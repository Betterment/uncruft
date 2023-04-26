# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project aims to adhere to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added <!-- for new features. -->
### Changed <!-- for changes in existing functionality. -->
### Deprecated <!-- for soon-to-be removed features. -->
### Removed <!-- for now removed features. -->
### Fixed <!-- for any bug fixes. -->

## [0.3.1] - 2023-04-26
### Fixed
- Some ruby warnings included gem paths that weren't being normalized by the
  regex matchers
- Some ruby warnings included both gem paths and absolute paths and we were
  only normalizing one but not the other
- Fixed some rubocop linter rules

## [0.3.0] - 2021-12-16
### Added
- Official support for Ruby 2.7 and 3.0
- Official support for Rails 6.2 and 7.0
### Fixed
- An issue with `warn(...)` and Ruby 3.0's keyword arguments
- Miscellaneous test/linter issues affecting just the gem's test suite
### Removed
- Drops support for Rails < 5.2
- Drops support for Ruby < 2.6

## [0.2.1] - 2021-09-03
### Changed
- Changes the default CI build branch to `main`, and updates links in GUIDE.md
### Added
- Adds a "heads up" message to the top of the GUIDE.md indicating that you
  should check what version of the gem you are running before following the
  instructions.

## [0.2.0] - 2020-10-29
### Added
- This release adds a new `deprecate_attribute` helper! To get started, simply
  include `Uncruft::Deprecatable` in your class, and then supply an attribute
  name and deprecation message, like so: `deprecate_attribute :old_name,
  message: "Please stop using old_name"`. Note that this will deprecate both
  the getter and the setter. To apply this to just a single method, use
  `deprecate_method`.
- Special thanks to @yieldjessyield for the contribution!

## [0.1.0] - 2020-01-21
### Changed
- This release updates variable names and documentation to use more inclusive
  language. The ENV var for adding deprecations to the ignorefile is now
  `RECORD_DEPRECATIONS=1`.

## [0.0.2] - 2019-06-07
### Fixed
- Fixes an argument arity issue with `Kernal.warn` on newer rubies.

## [0.0.1] - 2019-04-30
### Added
- Initial open source commit! This gem has been used internally at Betterment
  for almost a year, and we've decided to open source it!

[0.3.1]: https://github.com/betterment/uncruft/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/betterment/uncruft/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/betterment/uncruft/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/betterment/uncruft/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/betterment/uncruft/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/betterment/uncruft/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/betterment/uncruft/releases/tag/v0.0.1
