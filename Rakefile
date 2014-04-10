# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'coder_crash'
  app.deployment_target = '6.0'

  app.vendor_project('objc', :static,
    :cflags => '-fobjc-arc',
    :source_files => ['archive.m', 'archive.h'])
end
