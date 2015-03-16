class ImageUrlResolver
  require 'open-uri'
  require 'nokogiri'

  def self.run(base_url)
    instance = new(base_url)
    instance.send(:run)
    instance.send(:image_urls)
  end

  private

  attr_reader :base_url
  attr_accessor :image_urls

  def initialize(base_url)
    @base_url = base_url
    @image_urls = []
  end

  def run
    collect_images_urls(base_url)
  end

  def collect_images_urls(current_url)
    current_doc = document(current_url)

    dirs(current_doc).each do |dir|
      begin
        next_url = build_url(current_url, dir)
        next_doc = document(next_url)

        images(next_doc).each do |e|
          add image_url(next_url, e)
        end

        collect_images_urls(next_url)
      end
    end
  end

  def add(image_url)
    image_urls << image_url
  end

  def image_url(url, element)
    url + '/' + element.attributes['data-file'].value + '&download'
  end

  def build_url(url, dir)
    if url.scan(/&path/).any?
      url + "/#{dir}"
    else
      url + "&path=//#{dir}"
    end
  end

  def document(url)
    Nokogiri::HTML(open(url).read)
  end

  def dirs(doc)
    doc.css(dir_selector).map {|e| e.attributes['data-file'].value }
  end

  def images(doc)
    doc.css(image_selector)
  end

  def dir_selector
    '#fileList tr[data-type=dir]'
  end

  def image_selector
    'tr[data-mime="image/jpeg"]'
  end
end

OWNCLOUD_OVERVIEW_URL = ENV['OWNCLOUD_OVERVIEW_URL']

if OWNCLOUD_OVERVIEW_URL
  OWNCLOUD_EVERY = ENV['OWNCLOUD_EVERY'] || "60s"

  SCHEDULER.every OWNCLOUD_EVERY, :first_in => 0 do
    image_urls = ImageUrlResolver.run(OWNCLOUD_OVERVIEW_URL)

    SENDER.send_event 'owncloud', url: image_urls.sample
  end
end
