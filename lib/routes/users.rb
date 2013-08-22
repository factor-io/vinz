require 'active_support/core_ext/hash/except'

class Vinz < Sinatra::Base

  get '/users' do
    auth_admin
    @user.organization.users.to_json
  end

  get '/users/:id' do
    auth_admin

    begin
      user = User.find(params[:id])
      verify_ownership(@user, user)
    rescue ActiveRecord::RecordNotFound
      halt 404
    end
    user.to_json(except: :password)
  end

  post '/users' do
    auth_admin
    if @user.super_admin?
      halt 400 if @data['organization_id'].nil?
    else
      @data['organization_id'] ||= @user.organization.id
      halt 401 if @data['organization_id'] != @user.organization.id
    end
    @data.extract!(%w{username password role})

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
    @data.extract!(%w{username password role})

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
