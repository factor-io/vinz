source 'https://rubygems.org'

gem 'rake', '10.0.4'
gem 'sinatra', '1.4.3'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'activesupport'
gem 'rack-ssl'
gem 'crypt_keeper'

group :production do
  gem 'pg'
end

group :test, :development do
  gem 'sqlite3'
  gem 'rspec'
  gem 'rack-test', '0.6.2'
  gem 'factory_girl'
  gem 'debugger'
end
