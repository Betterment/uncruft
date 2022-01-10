module Uncruft
  module Warning
    DEPRECATION_PATTERN = /(deprecation|deprecated)/i.freeze

    def warn(str, *args, **kwargs)
      if str =~ DEPRECATION_PATTERN # rubocop:disable Performance/RegexpMatch
        message = strip_caller_info(str, caller_locations(1..1).first).strip
        ActiveSupport::Deprecation.warn(message)
      elsif RUBY_VERSION < '2.7' && kwargs.empty?
        super(str, *args)
      else
        super
      end
    end

    private

    def strip_caller_info(str, cloc)
      str.sub(cloc.to_s, '') # try full caller information first
        .gsub(/#{cloc.path}(:#{cloc.lineno})?:?\s*/, '') # try path with optional line
    end
  end
end

if Rails.env.development? || Rails.env.test?
  if defined?(Warning)
    Warning.prepend(Uncruft::Warning)
    Warning.singleton_class.prepend(Uncruft::Warning)
  end
  Kernel.prepend(Uncruft::Warning)
  Kernel.singleton_class.prepend(Uncruft::Warning)
  Object.prepend(Uncruft::Warning)
  Object.singleton_class.prepend(Uncruft::Warning)
end
