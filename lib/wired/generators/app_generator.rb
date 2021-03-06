require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Wired
  class AppGenerator < Rails::Generators::AppGenerator
    class_option 'with-heroku', type: :boolean, default: false,
      desc: 'Adds the creation of the Heroku apps'

    class_option 'with-github', type: :boolean, default: false,
      desc: 'Adds the creation of a Github repository'

    def finish_template
      # Generate a normale rails app. After that AppBase invokes finish_template
      invoke :wired_customization
      super # invokes leftover
    end

    def app_name_clean
      clean = app_name.parameterize
      clean = clean.gsub '_', '-'
      clean = "wl-#{clean}" if clean.length < 3
      clean = clean[0..19] if clean.length > 20
      clean
    end

    def app_powder_name
      clean = app_name.parameterize
      clean = clean.gsub '_', '-'
      clean
    end

    def wired_customization
      invoke :remove_files_we_dont_need
      invoke :customize_gemfile
      invoke :create_wired_views
      invoke :setup_test
      invoke :bundle_gems
      invoke :setup_database
      invoke :configure_app
      invoke :customize_error_pages
      invoke :remove_routes_comment_lines
      invoke :application_setup
    end

    def leftover
      invoke :setup_git
      invoke :create_heroku_apps
      invoke :outro
      invoke :todo
    end

    def application_setup
      if run('which powder')
        build :powder_setup
      else
        say 'Powder not found. Skip linking app.'
      end
      build :create_robots_txt
      build :remove_public_robots
      build :add_robots_routes

      build :add_stylesheets
    end

    def remove_files_we_dont_need
      build :remove_doc_folder
      build :remove_public_index
      build :remove_rails_logo_image
      build :remove_turbo_links
    end

    def customize_gemfile
      build :replace_gemfile
      build :set_ruby_to_version_being_used
    end

    def bundle_gems
      say 'Bundling gems'
      bundle_command 'install'
      bundle_command 'exec rails generate simple_form:install'
    end

    def create_wired_views
      say 'Creating views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_shared_analytics
      build :create_application_layout
    end

    def setup_database
      say 'Setting up database'
      build :setup_database_config
      build :create_database
      build :add_postgres_drop_override
    end

    def configure_app
      say 'Configuring app'
      build :configure_time_zone
      build :set_asset_host
      build :set_action_mailer_config
      build :add_email_validator
      build :configure_server
    end

    def copy_miscellaneous_files
      build :copy_miscellaneous_files
    end

    def setup_robots_txt

    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def setup_test
      say 'Setting up test environment'
      build :test_configuration_files
    end

    def setup_git
      say 'Setting up git'
      build :gitignore_files
      build :setup_git
      build :deploy_github if options['with-github']
    end

    def create_heroku_apps
      if options['with-heroku']
        say 'Creating Heroku apps'
        build :create_heroku_apps
      end
    end

    def outro
      say "     _  _  _  ___   ___  _    ___  ___ \n    | || || || - > | __>| |  / - \\| - >\n    |    || ||   \\ | __>| |_ | | || _ \\\n    |_/\\_||_||_|\\_\\|___>|___||_|_||___/\n"
    end

    def todo
      # say "\n ------TODO------"
    end

    def bundle_install?
      # Let's not: We'll bundle manually at the right spot
      false
    end

    protected

    def get_builder_class
      AppBuilder
    end
  end
end
