# frozen_string_literal: true

module Uncruft
  module Deprecatable
    extend ActiveSupport::Concern

    module ClassMethods
      def deprecate_attribute(attribute, message:)
        deprecate_method attribute, message: message
        deprecate_method :"#{attribute}=", message: message
      end

      def deprecate_method(method, message:)
        prepended_method = Module.new

        prepended_method.module_eval do
          define_method method do |*args, &block|
            Uncruft.deprecator.warn(message)
            super(*args, &block)
          end
        end

        prepend prepended_method
      end
    end
  end
end
