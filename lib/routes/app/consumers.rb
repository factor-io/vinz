module Sinatra
  module App
    module Consumers
      def self.registered(app)

        app.post '/consumers' do
          require_login!

          errors = []
          if params['consumer'].nil?
            errors << 'Invalid consumer.'
          elsif params['consumer']['name'].blank?
            errors << 'Name cannot be empty.'
          end

          if errors.empty?
            begin
              @user.organization.consumers.create(params['consumer'])
            rescue ActiveRecord::RecordInvalid
              errors << "Error creating consumer."
            end
          end

          flash.now[:error] = errors.join("\n")
          redirect '/'
        end

        app.put '/consumers/:id' do
          require_login!

          errors = []
          if params['consumers'].nil? || params['consumers'][params['id']].nil?
            errors << 'Error updating consumer.'
          elsif params['consumers'][params['id']]['name'].blank?
            errors << 'Consumer name cannot be blank.'
          end

          begin
            consumer = Consumer.find(params['id'])
          rescue ActiveRecord::RecordNotFound
            errors << 'Could not find consumer.'
          end

          if consumer.organization != @user.organization
            errors << 'You do not have permission to update that consumer.'
          end

          if errors.empty?
            begin
              consumer.update_attributes(params['consumers'][params['id']])
            rescue ActiveRecord::RecordInvalid
              errors << 'Error updating consumer.'
            end
          end

          flash.now[:error] = errors.join("\n")
          redirect '/'
        end

        app.delete '/consumers/:id' do
          require_login!

          errors = []
          begin
            consumer = Consumer.find(params['id'])
          rescue ActiveRecord::RecordNotFound
            errors << 'Consumer could not be found.'
          end

          if consumer.organization != @user.organization
            errors << 'You do not have permission to delete that consumer.'
          end

          if errors.empty?
            consumer.destroy
          end

          flash.now[:error] = errors.join("\n")
          redirect '/'
        end


      end
    end
  end

  register App::Consumers
end
