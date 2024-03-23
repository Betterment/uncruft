# frozen_string_literal: true

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

      initializer "uncruft.deprecator" do |app|
        app.deprecators[:uncruft] = Uncruft.deprecator
      end
    end
  end
end
