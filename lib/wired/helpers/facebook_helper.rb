module Wired
  module FacebookHelper
    def facebook_setup
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
end
