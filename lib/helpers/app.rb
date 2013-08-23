module Sinatra
  module App
    module Helpers
      def csrf_token
        Rack::Csrf.csrf_token(env)
      end

      def csrf_tag
        Rack::Csrf.csrf_tag(env)
      end

      def link_to(text, action, options={})
        id = SecureRandom.hex
        _method = options[:method].to_s || 'get'
        method = 'get'
        method = 'post' unless _method == 'get'
        klass = options[:class] || ''
        <<-eos
          <form name='#{id}' method='#{method}' action='#{action}' style="display:inline">
            #{csrf_tag}
            <input type="hidden" name="_method" value="#{_method}" />
          </form>
          <a href='javascript: document.forms[\"#{id}\"].submit()' class="#{klass}">#{text}</a>
        eos
      end

      def delete_link(resource, options={})
        link_to('Delete', "/#{resource.class.to_s.underscore.pluralize}/#{resource.id}", options.merge(method: :delete))
      end

      def login(user)
        session[:user_id] = user.id
      end

      def authenticate!
        return nil if session[:user_id].nil?
        begin
          @user = User.find(session[:user_id])
        rescue ActiveRecord::RecordNotFound
          @user = nil
        end
        @user
      end

      def require_login!
        authenticate!
        redirect '/' if @user.nil?
      end

      def require_admin!
        authenticate!
        redirect '/' if @user.nil? || !@user.admin?
      end

      def require_super_admin!
        authenticate!
        redirect '/' if @user.nil? || !@user.super_admin?
      end


    end
  end
end
