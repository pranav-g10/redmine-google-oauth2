require 'redmine'

require_dependency 'google_oauth2/hooks'

Redmine::Plugin.register :google_oauth2 do
  name 'Google Oauth2'
  author 'Pranav Chaturvedi'
  description 'Google Oauth2 plugin for Redmine'
  version '0.2'
  url 'https://github.com/pranav-g10/redmine-google-oauth2.git'
end
