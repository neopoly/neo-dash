require 'set'
require 'digest/md5'
require 'active_support/core_ext/module/delegation'
require 'sax-machine'
require 'feedzirra'

REDMINE_ACTIVITY_EVERY = ENV['REDMINE_ACTIVITY_EVERY'] || "120s"
REDMINE_ACTIVITY_URL   = ENV['REDMINE_ACTIVITY_URL']

abort "Need REDMINE_ACTIVITY_URL to be set" unless REDMINE_ACTIVITY_URL

class RedmineActivities
  REDMINE_URL_PATTERN = /(.+)activity\.atom/

  def initialize(url, sender)
    @url    = url
    @sender = sender
  end

  def run
    if activities = fetch_activities
      projects = NamedPool.new Project
      users    = NamedPool.new User

      unpack_activities(activities, projects, users)

      send_projects projects
      send_users    users
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
    entries.map { |entry| Activity.new(entry) }.select(&:valid?)
  end

  def unpack_activities(activities, projects, users)
    activities.each do |activity|
      project = projects.find_or_create_by_name(activity.project)
      project.add_activity activity
      user    = users.find_or_create_by_name(activity.author.name, :email => activity.author.email)
      user.add_activity activity
      project.add_user user
    end
  end

  def send_projects(projects)
    # only send projects with more than one activity
    @sender.send_event 'redmine_activity_projects',
      projects: projects.select{|p| p.size > 1}.sort.map(&:to_hash)
  end

  def send_users(users)
    @sender.send_event 'redmine_activity_users',
      users: users.sort.map(&:to_hash)
  end

  class NamedPool
    delegate :each, :map, :size, :sort, :select, :to => :all

    def initialize(klass)
      @klass = klass
      clear!
    end

    def find_or_create_by_name(name, attributes = {})
      @pool[name] ||= @klass.new(attributes.merge(:name => name))
    end

    def all
      @pool.values
    end

    def clear!
      @pool = Hash.new
    end
  end

  class ActivityHolder
    include Comparable
    attr_reader :activities
    private :activities

    delegate :size, :to => :activities

    def initialize
      @activities = Set.new
    end

    def add_activity(activity)
      activities << activity
    end

    def updated_at
      activities.map(&:at).sort.last
    end

    def <=>(other)
      result = other.size <=> self.size
      result = other.updated_at <=> self.updated_at if result == 0
      result
    end

    def url
      self.class.url + name
    end

    def to_hash
      {
        :activities => activities.map(&:to_hash),
        :size       => size,
        :url        => url,
        :updated_at => updated_at
      }
    end

    protected

    def self.url
      @url ||= REDMINE_ACTIVITY_URL[REDMINE_URL_PATTERN,1] + "projects/"
    end
  end

  class Project < ActivityHolder
    attr_reader :users, :name

    def initialize(attributes)
      super()
      @name       = attributes[:name]
      @users      = Set.new
    end

    def inspect
      "project:#{name}"
    end

    def add_user(user)
      if users.add?(user)
        user.add_project self
      end
      user
    end

    def url
      self.class.url + name.gsub(" ","-") + "/activity"
    end

    def to_hash
      super.merge({
        :name       => name,
        :url        => url,
        :users      => users.map(&:to_base_hash)
      })
    end

    protected

    def self.url
      @url ||= REDMINE_ACTIVITY_URL[REDMINE_URL_PATTERN,1] + "projects/"
    end
  end

  class User < ActivityHolder
    attr_reader :name, :email

    GRAVATAR_URL = "https://www.gravatar.com/avatar/"

    def initialize(attributes)
      super()
      @name       = attributes[:name]
      @email      = attributes[:email]
      @projects   = Set.new
    end

    def inspect
      "user:#{name}"
    end

    def add_project(project)
      @projects << project
    end

    def recent_projects(n = 3)
      @projects.sort_by(&:updated_at).reverse.first(n)
    end

    def avatar
      GRAVATAR_URL + Digest::MD5.hexdigest(email.strip.downcase)
    end

    def to_base_hash
      {
        :name       => name,
        :email      => email,
        :avatar     => avatar
      }
    end

    def to_hash
      super.merge(to_base_hash).merge({
        :projects   => recent_projects.map(&:to_hash)
      })
    end
  end

  class Activity
    # Matches titles like "project-name - Task #1 ..."
    PROJECT_PATTERN = /^([\w\-_ ]+) - /

    attr_reader :project, :author

    delegate :title, :id, :to => :@feed_entry

    def initialize(feed_entry)
      @feed_entry = feed_entry
      @project    = title[PROJECT_PATTERN, 1] || ""
      @author     = @feed_entry.author
    end

    def inspect
      "activity:#{id}"
    end

    def valid?
      !!@author.try(:valid?)
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

  # Simple wrapper to contain an atom entry author
  class AuthorEntry
    include SAXMachine

    element :name
    element :email

    def valid?
      name && email
    end
  end

  # Extract name AND email from the author field
  # (Feedzirra would normally only use the name)
  class Feedzirra::Parser::AtomEntry
    element :author, :class => AuthorEntry
  end
end

SCHEDULER.every REDMINE_ACTIVITY_EVERY, :first_in => 0 do |job|
  RedmineActivities.new(REDMINE_ACTIVITY_URL, SENDER).run
end
