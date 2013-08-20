ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'config/environments'
Dir[File.join("./lib", "**/*.rb")].each do |f|
  require f
end

class Vinz < Sinatra::Base
  helpers Sinatra::Vinz::Helpers

  set(:methods) do |*methods|
    methods = [methods].flatten
    condition { methods.include?(request.request_method.upcase) }
  end
  before methods: %w{POST PUT} do
    parse_json_body
  end

  get '/' do
    'test'
  end

end
