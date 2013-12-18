SHIP_EVERY = ENV['SHIP_EVERY'] || "1m"
SHIP_URL = ENV['SHIP_URL'].to_s.split(",")

unless SHIP_URL.empty?
  SCHEDULER.every SHIP_EVERY, :first_in => 0 do
    url = SHIP_URL.shuffle.first
    SENDER.send_event 'ship', url: url
  end
end
