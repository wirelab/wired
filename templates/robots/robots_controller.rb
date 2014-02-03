class RobotsController < ActionController::Base
  layout false
  def index
    if ENV['DISALLOW_SEARCH'].present? && ENV['DISALLOW_SEARCH'].downcase == 'true'
      #test server
      render 'disallow.txt', content_type: "text/plain"
    else
      #live server
      render 'allow.txt', content_type: "text/plain"
    end
  end
end
