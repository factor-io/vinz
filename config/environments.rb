configure do
end

configure :production do
  raise "ENCRYPTION_KEY is required" if ENV['ENCRYPTION_KEY'].nil?

  use Rack::SSL

  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  pg_config = vcap_services['postgresql-9.1'].first
  pg_creds = pg_config['credentials']
  ActiveRecord::Base.establish_connection(
    :adapter  => 'postgresql',
    :host     => pg_creds['host'],
    :username => pg_creds['user'],
    :password => pg_creds['password'],
    :database => pg_creds['name'],
    :encoding => 'utf8'
  )
end

configure :development do
  ENV['ENCRYPTION_KEY'] ||= 'USE AN ENVIRONMENT VAR HERE'
  set :database, 'sqlite:///vinz-dev.db'
end

configure :test do
  ENV['ENCRYPTION_KEY'] ||= 'USE AN ENVIRONMENT VAR HERE'
  set :database, 'sqlite:///vinz-test.db'
  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  ActiveRecord::Base.logger = logger
end
