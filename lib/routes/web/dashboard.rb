module Sinatra
  module Web
    module Dashboard
      def self.registered(app)

        app.get '/' do
          authenticate!
          if @user.nil?
            haml :index, layout: 'layouts/home'.to_sym
          else
            haml 'console/index'.to_sym,
                layout: 'layouts/console'.to_sym,
                locals: {
                  organization: @user.organization,
                  user: @user,
                  consumers: @user.organization.consumers,
                  config_items: @user.organization.config_items
                }
          end
        end

      end
    end
  end

  register Web::Dashboard
end
