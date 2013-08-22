module Sinatra
  module API
    module Organizations
      def self.registered(app)

        app.get '/organizations' do
          auth_super_admin
          Organization.all.to_json
        end

        app.get '/organizations/:id' do
          auth_user
          halt 401 if @user.organization.id != params[:id] && !@user.super_admin?

          begin
            org = Organization.find(params[:id])
          rescue ActiveRecord::RecordNotFound
            halt 404
          end
          org.to_json
        end

        app.post '/organizations' do
          auth_super_admin
          begin
            org = Organization.create!(@data)
          rescue ActiveRecord::RecordInvalid
            halt 400
          end

          status 201
          org.to_json
        end

        app.put '/organizations/:id' do
          auth_admin
          halt 401 if @user.organization.id != params[:id] && !@user.super_admin?

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

        app.delete '/organizations/:id' do
          auth_admin
          halt 401 if @user.organization.id != params[:id] && !@user.super_admin?

          begin
            Organization.destroy(params[:id])
          rescue ActiveRecord::RecordNotFound
            halt 404
          end
        end

      end
    end
  end

  register API::Organizations
end
