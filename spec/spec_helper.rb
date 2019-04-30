require 'bundler'
Bundler.require :default, :development

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path('dummy/config/application', __dir__)
require 'support/rails_root'

Time.zone = ActiveSupport::TimeZone.all.first

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = 'spec/examples.txt'
end
