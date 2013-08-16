ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'helpers'

class Vinz < Sinatra::Base
  helpers Sinatra::Vinz::Helpers

  before do
    auth
  end

  get '/' do
    'test'
  end

  get '/configs' do
  end

end
