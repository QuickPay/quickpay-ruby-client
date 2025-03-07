lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "quickpay/api/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 2.5.0" # rubocop:disable Gemspec/RequiredRubyVersion

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

  spec.add_dependency "json", "~> 2", ">= 2.5"
end
