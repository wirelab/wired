class FacebookController < ApplicationController
  protect_from_forgery except: [:tab]

  def campaign
    if is_facebook_crawler?
      render 'tab' # is FB crawler, dont redirect
    elsif is_mobile_request?
      render 'tab' # is mobile, dont redirect
    elsif is_facebook_app?
      render 'tab' # is app, dont redirect
    else
      @redirect_url =   "http://www.facebook.com/#{ENV['FB_PAGE_NAME']}/app_#{ENV['FB_APP_ID']}" # is desktop, redirect with js to tab
      render 'campaign', layout: false
    end
  end

  def tab
  end

  def canvas
    #canvas redirects to tab
    redirect_url = "http://www.facebook.com/#{ENV['FB_PAGE_NAME']}/app_#{ENV['FB_APP_ID']}"
    iframe_redirect_to redirect_url
  end

  private

  def is_facebook_crawler?
    user_agent.include?('facebookexternalhit')
  end

  def is_facebook_app?
    user_agent.include?('FBAN')
  end

  def user_agent
    request.env['HTTP_USER_AGENT']
  end
end
