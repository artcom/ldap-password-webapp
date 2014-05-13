source "https://rubygems.org"

gem 'sinatra', '~>1.4.4'
gem 'net-ldap'

gem 'byebug', :group => [:development, :test]

group :development do
  gem 'foreman'
  gem 'rerun'
end

group :test do
  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
  gem 'guard'
  #gem 'guard-minitest'
  gem 'rb-fsevent'
  gem 'growl_notify'
end
