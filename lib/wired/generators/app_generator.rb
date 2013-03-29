require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Wired
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, :type => :string, :aliases => '-d', :default => 'postgresql',
      :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"

    class_option :skip_test_unit, :type => :boolean, :aliases => '-T', :default => true,
      :desc => 'Skip Test::Unit files'

    def finish_template
      invoke :wired_customization
      super
    end

    def wired_customization
      invoke :remove_files_we_dont_need
      invoke :customize_gemfile
      invoke :outro
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

    def using_active_record?
      !options[:skip_active_record]
    end
  end
end
