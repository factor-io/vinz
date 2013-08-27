require 'active_support/core_ext/hash/except'

module Sinatra
  module API
    module ConfigItems

      def self.registered(app)
        app.get '/config_items' do
          auth_consumer
          {'config_items' => @consumer.organization.config_items}.to_json
          #@consumer.organization.config_items.to_json(root: true)
        end

        app.get '/config_items/:id' do
          auth_consumer

          begin
            item = ConfigItem.find(params[:id])
            halt 401 if @consumer.organization != item.organization
          rescue ActiveRecord::RecordNotFound
            halt 404
          end

          item.to_json(root: true)
        end

        app.post '/config_items' do
          auth_user

          item_data = @data['config_item']
          halt 400 if item_data.nil?

          item_data['organization_id'] ||= @user.organization.id
          unless @user.super_admin?
            halt 401 if item_data['organization_id'] != @user.organization.id
          end

          item_data.extract!(%w{name value})

          begin
            item = ConfigItem.create!(item_data)
          rescue ActiveRecord::RecordInvalid
            halt 400
          end

          status 201
          item.to_json(root: true)
        end

        app.put '/config_items/:id' do
          auth_user
          item_data = @data['config_item']
          item_data.extract!(%w{name value})
          
          begin
            item = ConfigItem.find(params[:id])
            verify_ownership(@user, item)
            item.update_attributes!(item_data)
          rescue ActiveRecord::RecordNotFound
            halt 404
          rescue ActiveRecord::RecordInvalid
            halt 400
          end

          item.to_json(root: true)
        end

        app.delete '/config_items/:id' do
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

    end
  end

  register API::ConfigItems
end
