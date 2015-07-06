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
  root to: 'facebook#campaign'
  get '/', to: 'facebook#campaign'
  match 'tab', to: 'facebook#tab', as: 'tab', via: [:get, :post]
  get 'cookie', to: 'sessions#cookie', as: 'cookie'
  get 'robots.txt', to: 'robots#index'
      ROUTES
      inject_into_file "config/routes.rb", facebook_routes, :before => "end"
    end

    def create_application_layout
      template 'facebook/views/layout.html.erb.erb',
        'app/views/layouts/application.html.erb',
        :force => true
    end

    def add_controllers
      copy_file 'facebook/facebook_controller.rb', 'app/controllers/facebook_controller.rb'
    end

    def add_channel_file
      copy_file 'facebook/views/channel.html', 'public/channel.html'
    end

    def create_views
      empty_directory 'app/views/facebook'
      home_page =<<-HOME
Home pagina<a href="javascript: " data-fb-login rel="no-follow">Login</a>
      HOME
      File.open("app/views/facebook/tab.html.erb", 'w') { |file| file.write(home_page) }

      copy_file 'facebook/views/campaign.html.erb', 'app/views/facebook/campaign.html.erb'
      copy_file 'facebook/views/campaign.html.erb', 'app/views/facebook/campaign.html.erb'
    end

    def add_cookie_fix
      copy_file 'facebook/sessions_controller.rb', 'app/controllers/sessions_controller.rb'
      copy_file 'facebook/views/cookie.html.erb', 'app/views/sessions/cookie.html.erb'
      facebook_cookie_fix =<<-COOKIE_FIX
  include Mobylette::RespondToMobileRequests

  before_action :allow_iframe_requests
  before_action :cookie_fix
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

  def cookie_fix
    cookies[:cookie_fix] = "cookie" #third party cookie fix
  end

  def allow_iframe_requests
    response.headers.delete 'X-Frame-Options'
  end

  def iframe_redirect_to(path)
    render layout: false, inline: "<html><head>\\n<script type=\\"text/javascript\\">\\nwindow.top.location.href = '\#{path}';\\n</script>\\n<noscript>\\n<meta http-equiv=\\"refresh\\" content=\\"0;url=\#{path}\\" />\\n<meta http-equiv=\\"window-target\\" content=\\"_top\\" />\\n</noscript>\\n</head></html>\\n"
  end

      COOKIE_FIX
      inject_into_file "app/controllers/application_controller.rb", facebook_cookie_fix, :before => "end"
      copy_file 'facebook/cookie_fix.js.coffee', 'app/assets/javascripts/cookie_fix.coffee'
      copy_file 'facebook/facebook.js.coffee', 'app/assets/javascripts/facebook.coffee'
    end

    def add_javascripts_to_manifest
      inject_into_file 'app/assets/javascripts/application.js', "//= require facebook\n", :before => '//= require_tree .'
      inject_into_file 'app/assets/javascripts/application.js', "//= require cookie_fix\n", :before => '//= require_tree .'
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
gem 'koala'
gem 'mobylette', github: 'equinux/mobylette', tag: '628fd15f9374cb8f3922682b1351c185393faa7d'
      GEMS
      inject_into_file "Gemfile", gems, :before => "group :development, :test do"
    end
  end
end
