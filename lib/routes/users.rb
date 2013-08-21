class Vinz < Sinatra::Base

  get '/users' do
    auth_admin
    @user.organization.users.all.to_json
  end

  get '/users/:id' do
    auth_admin

    begin
      user = User.find(params[:id])
      verify_ownership(@user, user)
    rescue ActiveRecord::RecordNotFound
      halt 404
    end
    user.to_json
  end

  post '/users' do
    auth_admin

    begin
      user = User.create!(@data)
    rescue ActiveRecord::RecordInvalid
      halt 400
    end

    status 201
    user.to_json
  end

  put '/users/:id' do
    auth_admin

    begin
      user = User.find(params[:id])
      verify_ownership(@user, user)
      user.update_attributes!(@data)
    rescue ActiveRecord::RecordNotFound
      halt 404
    rescue ActiveRecord::RecordInvalid
      halt 400
    end

    user.to_json
  end

  delete '/users/:id' do
    auth_admin

    begin
      user = User.find(params[:id])
      verify_ownership(@user, user)
      user.destroy
    rescue ActiveRecord::RecordNotFound
      halt 404
    end
  end

end
