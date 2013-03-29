#rails new foo --skip-bundle -b app_builder.rb
class AppBuilder < Rails::AppBuilder
  include Actions
  
  def initialize(generator)
    super(generator)

    at_exit do
      postprocess
    end
  end

  def readme
    create_file "README.md", "TODO"
  end

  def test
    gem_group :test, :development do
      gem 'rspec-rails'
    end
  end

  def leftovers
    remove_file "public/index.html"
    remove_file "public/images/rails.png"

    if yes? "Do you want to support Mobile?"
      #setup mobile redirect to seperate page
    end

    if yes? "Are you going to send emails?"
      #setup sendgrid
    end

    setup_database

    git :init
    git add: ".", commit: "-m 'initial commit'"
  end

  def setup_database
    #run "cp config/database.yml config/database.example"
    template 'postgresql_database.yml.erb', 'config/database.yml',
      :force => true
  end

  def create_database
    bundle_command 'exec rake db:create'
  end

  def generate_models
    #user
    generate "model", "User"
  end

  def postprocess
    generate 'rspec:install'
  end

  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<-FILE
      module #{class_name}Helper
        attr_reader :#{plural_name}, :#{plural_name.singularize}
      end
    FILE
  end


  
end