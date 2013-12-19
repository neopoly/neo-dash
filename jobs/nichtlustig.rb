
NICHTLUSTIG_EVERY = ENV['NICHTLUSTIG_EVERY'] || "5m"
NICHTLUSTIG_OVERVIEW_URL = ENV['NICHTLUSTIG_OVERVIEW_URL']
NICHTLUSTIG_IMAGE_URL = ENV['NICHTLUSTIG_IMAGE_URL'] || "http://static.nichtlustig.de/comics/full/%s.jpg"

if NICHTLUSTIG_OVERVIEW_URL
  require 'open-uri'

  overview = open(NICHTLUSTIG_OVERVIEW_URL).read.scan(%r{href=".*?(\d+)\.jpg"}i)
  ids = overview.map { |x| x[0] }

  SCHEDULER.every NICHTLUSTIG_EVERY, :first_in => 0 do
    id = ids.sample
    url = NICHTLUSTIG_IMAGE_URL % id
    SENDER.send_event 'nichtlustig', url: url
  end
end
