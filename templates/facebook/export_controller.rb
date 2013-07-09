class ExportController < ApplicationController
  before_action :authenticate
  def index
    render 'export', layout: false
  end

private
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == 'USER_NAME' && password == 'PASSWORD'
    end
  end
end
