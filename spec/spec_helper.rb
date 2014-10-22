require 'rubygems'
require 'bundler/setup'
require 'nexus_client'
require 'fakefs/safe'
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.formatter = 'documentation'
  config.color = true
end
