DASHBOARD_NOTEPAD_EVERY = ENV['DASHBOARD_NOTEPAD_EVERY'] || "1m"
DASHBOARD_NOTEPAD_URL = ENV['DASHBOARD_NOTEPAD_URL'].to_s.split(",")

require 'curb'

unless DASHBOARD_NOTEPAD_URL.empty?
  SCHEDULER.every DASHBOARD_NOTEPAD_EVERY, :first_in => 0 do
    url = DASHBOARD_NOTEPAD_URL.shuffle.first

    content = Curl::Easy.perform(url).body_str

    SENDER.send_event 'dashboard_notepad', content: content
  end
end
