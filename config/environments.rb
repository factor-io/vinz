configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/vinz')

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
end

configure :development do
  set :database, 'sqlite:///vinz-dev.db'
end

configure :test do
  set :database, 'sqlite:///vinz-test.db'
  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  ActiveRecord::Base.logger = logger
end
