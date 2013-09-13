module Wired
  class FacebookGenerator < AppGenerator
    def application_setup
      super
      build :update_readme
      build :add_routes
      build :add_channel_file
      build :add_controllers
      build :add_stylesheets
      build :create_views
      build :add_cookie_fix
      build :add_javascripts_to_manifest
      build :generate_user
      build :run_migrations
      build :create_initializers
    end

    def todo
      super
      say "* Create Facebook apps on https://developers.facebook.com"
      say "* Update FB_APP_ID env variables locally, on Heroku and in the readme"
      say "* Add app to wiredev (http://www.facebook.com/dialog/pagetab?app_id=FB_APP_ID&next=http%3A%2F%2Ffacebook.com)"
    end

    def customize_gemfile
      super
      build :add_gems
    end

    protected

    def get_builder_class
      FacebookBuilder
    end
  end
end
