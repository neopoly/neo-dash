OWNCLOUD_EVERY = ENV['OWNCLOUD_EVERY'] || "60s"
OWNCLOUD_OVERVIEW_URL = ENV['OWNCLOUD_OVERVIEW_URL']
OWNCLOUD_IMAGE_URL = ENV['OWNCLOUD_IMAGE_URL'] || OWNCLOUD_OVERVIEW_URL + '&download&path=//%s'

if OWNCLOUD_OVERVIEW_URL
  require 'open-uri'
  require 'nokogiri'

  doc = Nokogiri::HTML(open(OWNCLOUD_OVERVIEW_URL).read)
  images = doc.css('#fileList tr[data-file]').map {|e| e.attributes['data-file'].value }

  SCHEDULER.every OWNCLOUD_EVERY, :first_in => 0 do
    image = images.sample
    url = OWNCLOUD_IMAGE_URL % image
    SENDER.send_event 'owncloud', url: url
  end
end
