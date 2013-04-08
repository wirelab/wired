class TabController < ApplicationController
  include Mobylette::RespondToMobileRequests

  def home 
    if params[:signed_request]
      redirect_to :fangate unless liked?
    else
      redirect_to "http://www.facebook.com/#{ENV['FB_PAGE_NAME']}/app_#{ENV['FB_APP_ID']}" unless is_mobile_view?
    end
  end

  def fangate
  end

  private
  def liked? 
    if params[:signed_request]
      encoded_request = params[:signed_request]
      json_request = decode_data(encoded_request)
      signed_request = JSON.parse(json_request)
      signed_request['page']['liked']
    else
      false
    end
  end

  def base64_url_decode str
    encoded_str = str.gsub('-','+').gsub('_','/')
    encoded_str += '=' while !(encoded_str.size % 4).zero?
    Base64.decode64(encoded_str)
  end

  def decode_data(signed_request)
    encoded_sig, payload = signed_request.split('.')
    data = base64_url_decode(payload)
  end
end
