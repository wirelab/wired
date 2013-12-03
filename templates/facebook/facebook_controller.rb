class FacebookController < ApplicationController
  protect_from_forgery except: [:tab]

  def tab
    request = Facebook::SignedRequest.new params[:signed_request]

    if request.data.present?
      session[:fbid] = request.data[:user_id] if request.data[:user_id].present?
      @show_fangate = !request.data[:page][:liked]
    else
      @show_fangate = false
      redirect_to "http://www.facebook.com/#{ENV['FB_PAGE_NAME']}/app_#{ENV['FB_APP_ID']}" unless is_mobile_request?
    end
  end

  def canvas
    #canvas redirects to tab
    redirect_url = "http://www.facebook.com/#{ENV['FB_PAGE_NAME']}/app_#{ENV['FB_APP_ID']}"
    iframe_redirect_to redirect_url
  end
end
