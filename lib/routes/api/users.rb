require 'active_support/core_ext/hash/except'

module Sinatra
  module API
    module Users

      def self.registered(app)
        app.get '/users' do
          auth_admin
          {users: @user.organization.users}.to_json
        end

        app.get '/users/:id' do
          auth_admin

          begin
            user = User.find(params[:id])
            verify_ownership(@user, user)
          rescue ActiveRecord::RecordNotFound
            halt 404
          end
          user.to_json(except: :password, root: true)
        end

        app.post '/users' do
          auth_admin

          user_data = @data['user']
          halt 400 if user_data.nil?

          user_data['organization_id'] ||= @user.organization.id
          unless @user.super_admin?
            halt 401 if user_data['organization_id'] != @user.organization.id
          end

          user_data = user_data.extract!(*%w{organization_id username password role})

          begin
            user = User.create!(user_data)
          rescue ActiveRecord::RecordInvalid
            halt 400
          end

          status 201
          user.to_json(except: :password, root: true)
        end

        app.put '/users/:id' do
          auth_admin

          user_data = @data['user']
          halt 400 if user_data.nil?
          user_data = user_data.extract!(*%w{username password role})

          begin
            user = User.find(params[:id])
            verify_ownership(@user, user)
            user.update_attributes!(user_data)
          rescue ActiveRecord::RecordNotFound
            halt 404
          rescue ActiveRecord::RecordInvalid
            halt 400
          end

          user.to_json(except: :password, root: true)
        end

        app.delete '/users/:id' do
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

    end
  end

  register API::Users
end
