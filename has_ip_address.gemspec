$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "has_ip_address/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "has_ip_address"
  s.version     = HasIPAddress::VERSION
  s.authors     = ["Matt Andre"]
  s.email       = ["matt@mattandre.me"]
  s.homepage    = "https://github.com/mattandre/has_ip_address"
  s.summary     = "Provides IP address support for Ruby on Rails"
  s.description = "Has IP Address is a helper to use IP addresses for model attributes in Ruby on Rails."
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "mysql2"
end
