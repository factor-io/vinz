module Sinatra
  module App
    module Admin
      def self.registered(app)

        app.get '/admin/organizations' do
          require_super_admin!
          Organization.all.to_json
        end

        app.get '/admin/users' do
          require_super_admin!
          User.all.to_json
        end

      end
    end
  end

  register App::Admin
end
