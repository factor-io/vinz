module Sinatra
  module API
    module Consumers

      def self.registered(app)
        app.get '/consumers' do
          auth_user
          {'consumers' => @user.organization.consumers}.to_json()
        end

        app.get '/consumers/:id' do
          auth_user

          begin
            consumer = Consumer.find(params[:id])
            verify_ownership(@user, consumer)
          rescue ActiveRecord::RecordNotFound
            halt 404
          end
          consumer.to_json(root: true)
        end

        app.post '/consumers' do
          auth_user

          consumer_data = @data['consumer']
          halt 400 if consumer_data.nil?

          consumer_data['organization_id'] ||= @user.organization.id
          unless @user.super_admin?
            halt 401 if consumer_data['organization_id'] != @user.organization.id
          end

          begin
            consumer = Consumer.create!(consumer_data)
          rescue ActiveRecord::RecordInvalid
            halt 400
          end

          status 201
          consumer.to_json(root: true)
        end

        app.put '/consumers/:id' do
          auth_user

          consumer_data = @data['consumer'].extract!(*%w{name})

          begin
            consumer = Consumer.find(params[:id])
            verify_ownership(@user, consumer)
            consumer.update_attributes!(consumer_data)
          rescue ActiveRecord::RecordNotFound
            halt 404
          rescue ActiveRecord::RecordInvalid
            halt 400
          end

          consumer.to_json(root: true)
        end

        app.delete '/consumers/:id' do
          auth_user

          begin
            consumer = Consumer.find(params[:id])
            verify_ownership(@user, consumer)
            consumer.destroy
          rescue ActiveRecord::RecordNotFound
            halt 404
          end
        end
      end

    end
  end

  register API::Consumers
end
