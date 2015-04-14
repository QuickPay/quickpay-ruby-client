$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
Bundler.setup(:default, :development)
require 'quickpay'
require 'webmock/rspec'

Quickpay.logger.level = Logger::DEBUG
Dir.glob("./spec/support/**/*.rb").each{|f| require f }

RSpec.configure do |config|
  config.include(Quickpay::CommonHelpers)
  WebMock.disable_net_connect!
  WebMock.reset!
end