# frozen_string_literal: true

require 'bundler'
Bundler.require :default, :development

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path('dummy/config/application', __dir__)
require 'support/rails_root'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.around(:all) do |example|
    Time.use_zone(ActiveSupport::TimeZone.all.first) do
      example.run
    end
  end
end
