#!/usr/bin/env rake
require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks'
require 'shellwords'

ext_name = 'skype_api'

CLEAN.include Dir.glob("ext/#{ext_name}/*{.o,.log}")
CLEAN.include "ext/#{ext_name}/Makefile"
CLOBBER.include "ext/#{ext_name}/#{ext_name}.bundle"
CLOBBER.include "lib/#{ext_name}.bundle"

file "lib/#{ext_name}.bundle" =>
  Dir.glob("ext/#{ext_name}/*{.rb,.m,.h}") do
  Dir.chdir("ext/#{ext_name}") do
    ruby "extconf.rb"
    sh "make"
  end
  cp "ext/#{ext_name}/#{ext_name}.bundle", "lib/"
end

task :spec => "lib/#{ext_name}.bundle"

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec
