require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Wired
  class AppGenerator < Rails::Generators::AppGenerator

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
    end

    def application_setup
      #additional invokes based on type of app we're generating
    end

    def remove_files_we_dont_need
      build :remove_public_index
      build :remove_rails_logo_image
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
      build :add_email_validator
    end

    def copy_miscellaneous_files
      say 'Copying miscellaneous support files'
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
    end

    def create_heroku_apps
      if options[:heroku]
        say 'Creating Heroku apps'
        build :create_heroku_apps
      end
    end

    def outro
      say 'Wired up!'
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
