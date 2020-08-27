lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "quickpay/api/version"

Gem::Specification.new do |spec|
  spec.name          = "quickpay-ruby-client"
  spec.version       = QuickPay::API::VERSION
  spec.authors       = ["QuickPay Developers"]
  spec.email         = ["support@quickpay.net"]

  spec.summary       = "Ruby client for QuickPay API"
  spec.description   = "Embed QuickPay's secure payments directly into your Ruby applications. Learn more at https://tech.quickpay.net"
  spec.homepage      = "https://github.com/QuickPay/quickpay-ruby-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest", "~> 5.11.3"
  spec.add_development_dependency "rake", "~> 12.3.2"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov", "~> 0.16.1"
  spec.add_development_dependency "simplecov-console", "~> 0.4.2"

  spec.add_development_dependency "json", "~> 2.3.0"

  spec.add_dependency "excon", "~> 0.71.0"
end
