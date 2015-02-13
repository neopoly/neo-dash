GITTER_ROOM_ID      = ENV["GITTER_ROOM_ID"]
GITTER_ACCESS_TOKEN = ENV["GITTER_ACCESS_TOKEN"]

class Gitter < Struct.new(:token, :room_id, :sender)
  def run
    send_config
  end

  private

  def send_config
    sender.send_event 'gitter', {
      :access_token => token,
      :room_id      => room_id
    }
  end
end

if GITTER_ROOM_ID && GITTER_ACCESS_TOKEN
  Gitter.new(GITTER_ACCESS_TOKEN, GITTER_ROOM_ID, SENDER).run
else
  warn "Env var GITTER_ROOM_ID and/or GITTER_ACCESS_TOKEN is missing. Skip gitter widget"
end
