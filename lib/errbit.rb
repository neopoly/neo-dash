require "open-uri"
require "net/http"
require "json"

class Errbit

  attr_reader :api_key, :base_uri, :skip_ssl_verification, :response

  def initialize(options)
    @api_key     = options.delete(:api_key)
    @base_uri    = options.delete(:base_uri)
    @skip_ssl_verification = options.delete(:skip_ssl_verification) || false
    @response    = parse read(errbit_uri)
  end

  def to_hash
    {
      :name   => name,
      :status => status,
      :date   => date,
      :errors => errors
    }
  end

  private

  def name
    response[:name]
  end

  def status
    errors == 0 ? "passed" : "failed"
  end

  def date
    response[:last_error_time]
  end

  def errors
    response[:unresolved_errors]
  end

  def read(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if skip_ssl_verification
    http.use_ssl     = true
    http.get(uri).body
  end

  def parse(data)
    JSON.parse data, :symbolize_names => true
  end

  def errbit_uri
    URI.parse("#{base_uri}/api/v1/stats/app.json?api_key=#{api_key}")
  end

end
