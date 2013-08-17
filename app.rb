ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'config/environments'
Dir[File.join("./lib", "**/*.rb")].each do |f|
  require f
end

class Vinz < Sinatra::Base
  helpers Sinatra::Vinz::Helpers

  set(:method) do |*methods|
    methods = [methods].flatten
    methods.each do |method|
      method = method.to_s.upcase
      condition { request.request_method == method }
    end
  end
  before method: [:post, :put] do
    parse_json_body
  end

  get '/' do
    'test'
  end

  get '/organizations' do
    auth_super_admin
    Organization.all.to_json
  end

  get '/organizations/:id' do
    auth_user
    halt 401 if @user.organization.id != params[:id] && !@user.super_admin?

    begin
      org = Organization.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      halt 404
    end
    org.to_json
  end

  post '/organizations' do
    auth_super_admin
    org_keys = [:name]
    org_params = @data.select { |k, v| org_keys.include?(k) }
    org = Organization.create(org_params)
  end

  get '/consumers' do
  end

  post '/consumers' do
    auth_user
    user.organization.consumers.create()
  end

  get '/groups' do
    auth_user
  end

  get '/config_items' do
    auth_consumer
  end

end
