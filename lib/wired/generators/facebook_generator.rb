module Wired
  class FacebookGenerator < AppGenerator
    def application_setup
      super
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

    def todo
      super
      say "* Create Facebook apps on https://developers.facebook.com"
      say "* Update FB_APP_ID env variables locally, on Heroku and in the readme"
    end

    protected

    def get_builder_class
      FacebookBuilder
    end
  end
end
