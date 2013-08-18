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
    begin
      org = Organization.create!(@data)
    rescue ActiveRecord::RecordInvalid
      halt 400
    end

    status 201
    org.to_json
  end

  put '/organizations/:id' do
    auth_super_admin
    begin
      org = Organization.find(params[:id])
      org.update_attributes!(@data)
    rescue ActiveRecord::RecordNotFound
      halt 404
    rescue ActiveRecord::RecordInvalid
      halt 400
    end

    org.to_json
  end

  delete '/organizations/:id' do
    auth_super_admin
    begin
      Organization.destroy(params[:id])
    rescue ActiveRecord::RecordNotFound
      halt 404
    end
  end

  get '/consumers' do
    auth_user
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
