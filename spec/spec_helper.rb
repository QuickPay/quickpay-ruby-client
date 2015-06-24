$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
Bundler.setup(:default, :development)
require 'quickpay/api/client'
require 'webmock/rspec'

QuickPay.logger.level = Logger::DEBUG
Dir.glob("./spec/support/**/*.rb").each{|f| require f }

RSpec.configure do |config|
  config.include(QuickPay::CommonHelpers)
  WebMock.disable_net_connect!
  WebMock.reset!
end