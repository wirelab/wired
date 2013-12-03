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
  root :to => 'facebook#tab'
  post '/' => 'facebook#tab'

  get 'cookie' => 'sessions#cookie', as: 'cookie'
  post 'user' => 'users#create', as: 'user'
      ROUTES
      inject_into_file "config/routes.rb", facebook_routes, :before => "end"
    end

    def add_controllers
      copy_file 'facebook/facebook_controller.rb', 'app/controllers/facebook_controller.rb'
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
      empty_directory 'app/views/facebook'
      home_page =<<-HOME
Home pagina, show fangate: <%= @show_fangate %>, <a href="javascript: " data-fb-login rel="no-follow">Login</a>
      HOME
      File.open("app/views/facebook/tab.html.erb", 'w') { |file| file.write(home_page) }
    end

    def add_cookie_fix
      copy_file 'facebook/sessions_controller.rb', 'app/controllers/sessions_controller.rb'
      copy_file 'facebook/cookie.html.erb', 'app/views/sessions/cookie.html.erb'
      facebook_cookie_fix =<<-COOKIE_FIX
  include Mobylette::RespondToMobileRequests

  before_action :allow_iframe_requests
  helper_method :current_user
  before_action :cookie_fix
  before_action :add_global_javascript_variables
  before_action :set_origin
  before_action :set_p3p

  mobylette_config do |config|
    config[:skip_user_agents] = [:ipad]
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

  def allow_iframe_requests
    response.headers.delete 'X-Frame-Options'
  end

  def add_global_javascript_variables
    Gon.global.facebook = { 'app_id' => ENV["FB_APP_ID"] }
    Gon.global.current_user = current_user.fbid if current_user.present?
  end

  def iframe_redirect_to(path)
    render layout: false, inline: "<html><head>\\n<script type=\\"text/javascript\\">\\nwindow.top.location.href = '\#{path}';\\n</script>\\n<noscript>\\n<meta http-equiv=\\"refresh\\" content=\\"0;url=\#{path}\\" />\\n<meta http-equiv=\\"window-target\" content=\\"_top\\" />\\n</noscript>\\n</head></html>\\n"
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

    def generate_user
      user_token_method =<<-USER_TOKEN_METHOD
  def self.create_or_update_by_access_token(access_token)
    @graph = Koala::Facebook::API.new access_token
    profile = @graph.get_object 'me'
    user = where(fbid: profile['id']).first_or_initialize
    user.first_name = profile['first_name']
    user.last_name = "\#{profile['middle_name']} \#{profile['last_name']}".strip
    user.email = profile['email']
    user
  end
      USER_TOKEN_METHOD
      run 'rails g model User first_name last_name email fbid'
      inject_into_file "app/models/user.rb", user_token_method, :before => "end"
      copy_file 'facebook/users_controller.rb', 'app/controllers/users_controller.rb'
    end

    def run_migrations
      bundle_command 'exec rake db:migrate'
    end

    def powder_setup
      super
      copy_file 'facebook/env', '.env'
    end

    def create_initializers
      #do nothing
    end

    def add_gems
      gems =<<-GEMS
    gem 'facebook-signed-request'
      GEMS
      inject_into_file "Gemfile", gems, :before => "group :development, :test do"

      config = <<-RUBY
    Facebook::SignedRequest.secret = ENV['FB_APP_SECRET']
      RUBY
      inject_into_class 'config/application.rb', 'Application', config


    end
  end
end
