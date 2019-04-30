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

## Whitelisting Deprecations

When testing on a new Rails version for the first time, you will undoubtedly encounter many new warnings. As such, you can quickly whitelist all existing deprecation warnings encountered during your test suite like so:

```bash
WHITELIST_DEPRECATIONS=1 rake
```

You can also incrementally add new warnings to the whitelist as you encounter them:

```bash
WHITELIST_DEPRECATIONS=1 rspec path/to/my/failing/spec.rb
```

This will generate (or add to) a whitelist of warnings at `config/deprecations.ignore`. Any warning in that file will be ignored when next encountered.

## How to Contribute

We would love for you to contribute! Anything that benefits the majority of users—from a documentation fix to an entirely new feature—is encouraged.

Before diving in, [check our issue tracker](//github.com/Betterment/uncruft/issues) and consider creating a new issue to get early feedback on your proposed change.

### Suggested Workflow

* Fork the project and create a new branch for your contribution.
* Write your contribution (and any applicable test coverage).
* Make sure all tests pass (`bundle exec rake`).
* Submit a pull request.
