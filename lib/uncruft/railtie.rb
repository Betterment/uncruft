require 'rails'

module Uncruft
  class Railtie < ::Rails::Railtie
    if Rails.env.test? || Rails.env.development?
      initializer 'uncruft.deprecation_handler', before: 'active_support.deprecation_behavior' do
        strategies = [config.active_support.deprecation].flatten(1).compact
        strategies.reject! { |s| s == :stderr }
        strategies.unshift(DeprecationHandler.new)
        config.active_support.deprecation = strategies
      end
    end
  end
end
