module Uncruft
  module DeprecateMethod
    extend ActiveSupport::Concern

    module ClassMethods
      def deprecate_method(method, message:)
        deprecated_methods = Module.new

        deprecated_methods.module_eval do
          define_method method do
            ActiveSupport::Deprecation.warn(message)
            super()
          end

          define_method "#{method}=" do |value|
            ActiveSupport::Deprecation.warn(message)
            super(value)
          end
        end

        prepend deprecated_methods
      end
    end
  end
end
