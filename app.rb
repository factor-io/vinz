ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'lib/helpers'
require_relative 'config/environments'

class Organization < ActiveRecord::Base
  has_many :users
  has_many :consumers
  has_many :groups
  has_many :config_items
end

class User < ActiveRecord::Base
  belongs_to :organization

  def super_admin?
    role == 'super_admin'
  end

end

class Consumer < ActiveRecord::Base
  belongs_to :organization
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :config_items
end

class Group < ActiveRecord::Base
  belongs_to :organization
  has_and_belongs_to_many :consumers
  has_and_belongs_to_many :config_items
end

class ConfigItem < ActiveRecord::Base
  has_and_belongs_to_many :groups
end

class Vinz < Sinatra::Base
  helpers Sinatra::Vinz::Helpers

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
  end

  get '/consumers' do
  end

  post '/consumers' do
    auth_user
    user.organization.consumers.create(params)
  end

  get '/groups' do
    auth_user
  end

  get '/config_items' do
    auth_consumer
  end

end
