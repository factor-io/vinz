ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym
require 'active_support/core_ext'

require_relative 'config/environments'
Dir[File.join("./lib", "**/*.rb")].each do |f|
  require f
end

class VinzApp < Sinatra::Base
  require 'rack/csrf'
  require 'rack/flash'

  configure do
    use Rack::Session::Cookie, secret: ENV['SESSION_SECRET'] || 'Sssshh its a secret'
    use Rack::Csrf
    use Rack::Flash
    use Rack::MethodOverride
  end

  helpers do
    def csrf_token
      Rack::Csrf.csrf_token(env)
    end

    def csrf_tag
      Rack::Csrf.csrf_tag(env)
    end

    def link_to(text, action, options={})
      id = SecureRandom.hex
      _method = options[:method].to_s || 'get'
      method = 'get'
      method = 'post' unless _method == 'get'
      <<-eos
        <form name='#{id}' method='#{method}' action='#{action}' style="display:inline">
          #{csrf_tag}
          <input type="hidden" name="_method" value="#{_method}" />
          <a href='javascript: document.forms[\"#{id}\"].submit()'>#{text}</a>
        </form>
      eos
    end

    def delete_link(resource)
      link_to('Delete', "/#{resource.class.to_s.underscore.pluralize}/#{resource.id}", method: :delete)
    end

    def login(user)
      session[:user_id] = user.id
    end

    def authenticate!
      return nil if session[:user_id].nil?
      begin
        @user = User.find(session[:user_id])
      rescue ActiveRecord::RecordNotFound
        @user = nil
      end
      @user
    end

    def require_login!
      authenticate!
      redirect '/' if @user.nil?
    end

    def require_admin!
      authenticate!
      redirect '/' if @user.nil? || !@user.admin?
    end

    def require_super_admin!
      authenticate!
      redirect '/' if @user.nil? || !@user.super_admin?
    end
  end

  get '/' do
    authenticate!
    if @user.nil?
      haml :index, layout: 'layouts/home'.to_sym
    else
      haml 'console/index'.to_sym,
           layout: 'layouts/console'.to_sym,
           locals: {
             organization: @user.organization,
             user: @user,
             consumers: @user.organization.consumers,
             config_items: @user.organization.config_items
           }
    end
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    username = params['username']
    password = params['password']

    user = User.find_by_username(username)
    if !user.nil? && password == user.password
      login(user)
      redirect '/'
    else
      redirect '/login'
    end
  end

  post '/logout' do
    session.delete(:user_id)
    redirect '/'
  end

  get '/register' do
    haml :register, layout: 'layouts/home'.to_sym
  end

  post '/register' do
    errors = []

    if params['organization'].nil? || params['organization']['name'].blank?
      errors << "Organization name is required."
    elsif Organization.exists?(name: params['organization']['name'])
      errors << "Organization already exists."
    end

    if params['user'].nil? || params['user']['username'].blank?
      errors << "Username is required."
    elsif User.exists?(username: params['user']['username'])
      errors << "Username is taken."
    end

    if params['user']['password'].blank?
      errors << "Password is required."
    elsif params['user']['password'] != params['confirm_password']
      errors << "Passwords must match."
    end

    if errors.empty?
      begin
        org = Organization.create(params['organization'])
      rescue ActiveRecord::RecordInvalid
        errors << "There was a problem. Please try again."
      end

      begin
        params['user']['role'] = 'admin'
        user = org.users.create(params['user'])
      rescue ActiveRecord::RecordInvalid
        errors << "There was a problem. Please try again."
        org.destroy
      end
    end

    if !errors.empty?
      flash.now[:error] = errors.join("\n")
      haml :register, layout: 'layouts/home'.to_sym
    else
      login(user)
      redirect '/'
    end
  end

  post '/config_items' do
    require_login!

    errors = []
    if params['config_item'].nil?
      errors << 'Invalid config item.'
    elsif params['config_item']['name'].blank?
      errors << 'Name cannot be empty.'
    end

    if errors.empty?
      begin
        item = @user.organization.config_items.create(params['config_item'])
      rescue ActiveRecord::RecordInvalid
        errors << "Error creating config item."
      end
    end

    flash.now[:error] = errors.join("\n")
    redirect '/'
  end

  put '/config_items/:id' do
    require_login!

    errors = []
    if params['config_items'].nil? || params['config_items'][params['id']].nil?
      errors << 'Error updating config item.'
    elsif params['config_items'][params['id']]['name'].blank?
      errors << 'Item name cannot be blank.'
    end

    begin
      item = ConfigItem.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      errors << 'Could not find item.'
    end

    if item.organization != @user.organization
      errors << 'You do not have permission to update that item.'
    end

    if errors.empty?
      begin
        item.update_attributes(params['config_items'][params['id']])
      rescue ActiveRecord::RecordInvalid
        errors << 'Error updating item.'
      end
    end

    flash.now[:error] = errors.join("\n")
    redirect '/'
  end

  delete '/config_items/:id' do
    require_login!

    errors = []
    begin
      item = ConfigItem.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      errors << 'Item could not be found.'
    end

    if item.organization != @user.organization
      errors << 'You do not have permission to delete that item.'
    end

    if errors.empty?
      item.destroy
    end

    flash.now[:error] = errors.join("\n")
    redirect '/'
  end

  get '/admin/organizations' do
    require_super_admin!
    Organization.all.to_json
  end

  get '/admin/users' do
    require_super_admin!
    User.all.to_json
  end

end

class VinzAPI < Sinatra::Base
  helpers Sinatra::Vinz::Helpers

  register Sinatra::API::Organizations
  register Sinatra::API::Users
  register Sinatra::API::Consumers
  register Sinatra::API::ConfigItems

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
