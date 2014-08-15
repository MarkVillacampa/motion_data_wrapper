$:.unshift("/Library/RubyMotion/lib")

template = ENV['template'] || 'osx'
require "motion/project/template/#{template}"
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'MotionDataWrapperTest'
end
