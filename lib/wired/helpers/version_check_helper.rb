class VersionCheckHelper
  require 'httparty'
  require 'highline/import'
  require 'wired/version'

  def self.check_version!
    response = HTTParty.get 'https://rubygems.org/api/v1/gems/wired.json'
    latest_version = response.parsed_response['version']
    if latest_version != Wired::VERSION
      exit unless agree("You are using an outdated version of Wired and will probably break stuff, are you sure you want to continue?")
    end
  end
end
