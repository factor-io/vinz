module Sinatra
  module App
    module ConfigItems
      def self.registered(app)

        app.post '/config_items' do
          require_login!

          errors = []
          if params['config_item'].nil?
            errors << 'Invalid config item.'
          elsif params['config_item']['name'].blank?
            errors << 'Name cannot be empty.'
          end

          if errors.empty?
            begin
              @user.organization.config_items.create(params['config_item'])
            rescue ActiveRecord::RecordInvalid
              errors << "Error creating config item."
            end
          end

          flash.now[:error] = errors.join("\n")
          redirect '/'
        end

        app.put '/config_items/:id' do
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

        app.delete '/config_items/:id' do
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


      end
    end
  end

  register App::ConfigItems
end
