# frozen_string_literal: true

module Uncruft
  module Warning
    DEPRECATION_PATTERN = /(deprecation|deprecated)/i

    def warn(*args, **kwargs)
      str = args[0]

      if str =~ DEPRECATION_PATTERN # rubocop:disable Performance/RegexpMatch
        cloc = find_caller_location(str, caller_locations(1..5))
        message = strip_caller_info(str, cloc).strip
        Uncruft.deprecator.warn(message)
      else
        super
      end
    end

    private

    def find_caller_location(str, clocs)
      clocs.detect do |cl|
        str.include?(cl.path) || str.include?(File.expand_path(cl.path))
      end || clocs.first
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
