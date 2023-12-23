require 'active_support'
require 'active_support/time'

require 'uncruft/version'
require 'uncruft/deprecator'
require 'uncruft/railtie'
require 'uncruft/deprecation_handler'
require 'uncruft/deprecatable'
require 'uncruft/warning'

module Uncruft
  class << self
    # http://api.rubyonrails.org/classes/ActiveModel/Type/Boolean.html
    FALSE_VALUES = [false, 0, "0", "f", "F", "false", "FALSE", "off", "OFF"].to_set

    def record_deprecations?
      ENV['RECORD_DEPRECATIONS'].presence && !ENV['RECORD_DEPRECATIONS'].in?(FALSE_VALUES)
    end

    def ignorefile_path
      ENV['UNCRUFT_IGNOREFILE_PATH'] || Rails.root.join('config/deprecations.ignore')
    end
  end
end
