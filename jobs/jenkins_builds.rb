require 'json'
require 'net/http'

JENKINS_BUILDS_EVERY = ENV['JENKINS_BUILDS_EVERY'] || "5s"
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
    failed_jobs = jobs.select(&:failed?)

    @sender.send :send_event, 'jenkins_builds',
      url:          @base_url.to_s,
      failed_jobs:  failed_jobs.map(&:to_hash)
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

SCHEDULER.every JENKINS_BUILDS_EVERY, :first_in => 0 do
  JenkinsBuilds.new(JENKINS_BUILDS_URL, self).run
end
