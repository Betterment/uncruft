require 'uncruft/version'
require 'uncruft/railtie'
require 'uncruft/deprecation_handler'
require 'uncruft/deprecate_deprecatable'
require 'uncruft/warning'

module Uncruft
  class << self
    # http://api.rubyonrails.org/classes/ActiveModel/Type/Boolean.html
    FALSE_VALUES = [false, 0, "0", "f", "F", "false", "FALSE", "off", "OFF"].to_set

    def record_deprecations?
      ENV['RECORD_DEPRECATIONS'].presence && !FALSE_VALUES.include?(ENV['RECORD_DEPRECATIONS'])
    end

    def ignorefile_path
      ENV['UNCRUFT_IGNOREFILE_PATH'] || Rails.root.join('config', 'deprecations.ignore')
    end
  end
end
