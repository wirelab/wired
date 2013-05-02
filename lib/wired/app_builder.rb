module Wired
  class AppBuilder < Rails::AppBuilder
    include Wired::Actions

    def readme
      template 'README.md.erb', 'README.md'
      remove_dir 'doc'
    end

    def remove_public_index
      remove_file 'public/index.html'
    end

    def remove_rails_logo_image
      remove_file 'app/assets/images/rails.png'
    end

    def replace_gemfile
      remove_file 'Gemfile'
      copy_file 'Gemfile_clean', 'Gemfile'
    end

    def set_ruby_to_version_being_used
      inject_into_file 'Gemfile', "\n\nruby '#{RUBY_VERSION}'",
        after: /source 'https:\/\/rubygems.org'/
    end

    def setup_database_config 
      template 'database.yml.erb', 'config/database.yml', :force => true
    end

    def create_database
      bundle_command 'exec rake db:create'
    end

    def create_partials_directory
      empty_directory 'app/views/application'
    end

    def create_shared_flashes
      copy_file '_flashes.html.erb',
        'app/views/application/_flashes.html.erb'
    end

    def create_application_layout
      template 'layout.html.erb.erb',
        'app/views/layouts/application.html.erb',
        :force => true
    end

    def configure_time_zone
      config = <<-RUBY
    config.time_zone = 'Amsterdam'

      RUBY
      inject_into_class 'config/application.rb', 'Application', config
    end

    def customize_error_pages
      meta_tags =<<-EOS
  <meta charset='utf-8' />
      EOS

      %w(500 404 422).each do |page|
        inject_into_file "public/#{page}.html", meta_tags, :after => "<head>\n"
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb',
        /Application\.routes\.draw do.*end/m,
        "Application.routes.draw do\nend"
    end

    def gitignore_files
      concat_file 'wired_gitignore', '.gitignore'
      [
        'app/models',
        'app/assets/images',
        'app/views/pages',
        'db/migrate',
        'log',
        'spec/support',
        'spec/lib',
        'spec/models',
        'spec/views',
        'spec/controllers',
        'spec/helpers',
        'spec/support/matchers',
        'spec/support/mixins',
        'spec/support/shared_examples'
      ].each do |dir|
        empty_directory_with_gitkeep dir
      end
    end

    def setup_git 
      run 'git init'
      run "hub create -p wirelab/#{app_name}"
      run "git add ."
      run "git commit -m 'initial commit'"
      run "git checkout -b develop"
      run "git push --all"
    end

    def powder_setup
      run 'powder link'
      copy_file 'facebook/powenv', '.powenv'
    end

    def update_readme_for_facebook 
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

    def add_facebook_routes
      facebook_routes =<<-ROUTES
  root :to => 'tab#home'
  match "fangate" => "tab#fangate", as: 'fangate'
 
  #safari cookie fix
  get 'cookie' => 'application#cookie', as: 'cookie'

  #admin
  get 'admin/export' => 'admin#export'
      ROUTES
      inject_into_file "config/routes.rb", facebook_routes, :before => "end"
    end

    def add_facebook_controllers
      copy_file 'facebook/tab_controller.rb', 'app/controllers/tab_controller.rb'
      copy_file 'facebook/export_controller.rb', 'app/controllers/export_controller.rb'
    end

    def create_facebook_views
      empty_directory 'app/views/tab'
      %w(fangate home).each do |page|
        File.open("app/views/tab/#{page}.html.erb", 'w') { |file| file.write(page) }
      end
    end

    def add_safari_cookie_fix
      facebook_cookie_fix =<<-COOKIE_FIX
  helper_method :current_user
  before_filter :safari_cookie_fix
  before_filter :add_global_javascript_variables  
  
  def cookie
    #safari third party cookie fix
  end

  private

  def current_user
    @current_user ||= User.by_fbid session[:fbid]
  end

  def safari_cookie_fix
    cookies[:safari_cookie_fix] = "cookie" #safari third party cookie fix
  end

  def add_global_javascript_variables
    Gon.global.facebook = { 'app_id' => ENV["FB_APP_ID"] }
    Gon.global.current_user = current_user
  end
      COOKIE_FIX
      inject_into_file "app/controllers/application_controller.rb", facebook_cookie_fix, :before => "end"
      copy_file 'facebook/safari-cookie-fix.js.coffee', 'app/assets/javascripts/safari-cookie-fix.js.coffee'
    end

    def create_heroku_apps
      %w(staging acceptance production).each do |env|
        if env == 'production'
          run "heroku create #{app_name} --remote=#{env}"
        else
          run "heroku create #{app_name}-#{env} --remote=#{env}"
        end
        run "heroku sharing:add algemeen@wirelab.nl --remote=#{env}"
        run "heroku sharing:transfer algemeen@wirelab.nl --remote=#{env}"
      end
    end
  end
end
