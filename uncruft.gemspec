# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'uncruft/version'

Gem::Specification.new do |s|
  s.name        = 'uncruft'
  s.version     = Uncruft::VERSION
  s.authors     = ['Nathan Griffith', 'Chris Zega']
  s.email       = ['nathan@betterment.com']
  s.homepage    = 'https://github.com/Betterment/uncruft'
  s.summary     = 'A library to assist with Rails upgrades'
  s.description = 'A library to assist with clearing out Rails deprecation warnings and upgrading Rails versions'
  s.license     = 'MIT'
  s.metadata = {
    'rubygems_mfa_required' => 'true',
  }

  s.files = Dir['{lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']

  s.required_ruby_version = '>= 3.0'

  s.add_dependency 'railties', '>= 6.1.0'
end
