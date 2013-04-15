require 'active_support/core_ext/module/delegation'
require 'feedzirra'

REDMINE_ACTIVITY_EVERY = ENV['REDMINE_ACTIVITY_EVERY'] || "120s"
REDMINE_ACTIVITY_URL   = ENV['REDMINE_ACTIVITY_URL']

abort "Need REDMINE_ACTIVITY_URL to be set" unless REDMINE_ACTIVITY_URL

class RedmineActivities
  def initialize(url, sender)
    @url    = url
    @sender = sender
  end

  def run
    if activities = fetch_activities
      send_projects activities_to_projects(activities)
      send_users    activities_to_users(activities)
    end
  end

  protected

  def fetch_activities
    feed = Feedzirra::Feed.fetch_and_parse(@url)
    unless feed.is_a?(Fixnum) # Feedzirra returns a status code in case of an error
      parse_activites feed.entries
    end
  end

  def parse_activites(entries)
    entries.map { |entry| Activity.new(entry) }
  end

  def activities_to_projects(activities)
    projects = Hash.new { |hash, project| hash[project] = Project.new(project) }
    activities.each do |activity|
      projects[activity.project] << activity
    end
    projects.values.sort
  end

  def activities_to_users(activities)
    users = Hash.new { |hash, name| hash[name] = User.new(name) }
    activities.each do |activity|
      users[activity.author] << activity
    end
    users.values.sort
  end

  def send_projects(projects)
    @sender.send_event 'redmine_activity_projects',
      projects: projects.map(&:to_hash)
  end

  def send_users(users)
    @sender.send_event 'redmine_activity_users',
      users: users.map(&:to_hash)
  end

  class Project
    include Comparable
    attr_reader :activities, :name

    delegate :<<, :size, :to => :activities

    def initialize(name)
      @name       = name
      @activities = []
    end

    def updated_at
      activities.map(&:at).sort.last
    end

    def <=>(other)
      result = other.size <=> self.size
      result = other.updated_at <=> self.updated_at if result == 0
      result
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

  class User
    include Comparable
    attr_reader :activities, :name

    delegate :<<, :size, :to => :activities

    def initialize(name)
      @name       = name
      @activities = []
    end

    def updated_at
      activities.map(&:at).sort.last
    end

    def <=>(other)
      result = other.size <=> self.size
      result = other.updated_at <=> self.updated_at if result == 0
      result
    end

    # TODO refactor!
    def projects
      projects = Hash.new { |hash, project| hash[project] = Project.new(project) }
      activities.each do |activity|
        projects[activity.project] << activity
      end
      projects.values.sort_by(&:updated_at).reverse
    end

    def to_hash
      {
        :name       => name,
        :projects   => projects.first(3).map(&:to_hash),
        :size       => size,
        :updated_at => updated_at
      }
    end
  end

  class Activity
    PROJECT_PATTERN = /^([^-]+) -/

    attr_reader :project, :author

    delegate :title, :id, :to => :@feed_entry

    def initialize(feed_entry)
      @feed_entry = feed_entry
      @project    = title[PROJECT_PATTERN] || ""
      @author     = @feed_entry.author
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
        :author  => author,
        :at      => at
      }
    end
  end
end


SCHEDULER.every REDMINE_ACTIVITY_EVERY, :first_in => 0 do |job|
  RedmineActivities.new(REDMINE_ACTIVITY_URL, SENDER).run
end
