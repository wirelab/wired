require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Wired
  class AppGenerator < Rails::Generators::AppGenerator
    class_option 'skip-heroku', type: :boolean, default: false,
      desc: 'Skips the creation of the Heroku apps'

    class_option 'skip-github', type: :boolean, default: false,
      desc: 'Skips the creation of a Github repository'

    @@type = ""

    def finish_template
      invoke :wired_customization
      super
    end

    def wired_customization
      invoke :remove_files_we_dont_need
      invoke :customize_gemfile
      invoke :create_wired_views
      invoke :setup_database
      invoke :configure_app
      invoke :customize_error_pages
      invoke :remove_routes_comment_lines
      invoke :application_setup
      invoke :setup_git
      invoke :create_heroku_apps
      invoke :outro
      invoke :todo
    end

    def application_setup
      build :powder_setup

      choices = ["facebook", "teaser"]
      type = ask "Applicationtype? (#{choices.join ', '})"
      if choices.include? type
        @@type = type
        case type
        when "facebook"
          say "Setting up a Facebook application"
          invoke :facebook_setup
        when "teaser"
          say "Setting up a teaser with email registration"
          #invoke :teaser_setup
        end
      else
        say "Applicationtype should be one of: #{choices.join ', '}"
        invoke :application_setup
      end
    end

    def facebook_setup
      if @@type == "facebook"
        build :update_readme_for_facebook
        build :add_facebook_routes
        build :add_facebook_channel_file
        build :add_facebook_controllers
        build :add_facebook_stylesheets
        build :create_facebook_views
        build :add_cookie_fix
        build :add_javascripts_to_manifest
        build :generate_user_model
        build :run_migrations
      end
    end

    def teaser_setup
      if @@type == "teaser"
        say "There's no teaser setup yet"
      end
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
      bundle_command 'install --binstubs=bin/stubs'
    end

    def create_wired_views
      say 'Creating views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_application_layout
    end

    def setup_database
      say 'Setting up database'
      build :setup_database_config
      build :create_database
    end

    def configure_app
      say 'Configuring app'
      build :configure_time_zone
      build :set_asset_sync
      build :add_email_validator
    end

    def copy_miscellaneous_files
      build :copy_miscellaneous_files
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def setup_git
      say 'Setting up git'
      build :gitignore_files
      build :setup_git
      build :deploy_github unless options['skip-github']
    end

    def create_heroku_apps
      unless options['skip-heroku']
        say 'Creating Heroku apps'
        build :create_heroku_apps
      end
    end

    def outro
      say "     _  _  _  ___   ___  _    ___  ___ \n    | || || || - > | __>| |  / - \\| - >\n    |    || ||   \\ | __>| |_ | | || _ \\\n    |_/\\_||_||_|\\_\\|___>|___||_|_||___/\n"
    end

    def todo
      say "\n ------TODO------"
      case @@type
      when "facebook"
        say "* Create Facebook apps on https://developers.facebook.com"
        say "* Update FB_APP_ID env variables locally, on Heroku and in the readme"
      when "teaser"
        say "* Build entire app"
      end
    end

    def run_bundle
      # Let's not: We'll bundle manually at the right spot
    end

    protected

    def get_builder_class
      Wired::AppBuilder
    end
  end
end
