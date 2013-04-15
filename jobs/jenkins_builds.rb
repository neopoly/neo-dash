require 'json'
require 'net/http'

JENKINS_BUILDS_EVERY = ENV['JENKINS_BUILDS_EVERY'] || "5s"
JENKINS_BUILDS_URL = ENV['JENKINS_BUILDS_URL']

abort "Need JENKINS_BUILDS_URL to be set" unless JENKINS_BUILDS_URL

class JenkinsBuilds
  def initialize(url, sender)
    @url    = url
    @sender = sender
  end

  def run
    response = fetch(@url)
    send_events(response)
  end

  private

  def send_events(response)
    @sender.send_event 'jenkins_builds',
      url:          response.base_url,
      failed_jobs:  response.failed_jobs.map(&:to_hash)
  end

  def fetch(url)
    json = JSON Net::HTTP.get(URI(url))
    Response.new(json)
  rescue => e
    warn "Failed to fetch jenkins builds: #{e.class}"
    Response.new({})
  end


  class Response
    attr_reader :jobs

    def initialize(json)
      @json = json
    end

    def jobs
      @json.fetch("jobs", []).map { |job| Job.new(job) }
    end

    def failed_jobs
      jobs.select(&:failed?)
    end

    def base_url
      @json.fetch("primaryView", {}).fetch("url", "?")
    end
  end

  class Job
    attr_reader :name, :url

    def initialize(json)
      @json   = json
    end

    def failed?
      @json["color"] == "red"
    end

    def to_hash
      @json
    end
  end
end

SCHEDULER.every JENKINS_BUILDS_EVERY, :first_in => 0 do
  JenkinsBuilds.new(JENKINS_BUILDS_URL, SENDER).run
end
