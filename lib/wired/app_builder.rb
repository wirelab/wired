module Wired
  class AppBuilder < Rails::AppBuilder
    include Wired::Actions
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
  end
end
