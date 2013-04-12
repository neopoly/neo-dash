require 'json'
require 'net/http'

JENKINS_BUILDS_URL = ENV['JENKINS_BUILDS_URL']

abort "Need JENKINS_BUILDS_URL to be set" unless JENKINS_BUILDS_URL

class JenkinsBuilds
  def initialize(base_url, sender)
    @base_url = URI(base_url)
    @sender = sender
  end

  def run
    jobs = fetch_jobs
    send_events(jobs)
  end

  def send_events(jobs)
    failed = jobs.select(&:failed?)

    @sender.send :send_event, 'jenkins_builds',
      url:          @base_url.to_s,
      total_count:  jobs.size,
      failed_count: failed.size,
      failed:  failed.map(&:to_hash)
  end

  def fetch_jobs
    uri = @base_url + "/api/json"
    json = JSON Net::HTTP.get(uri)
    jobs = json["jobs"].map { |job| JenkinsJob.new(job) }
  end

  class JenkinsJob
    attr_reader :name, :url

    def initialize(json)
      @color  = json["color"]
      @json   = json
    end

    def failed?
      @color == "red"
    end

    def to_hash
      @json
    end
  end
end

SCHEDULER.every '5s', :first_in => 0 do
  JenkinsBuilds.new(JENKINS_BUILDS_URL, self).run
end
