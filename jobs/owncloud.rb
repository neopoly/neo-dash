class ChachedImageResolver
  def initialize
    @images = []
    @current = 0
    @size = 0
  end

  def next_image(url)
    if @images.empty?
      @current = 0
      @images = ImageResolver.run(url).shuffle
      @size = @images.size
    end

    @current += 1
    @images.pop
  end

  def counter
    "#{@current} von #{@size}"
  end
end

class ImageResolver
  require 'open-uri'
  require 'nokogiri'

  def self.run(base_url)
    instance = new(base_url)
    instance.send(:run)
    instance.send(:images)
  end

  private

  attr_reader :base_url
  attr_accessor :images

  def initialize(base_url)
    @base_url = base_url
    @images = []
  end

  def run
    collect_images_urls(base_url)
  end

  def collect_images_urls(current_url)
    current_doc = document_for(current_url)

    dirs_for(current_doc).each do |dir|
      begin
        next_url = build_url(current_url, dir)
        next_doc = document_for(next_url)

        images_for(next_doc).each do |e|
          add image(image_url(next_url, e), next_doc)
        end

        collect_images_urls(next_url)
      end
    end
  end

  def image(image_url, next_doc)
    Image.new(image_url, next_doc)
  end

  class Image
    attr_reader :url
    def initialize(image_url, doc)
      @url = image_url
      @doc = doc
    end

    def label
      [event, dir].join(' / ')
    end

    private

    def event
      @doc.css('#header #details').first.text.scan(/shared the folder (.*) with you/).flatten.first.capitalize
    end

    def dir
      path = @doc.css('input[@name="dir"]').first.attr('value')
      path.split(/\//).map do |crumb|
        unless crumb.empty?
          crumb.capitalize
        end
      end.compact
    end
  end

  def add(image)
    images << image
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

  def document_for(url)
    Nokogiri::HTML(open(url).read)
  end

  def dirs_for(doc)
    doc.css(dir_selector).map {|e| e.attributes['data-file'].value }
  end

  def images_for(doc)
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
  OWNCLOUD_EVERY = ENV['OWNCLOUD_EVERY'] || "10s"

  resolver = ChachedImageResolver.new

  SCHEDULER.every OWNCLOUD_EVERY, :first_in => 0 do
    image = resolver.next_image(OWNCLOUD_OVERVIEW_URL)
    counter = resolver.counter

    SENDER.send_event 'owncloud', url: image.url, label: image.label, counter: counter
  end
end
