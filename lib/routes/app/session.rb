module Sinatra
  module App
    module Session
      def self.registered(app)

        app.get '/login' do
          haml :login
        end

        app.post '/login' do
          username = params['username']
          password = params['password']

          user = User.find_by_username(username)
          if !user.nil? && password == user.password
            login(user)
            redirect '/'
          else
            redirect '/login'
          end
        end

        app.post '/logout' do
          session.delete(:user_id)
          redirect '/'
        end

        app.get '/register' do
          haml :register, layout: 'layouts/home'.to_sym
        end

        app.post '/register' do
          errors = []

          if params['organization'].nil? || params['organization']['name'].blank?
            errors << "Organization name is required."
          elsif Organization.exists?(name: params['organization']['name'])
            errors << "Organization already exists."
          end

          if params['user'].nil? || params['user']['username'].blank?
            errors << "Username is required."
          elsif User.exists?(username: params['user']['username'])
            errors << "Username is taken."
          end

          if params['user']['password'].blank?
            errors << "Password is required."
          elsif params['user']['password'] != params['confirm_password']
            errors << "Passwords must match."
          end

          if errors.empty?
            begin
              org = Organization.create(params['organization'])
            rescue ActiveRecord::RecordInvalid
              errors << "There was a problem. Please try again."
            end

            begin
              params['user']['role'] = 'admin'
              user = org.users.create(params['user'])
            rescue ActiveRecord::RecordInvalid
              errors << "There was a problem. Please try again."
              org.destroy
            end
          end

          if !errors.empty?
            flash.now[:error] = errors.join("\n")
            haml :register, layout: 'layouts/home'.to_sym
          else
            login(user)
            redirect '/'
          end
        end

      end
    end
  end

  register App::Session
end
