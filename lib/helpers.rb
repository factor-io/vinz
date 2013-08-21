require 'json'

module Sinatra
  module Vinz
    module Helpers

      def get_user(token)
        key = ApiKey.find_by_key(token)
        if key.nil? || key.key_owner.class != User
          halt 401
        end
        key.key_owner
      end

      def get_consumer(token)
        key = ApiKey.find_by_key(token)
        halt 401 if key.nil? || key.key_owner.class != Consumer
        key.key_owner
      end

      def auth_super_admin
        @user = get_user(request.env['HTTP_X_AUTH_TOKEN'])
        halt 401, 'Authorization denied' if @user.nil? || !@user.super_admin?
      end

      def auth_admin
        @user = get_user(request.env['HTTP_X_AUTH_TOKEN'])
        halt 401, 'Authorization denied' if @user.nil? || !@user.admin?
      end

      def auth_user
        @user = get_user(request.env['HTTP_X_AUTH_TOKEN'])
        halt 401, 'Authorization denied' if @user.nil?
      end

      def auth_consumer
        @consumer = get_consumer(request.env['HTTP_X_AUTH_TOKEN'])
        halt 401, 'Authorization denied' if @consumer.nil?
      end

      def verify_ownership(user, resource)
        halt 401 if user.organization != resource.organization && !user.super_admin?
      end

      def parse_json_body
        request.body.rewind
        @data = JSON.parse request.body.read, quirks_mode: true
      end

    end
  end
end
