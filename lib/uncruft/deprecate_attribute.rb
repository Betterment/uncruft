module Uncruft
  module DeprecateAttribute
    extend ActiveSupport::Concern

    module ClassMethods
      def deprecate_attribute(attribute, aliased_attribute: nil, message:)
        if aliased_attribute.present?
          alias_method aliased_attribute, attribute
          alias_method "#{aliased_attribute}=", "#{attribute}="
        end

        deprecated_methods = Module.new

        deprecated_methods.module_eval do
          define_method attribute do
            ActiveSupport::Deprecation.warn(message)
            super()
          end

          define_method "#{attribute}=" do |value|
            ActiveSupport::Deprecation.warn(message)
            super(value)
          end
        end

        prepend deprecated_methods
      end
    end
  end
end
