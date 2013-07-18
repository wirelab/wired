module Wired
  class FacebookBuilder < AppBuilder
    def update_readme
      append_file "README.md", "* FB_APP_ID\n* FB_PAGE_NAME"
      facebook_readme =<<-FACEBOOK
# Facebook Apps
* [Production](https://developers.facebook.com/apps/FB_APP_ID) _FB_APP_ID_
* [Acceptance](https://developers.facebook.com/apps/) _FB_APP_ID_
* [Staging](https://developers.facebook.com/apps/FB_APP_ID) _FB_APP_ID_
* [Development](https://developers.facebook.com/apps/FB_APP_ID) _FB_APP_ID_

***

      FACEBOOK
      inject_into_file "README.md", facebook_readme, :before => "# Variables\n"
    end

    def add_routes
      facebook_routes =<<-ROUTES
  root :to => 'tab#home'
  post '/' => 'tab#home'

  get 'cookie' => 'sessions#cookie', as: 'cookie'
      ROUTES
      inject_into_file "config/routes.rb", facebook_routes, :before => "end"
    end

    def add_controllers
      copy_file 'facebook/tab_controller.rb', 'app/controllers/tab_controller.rb'
      copy_file 'facebook/export_controller.rb', 'app/controllers/export_controller.rb'
    end
    
    def add_stylesheets
      say 'Copy stylesheets'
      copy_file 'facebook/reset.css.scss', 'app/assets/stylesheets/resets.css.scss'
      copy_file 'facebook/_variables.css.scss', 'app/assets/stylesheets/_variables.css.scss'
    end

    def add_channel_file
      copy_file 'facebook/channel.html', 'public/channel.html'
    end

    def create_views
      empty_directory 'app/views/tab'
      home_page =<<-HOME
Home pagina, show fangate: <%= @show_fangate %>
      HOME
      File.open("app/views/tab/home.html.erb", 'w') { |file| file.write(home_page) }
    end

    def add_cookie_fix
      copy_file 'facebook/sessions_controller.rb', 'app/controllers/sessions_controller.rb'
      copy_file 'facebook/cookie.html.erb', 'app/views/sessions/cookie.html.erb'
      facebook_cookie_fix =<<-COOKIE_FIX
  helper_method :current_user
  before_filter :cookie_fix
  before_filter :add_global_javascript_variables  
  before_filter :set_origin
  before_filter :set_p3p

  def cookie
    # third party cookie fix
  end

  private
  def set_p3p  
    headers['P3P'] = 'CP="ALL DSP COR CURa ADMa DEVa OUR IND COM NAV"'  
  end 
  
  def set_origin
    response.headers["Access-Control-Allow-Origin: facebook.com"]
  end

  def current_user
    @current_user ||= User.find_by_fbid session[:fbid]
  end

  def cookie_fix
    cookies[:cookie_fix] = "cookie" #third party cookie fix
  end

  def add_global_javascript_variables
    Gon.global.facebook = { 'app_id' => ENV["FB_APP_ID"] }
    Gon.global.current_user = current_user.fbid if current_user.present?
  end
      COOKIE_FIX
      inject_into_file "app/controllers/application_controller.rb", facebook_cookie_fix, :before => "end"
      copy_file 'facebook/cookie_fix.js.coffee', 'app/assets/javascripts/cookie_fix.js.coffee'
      copy_file 'facebook/facebook.js.coffee', 'app/assets/javascripts/facebook.js.coffee'
    end

    def add_javascripts_to_manifest
      inject_into_file 'app/assets/javascripts/application.js', "//= require facebook\n", :before => '//= require_tree .'
      inject_into_file 'app/assets/javascripts/application.js', "//= require cookie_fix\n", :before => '//= require_tree .'
    end

    def generate_user_model
      run 'rails g model User name:string email:string fbid:string'
    end

    def run_migrations
      bundle_command 'exec rake db:migrate'
    end

    def powder_setup
      super
      copy_file 'facebook/env', '.env'
    end

    def create_initializers 
      copy_file 'facebook/default_headers.rb', 'config/initializers/default_headers.rb'
    end
  end
end
