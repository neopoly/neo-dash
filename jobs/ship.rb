SHIP_EVERY = ENV['SHIP_EVERY'] || "1m"
SHIP_URL = ENV['SHIP_URL']

abort "Need SHIP_URL to be set" unless SHIP_URL

SCHEDULER.every SHIP_EVERY, :first_in => 0 do
  url = SHIP_URL % { :t => Time.now.to_i }
  SENDER.send_event 'ship', url: url
end
