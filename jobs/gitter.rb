GITTER_ROOM_ID      = ENV["GITTER_ROOM_ID"]
GITTER_ACCESS_TOKEN = ENV["GITTER_ACCESS_TOKEN"]
GITTER_EVERY        = ENV["GITTER_EVERY"] || "1m"
GITTER_MAX_MESSAGES = (ENV["GITTER_MAX_MESSAGES"] || 10).to_i
GITTER_MAX_WORDS    = (ENV["GITTER_MAX_WORDS"] || 20).to_i

require 'time'

class GitterClient < Struct.new(:token, :room_id)
  def get_messages(resource)
    uri = URI("https://api.gitter.im/v1/rooms/#{room_id}/#{resource}?limit=#{GITTER_MAX_MESSAGES}")
    perform_request(uri, Net::HTTP::Get.new(uri)).map do |raw|
      GitterMessage.new(raw.merge("resource" => resource))
    end
  end

  private

  def perform_request(uri, request)
    request["Authorization"] = "Bearer #{token}"
    response = build_http_connector(uri).request(request)
    return JSON.parse(response.body) if response.is_a?(Net::HTTPOK)
    []
  end

  def build_http_connector(uri)
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      http.use_ssl = true
    end
  end
end

class GitterMessage < OpenStruct
  def <=>(other)
    if self.sent && other.sent
       Time.parse(self.sent) <=> Time.parse(other.sent)
    else
      1
    end
  end

  def as_json(*args)
    to_h.merge(:text => truncated_text)
  end

  private

  def truncated_text
    sep = /\s+/
    if text =~ /\A((?:.+?#{sep}){#{GITTER_MAX_WORDS - 1}}.+?)#{sep}.*/m
      "#{$1} ..."
    else
      text.dup
    end
  end
end

class Gitter < Struct.new(:client, :sender)
  def run
    @messages = []
    load_chat_messages!
    load_events!
    send_messages
  end

  private

  def send_messages
    sender.send_event 'gitter', {
      :messages => @messages.sort.last(GITTER_MAX_MESSAGES)
    }
  end

  def load_chat_messages!
    @messages += client.get_messages("chatMessages")
  end

  def load_events!
    @messages += client.get_messages("events")
  end
end

if GITTER_ROOM_ID && GITTER_ACCESS_TOKEN
  client = GitterClient.new(GITTER_ACCESS_TOKEN, GITTER_ROOM_ID)
  SCHEDULER.every GITTER_EVERY, :first_in => 0 do
    Gitter.new(client, SENDER).run
  end
else
  warn "Env var GITTER_ROOM_ID and/or GITTER_ACCESS_TOKEN is missing. Skip gitter widget"
end
