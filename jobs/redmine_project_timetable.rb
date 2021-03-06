REDMINE_PROJECT_TIMETABLE_EVERY = ENV['REDMINE_PROJECT_TIMETABLE_EVERY'] || "10m"
REDMINE_PROJECT_TIMETABLE_URL   = (ENV['REDMINE_PROJECT_TIMETABLE_URL'] || "").to_s

unless REDMINE_PROJECT_TIMETABLE_URL.empty?
  SCHEDULER.every REDMINE_PROJECT_TIMETABLE_EVERY, :first_in => 0 do
    url = REDMINE_PROJECT_TIMETABLE_URL % { :month => Time.now.month.to_s, :year => Time.now.year.to_s, :cache_key => Time.now.to_i }
    SENDER.send_event 'redmine_project_timetable', url: url
  end
else
  warn "Env var REDMINE_PROJECT_TIMETABLE_URL is missing. Skip"
end
