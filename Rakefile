begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

task(:default).clear

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

if ENV['APPRAISAL_INITIALIZED'] || ENV['CI']
  task default: %i(rubocop spec)
else
  require 'appraisal'
  Appraisal::Task.new
  task default: :appraisal
end
