# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quickpay/version'

Gem::Specification.new do |spec|
  spec.name          = "quickpay-ruby-client"
  spec.version       = QuickPay::VERSION
  spec.authors       = ["QuickPay Developers"]
  spec.email         = ["support@quickpay.net"]
  
  spec.summary       = "Ruby client for QuickPay API"
  spec.description   = "Embed QuickPay's secure payments directly into your Ruby applications. more at https://tech.quickpay.net"
  spec.homepage      = "https://github.com/QuickPay/quickpay-ruby-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "webmock"
  
  spec.add_dependency "httparty", "~> 0.13"
    
end
