require 'active_support/core_ext/module/delegation'
require 'feedzirra'

REDMINE_ACTIVITY_EVERY = ENV['REDMINE_ACTIVITY_EVERY'] || "120s"
REDMINE_ACTIVITY_URL   = ENV['REDMINE_ACTIVITY_URL']

abort "Need REDMINE_ACTIVITY_URL to be set" unless REDMINE_ACTIVITY_URL

class RedmineActivities
  def initialize(base_url, sender)
    @base_url = base_url
    @sender   = sender
  end

  def run
    if activities = fetch_activities
      send_projects activites_to_projects(activities)
    end
  end

  protected

  def fetch_activities
    feed = Feedzirra::Feed.fetch_and_parse(@base_url)
    unless feed.is_a?(Fixnum) # Feezirra returns a status code in case of an error
      parse_activites feed.entries
    end
  end

  def parse_activites(entries)
    entries.map{|entry| RedmineActivities::RedmineActivity.new(entry)}
  end

  def activites_to_projects(activities)
    projects = {}
    activities.each do |activity|
      project = projects[activity.project] ||= RedmineProject.new(activity.project)
      project << activity
    end
    projects.values.sort_by{|p| -p.size}
  end

  def send_projects(projects)
    @sender.send :send_event, 'redmine_activity_projects',
      projects: projects.map(&:to_hash)
  end

  class RedmineProject
    attr_reader :activities, :name

    delegate :<<, :size, :to => :activities

    def initialize(name)
      @name       = name
      @activities = []
    end

    def updated_at
      activities.map(&:at).sort.last
    end

    def to_hash
      {
        :name       => name,
        :activities => activities.map(&:to_hash),
        :size       => size,
        :updated_at => updated_at
      }
    end
  end

  class RedmineActivity
    TITLE_PATTERN = /(\w+) \-.*/

    attr_reader :project

    delegate :title, :id, :to => :@feed_entry

    def initialize(feed_entry)
      @feed_entry = feed_entry
      if title =~ TITLE_PATTERN
        @project = $1
      else
        @project = ""
      end
    end

    def user
      @feed_entry.author
    end

    def inspect
      "activity:#{id}"
    end

    def at
      @feed_entry.updated
    end

    def to_hash
      {
        :title   => title,
        :project => project,
        :user    => user,
        :at      => at
      }
    end
  end
end


SCHEDULER.every REDMINE_ACTIVITY_EVERY, :first_in => 0 do |job|
  RedmineActivities.new(REDMINE_ACTIVITY_URL, self).run
end


