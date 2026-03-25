# frozen_string_literal: true

module Uncruft
  module Warning
    DEPRECATION_PATTERN = /(deprecation|deprecated)/i

    # Version-pinned: which internal frames are allowed at clocs[0].
    # Empty array = no internal frames expected. Missing key = unknown combo.
    EXPECTED_INTERNAL_FRAMES = {
      ["3.2", "7.2"] => [],
      ["3.2", "8.0"] => [],
      ["3.3", "7.2"] => [],
      ["3.3", "8.0"] => [],
      ["3.4", "7.2"] => [],
      ["3.4", "8.0"] => ['prism/polyfill/warn.rb'],
    }.freeze

    def self.expected_internal_frames
      ruby_minor = RUBY_VERSION.split('.')[0..1].join('.')
      rails_minor = Rails::VERSION::STRING.split('.')[0..1].join('.')
      EXPECTED_INTERNAL_FRAMES[[ruby_minor, rails_minor]]
    end

    def warn(*args, **kwargs)
      str = args[0]

      if str =~ DEPRECATION_PATTERN # rubocop:disable Performance/RegexpMatch
        cloc = find_caller_location(caller_locations(1..5))
        message = strip_caller_info(str, cloc).strip
        Uncruft.deprecator.warn(message)
      else
        super
      end
    end

    private

    def find_caller_location(clocs)
      first = clocs.first
      expected = Uncruft::Warning.expected_internal_frames
      if first && expected&.any? { |pattern| first.path.include?(pattern) }
        clocs[1] || first
      else
        first
      end
    end

    def strip_caller_info(str, cloc)
      str.sub(cloc.to_s, '') # try full caller information first
        .gsub(/#{cloc.path}(:#{cloc.lineno})?:?\s*/, '') # try path with optional line
    end
  end
end

if Rails.env.local?
  if defined?(Warning)
    Warning.prepend(Uncruft::Warning)
    Warning.singleton_class.prepend(Uncruft::Warning)
  end
  Kernel.prepend(Uncruft::Warning)
  Kernel.singleton_class.prepend(Uncruft::Warning)
  Object.prepend(Uncruft::Warning)
  Object.singleton_class.prepend(Uncruft::Warning)
end
