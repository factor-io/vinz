module Sinatra
  module Vinz
    module Helpers

      def auth_super_admin
        token = request.env['HTTP_X_AUTH_TOKEN']
        user = User.find_by_api_key(token)
        puts user.username
        halt 401, 'Authorization denied' if user.nil? || !user.super_admin?
      end

      def auth_user
        token = request.env['HTTP_X_AUTH_TOKEN']
        @user = User.find_by_api_key(token)
        halt 401, 'Authorization denied' if @user.nil?
      end

      def auth_consumer
        token = request.enf['HTTP_X_AUTH_TOKEN']
        @consumer = Consumer.find_by_token(token)
        halt 401, 'Authorization denied' if @consumer.nil?
      end

    end
  end
end
