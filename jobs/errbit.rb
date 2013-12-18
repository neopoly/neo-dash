ERRBIT_EVERY = ENV['ERRBIT_EVERY'] || "10m"
ERRBIT_URL   = ENV['ERRBIT_URL']
ERRBIT_KEYS  = ENV['ERRBIT_KEYS']

abort "Need ERRBIT_URL to be set" unless ERRBIT_URL
abort "Need ERRBIT_KEYS to be set as CSV" unless ERRBIT_KEYS

SCHEDULER.every ERRBIT_EVERY, :first_in => 0 do |job|

  projects = ERRBIT_KEYS.split(",").map do |key|
    options = {:base_uri => ERRBIT_URL, :api_key => key, :skip_ssl_verification => true}
    Errbit.new(options).to_hash
  end

  send_event "errbit", { :projects => projects }

end
