ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'lib/helpers'
require_relative 'config/environments'

class Organization < ActiveRecord::Base
  # Associations
  has_many :users
  has_many :consumers
  has_many :groups
  has_many :config_items

  # Validations
  validates :name, presence: true
end

class User < ActiveRecord::Base
  # Associations
  belongs_to :organization

  # Validations
  validates :username, presence: true
  validates :password, presence: true

  # Callbacks
  after_create :generate_api_key

  def super_admin?
    role == 'super_admin'
  end

  protected

  def generate_api_key
    self.update_attributes api_key: "user_#{id}"
  end
end

class Consumer < ActiveRecord::Base
  # Associations
  belongs_to :organization
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :config_items

  # Validations
  validates :name, presence: true

  # Callbacks
  before_create :generate_token

  protected

  def generate_token
    self.token = "consumer_#{id}"
  end
end

class Group < ActiveRecord::Base
  # Associations
  belongs_to :organization
  has_and_belongs_to_many :consumers
  has_and_belongs_to_many :config_items

  # Validations
  validates :name, presence: true
end

class ConfigItem < ActiveRecord::Base
  # Associations
  has_and_belongs_to_many :groups

  # Validations
  validates :name, presence: true
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
