# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'motion_data_wrapper/version'

Gem::Specification.new do |s|
  s.name          = "motion_data_wrapper"
  s.version       = MotionDataWrapper::VERSION
  s.authors       = ["Matt Brewer"]
  s.email         = ["matt.brewer@me.com"]
  s.homepage      = "https://github.com/macfanatic/motion_data_wrapper"
  s.summary       = "Provides an easy ActiveRecord-like interface to CoreData"
  s.description   = "Forked from the mattgreen/nitron gem, this provides an intuitive way to query and persist data in CoreData, while letting you use the powerful Xcode data modeler and versioning tools for schema definitions."
  s.license       = "MIT"

  s.files         = Dir["lib/**/*"] + ["README.md"]
  s.test_files    = Dir["spec/**/*"]
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']

  s.add_dependency "bubble-wrap", "~> 1.4.0"

  s.add_development_dependency "rake"
end
