$:.unshift("/Library/RubyMotion/lib")

template = ENV['template'] || 'osx'
require "motion/project/template/#{template}"
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'MotionDataWrapperTest'

  if template == 'osx'
    app.sdk_version = '10.9'
    app.deployment_target = '10.9'
  else
    app.sdk_version = '7.1'
    app.deployment_target = '7.1'
  end
end
