module Wired
  class AppBuilder < Rails::AppBuilder
    include Wired::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end

    def remove_doc_folder
      remove_dir 'doc'
    end

    def remove_public_index
      remove_file 'public/index.html'
    end

    def remove_rails_logo_image
      remove_file 'app/assets/images/rails.png'
    end

    def remove_turbo_links
      replace_in_file "app/assets/javascripts/application.js", /\/\/= require turbolinks\n/, ''
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
      bundle_command 'exec rake db:create db:migrate RAILS_ENV=development'
      bundle_command 'exec rake db:create db:migrate RAILS_ENV=test'
    end

    def configure_server
      copy_file 'puma.rb', 'config/puma.rb'
      copy_file 'Procfile', 'Procfile'
    end

    def add_postgres_drop_override
      copy_file 'database.rake', 'lib/tasks/database.rake'
    end

    def create_partials_directory
      empty_directory 'app/views/application'
    end

    def create_shared_flashes
      copy_file '_flashes.html.erb',
        'app/views/application/_flashes.html.erb'
    end

    def create_shared_analytics
      copy_file '_analytics.html.erb',
        'app/views/application/_analytics.html.erb'
    end

    def create_application_layout
      template 'layout.html.erb.erb',
        'app/views/layouts/application.html.erb',
        :force => true
    end

    def add_stylesheets
      say 'Copy stylesheets'
      empty_directory "app/assets/stylesheets"
      directory "stylesheets", "app/assets/stylesheets", recursive: true
    end

    def remove_public_robots
      remove_file 'public/robots.txt'
    end

    def create_robots_txt
      say 'Copying robots.txt'
      copy_file 'robots/allow.txt.erb', 'app/views/robots/allow.txt.erb'
      copy_file 'robots/disallow.txt.erb', 'app/views/robots/disallow.txt.erb'
      copy_file 'robots/robots_controller.rb', 'app/controllers/robots_controller.rb'
    end

    def add_robots_routes
      robots_routes =<<-ROUTES
  get 'robots.txt' => 'robots#index'
      ROUTES
      inject_into_file "config/routes.rb", robots_routes, :before => "end"
    end

    def configure_time_zone
      config = <<-RUBY
    config.time_zone = 'Amsterdam'

      RUBY
      inject_into_class 'config/application.rb', 'Application', config
    end

    def set_asset_host
      config = <<-RUBY
  config.action_controller.asset_host = ENV["ASSET_HOST"]
      RUBY
      inject_into_file 'config/environments/production.rb', config, :after => "config.action_controller.asset_host = \"http://assets.example.com\"\n"
    end

    def set_action_mailer_config
      config = <<-RUBY
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: '#{app_powder_name}.dev' }
  config.action_mailer.asset_host = 'http://#{app_powder_name}.dev'
      RUBY
      inject_into_file 'config/environments/development.rb', config, before: "end\n"

      config = <<-RUBY
  config.action_mailer.default_url_options = { host: ENV["MAILER_HOST"] }
  config.action_mailer.asset_host = ENV["ASSET_HOST"]
      RUBY
      inject_into_file 'config/environments/production.rb', config, before: "end\n"
      copy_file 'email_sanitizer.rb', 'lib/email_sanitizer.rb'
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
        /Rails\.application\.routes\.draw do.*end/m,
        "Rails.application.routes.draw do\nend"
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
       empty_directory_with_keep_file dir
      end
    end

    def test_configuration_files
      copy_file 'spec/spec_helper.rb', 'spec/spec_helper.rb'
      copy_file 'spec/rails_helper.rb', 'spec/rails_helper.rb'
      copy_file 'spec/simplecov', '.simplecov'
      copy_file 'spec/travis.yml', 'travis.yml'
      copy_file 'spec/rspec', '.rspec'
    end

    def setup_git
      run 'git init'
      run "git add -A"
      run "git commit -am 'initial commit'"
      run "git checkout -b develop"
    end

    def deploy_github
      github_result = run "hub create -p wirelab/#{app_name_clean}"
      if github_result
        puts "Github repo wirelab/#{app_name_clean} created."
      else
        puts "Github creation wirelab/#{app_name_clean} failed."
        puts "Wired generation halted due to error."
        puts "You might want to remove the created Rails app and retry."
        exit
      end
      run "git push --all"
    end

    def powder_setup
      run 'powder link'
    end

    def create_heroku_apps
      %w(acceptance production).each do |env|
        heroku_name = (env == "production") ? app_name_clean : "#{app_name_clean}-acc"
        heroku_result = run "heroku apss:create #{heroku_name} --o wirelab -r #{env} --region eu"

        if heroku_result
          puts "Heroku apps:create #{heroku_name} created."
        else
          puts "Heroku apps:create #{heroku_name} failed."
          puts "Wired generation halted due to error."
          puts "You might want to remove the GitHub repo and previously created heroku apps and retry."
          exit
        end

        %w(papertrail mandrill newrelic memcachier).each do |addon|
          puts "heroku addons:create #{addon} --remote #{env}"
        end

        if env == 'production'
          run "heroku maintenance:on -r production"
          run "heroku config:set DISALLOW_SEARCH=false -r #{env}"
        else
          run "heroku config:set DISALLOW_SEARCH=true -r #{env}"
        end
      end
    end
  end
end
