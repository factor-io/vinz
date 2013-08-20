class Vinz < Sinatra::Base

  get '/groups' do
    auth_user
  end

  get '/groups/:id' do
    auth_user

    begin
      group = Group.find(params[:id])
      verify_ownership(@user, group)
    rescue ActiveRecord::RecordNotFound
      halt 404
    end
    group.to_json
  end

  post '/groups' do
    auth_user

    begin
      group = Group.create!(@data)
    rescue ActiveRecord::RecordInvalid
      halt 400
    end

    status 201
    group.to_json
  end

  put '/groups/:id' do
    auth_user

    begin
      group = Group.find(params[:id])
      verify_ownership(@user, group)
      group.update_attributes!(@data)
    rescue ActiveRecord::RecordNotFound
      halt 404
    rescue ActiveRecord::RecordInvalid
      halt 400
    end

    group.to_json
  end

  delete '/groups/:id' do
    auth_user

    begin
      group = Group.find(params[:id])
      verify_ownership(@user, group)
      group.destroy
    rescue ActiveRecord::RecordNotFound
      halt 404
    end
  end

end
