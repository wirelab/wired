module Wired
  class AppBuilder < Rails::AppBuilder
    include Wired::Actions
    def remove_public_index
      remove_file 'public/index.html'
    end

    def remove_rails_logo_image
      remove_file 'app/assets/images/rails.png'
    end
  end
end
