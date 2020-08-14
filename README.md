Uncruft
========

A library to assist with clearing out Rails deprecation warnings and upgrading Rails versions.

## Getting Started

Uncruft is designed to work with Rails 4.2 and higher.

### Installation

You can add Uncruft to your Gemfile with:

```
gem 'uncruft'
```

Then run `bundle install`.

### Deprecation Warnings

By default, deprecation warnings will cause your application to raise exceptions in `test` and `development` modes.

The exception message will include the original deprecation warning, plus a link to [our troubleshooting guide](https://github.com/Betterment/uncruft/blob/master/GUIDE.md), to assist with resolving deprecations as they are encountered.

## Recording Deprecations

When testing on a new Rails version for the first time, you will undoubtedly encounter many new warnings. As such, you can quickly record all existing deprecation warnings encountered during your test suite like so:

```bash
RECORD_DEPRECATIONS=1 rake
```

This will generate (or add to) an ignorefile of warnings at `config/deprecations.ignore`. Any warning in that file will be ignored when next encountered.

You can also incrementally add new warnings to the ignorefile as you encounter them:

```bash
RECORD_DEPRECATIONS=1 rspec path/to/my/failing/spec.rb
```

## Deprecating Attributes

If you would like to deprecate an attribute by aliasing it to a new attribute and applying an `ActiveSupport::Deprecation` warning on the deprecated attribute's getters and setters then look no further, we have a tool for that! Simply include `Uncruft::DeprecateAttribute` in your class, identify the attribute you would like deprecated, the attribute you would like aliased, and finally a message you would like applied to the deprecation warning.

```ruby
class Customer < ActiveRecord::Base
  include Uncruft::DeprecateAttribute

  attr_accessor :first_name

  deprecate_attribute(:first_name,
                      aliased_attribute: :legal_first_name,
                      message: "Please stop using first_name it is deprecated, please use legal_first_name instead!")
end
```

From there you can use Uncruft's deprecation recording tools to generate ingorefiles and manage your deprecation backlog in an organized manner.

## How to Contribute

We would love for you to contribute! Anything that benefits the majority of users—from a documentation fix to an entirely new feature—is encouraged.

Before diving in, [check our issue tracker](//github.com/Betterment/uncruft/issues) and consider creating a new issue to get early feedback on your proposed change.

### Suggested Workflow

* Fork the project and create a new branch for your contribution.
* Write your contribution (and any applicable test coverage).
* Make sure all tests pass (`bundle exec rake`).
* Submit a pull request.
