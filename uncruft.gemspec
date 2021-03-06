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

  s.files = Dir['{lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'railties', '>= 4.2.0'

  s.add_development_dependency 'appraisal', '~> 2.2.0'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'rspec', '~> 3.7.0'
  s.add_development_dependency 'rubocop-betterment'
  s.add_development_dependency 'timecop', '~> 0.9.1'
end
