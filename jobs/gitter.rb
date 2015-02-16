GITTER_ROOM_ID      = ENV["GITTER_ROOM_ID"]
GITTER_ACCESS_TOKEN = ENV["GITTER_ACCESS_TOKEN"]

class Gitter < Struct.new(:token, :room_id, :sender)
  NUMBER_OF_LAST_MESSAGES = 10

  def run
    load_last_messages!
    send_config_and_messages
  end

  private

  def send_config_and_messages
    sender.send_event 'gitter', {
      :access_token  => token,
      :room_id       => room_id,
      :last_messages => @last_messages || []
    }
  end

  def load_last_messages!
    uri = URI("https://api.gitter.im/v1/rooms/#{room_id}/chatMessages?limit=#{NUMBER_OF_LAST_MESSAGES}")
    @last_messages = perform_request(uri, Net::HTTP::Get.new(uri))
  end

  def perform_request(uri, request)
    request["Authorization"] = "Bearer #{token}"
    response = build_http_connector(uri).request(request)
    JSON.parse(response.body) if response.is_a?(Net::HTTPOK)
  end

  def build_http_connector(uri)
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      http.use_ssl = true
    end
  end
end

if GITTER_ROOM_ID && GITTER_ACCESS_TOKEN
  Gitter.new(GITTER_ACCESS_TOKEN, GITTER_ROOM_ID, SENDER).run
else
  warn "Env var GITTER_ROOM_ID and/or GITTER_ACCESS_TOKEN is missing. Skip gitter widget"
end
