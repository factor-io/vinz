class Vinz < Sinatra::Base

  get '/config_items' do
    auth_consumer
    @consumer.config_items.to_json
  end

  get '/config_items/:id' do
    auth_consumer

    begin
      item = ConfigItem.find(params[:id])
      halt 401 if (@consumer.groups & item.groups).empty?
    rescue ActiveRecord::RecordNotFound
      halt 404
    end

    item.to_json
  end

  post '/config_items' do
    auth_user

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
