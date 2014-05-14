require 'rack/test'
ENV["RACK_ENV"] ||= 'test'

require 'bundler'
Bundler.require(:default, :test)

$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'web'

module RequestHelpers
  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  include Rack::Test::Methods
  config.include RequestHelpers

  config.after(:each) do
    $crux = false
  end
end
