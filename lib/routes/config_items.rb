require 'active_support/core_ext/hash/except'

class Vinz < Sinatra::Base

  get '/config_items' do
    auth_consumer
    @consumer.organization.config_items.to_json()
  end

  get '/config_items/:id' do
    auth_consumer

    begin
      item = ConfigItem.find(params[:id])
      halt 401 if @consumer.organization != item.organization
    rescue ActiveRecord::RecordNotFound
      halt 404
    end

    item.to_json
  end

  post '/config_items' do
    auth_user
    if @user.super_admin?
      halt 400 if @data['organization_id'].nil?
    else
      @data['organization_id'] ||= @user.organization.id
      halt 401 if @data['organization_id'] != @user.organization.id
    end
    @data.extract!(%w{name value})

    begin
      item = ConfigItem.create!(@data)
    rescue ActiveRecord::RecordInvalid
      halt 400
    end

    status 201
    item.to_json
  end

  put '/config_items/:id' do
    auth_user
    @data.extract!(%w{name value})
    
    begin
      item = ConfigItem.find(params[:id])
      verify_ownership(@user, item)
      item.update_attributes!(@data)
    rescue ActiveRecord::RecordNotFound
      halt 404
    rescue ActiveRecord::RecordInvalid
      halt 400
    end

    item.to_json
  end

  delete '/config_items/:id' do
    auth_user

    begin
      item = ConfigItem.find(params[:id])
      verify_ownership(@user, item)
      item.destroy
    rescue ActiveRecord::RecordNotFound
      halt 404
    end
  end

end
