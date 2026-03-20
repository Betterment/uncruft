# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uncruft::Deprecatable do
  let(:my_name) { "Jess" }

  subject { klass.new }

  describe '.deprecate_attribute' do
    let(:klass) do
      Class.new do
        include Uncruft::Deprecatable

        attr_accessor :first_name

        deprecate_attribute(:first_name, message: "Please stop using this attribute!")
      end
    end

    it 'reports the caller location, not deprecatable.rb, when setting' do
      warnings = []
      Uncruft.deprecator.behavior = ->(message, _callstack, _deprecation_horizon, _gem_name) {
        warnings << message
      }

      subject.first_name = my_name

      expect(warnings.length).to eq(1)
      expect(warnings.first).to include("deprecatable_spec.rb"), <<~MSG
        Expected the deprecation warning to reference the spec file as the caller,
        but got: #{warnings.first}
      MSG
      expect(warnings.first).not_to include("lib/uncruft/deprecatable.rb"), <<~MSG
        The deprecation warning should NOT reference deprecatable.rb as the caller,
        but got: #{warnings.first}
      MSG
    end

    it 'reports the caller location, not deprecatable.rb, when getting' do
      subject.instance_variable_set(:@first_name, my_name)

      warnings = []
      Uncruft.deprecator.behavior = ->(message, _callstack, _deprecation_horizon, _gem_name) {
        warnings << message
      }

      subject.first_name

      expect(warnings.length).to eq(1)
      expect(warnings.first).to include("deprecatable_spec.rb"), <<~MSG
        Expected the deprecation warning to reference the spec file as the caller,
        but got: #{warnings.first}
      MSG
      expect(warnings.first).not_to include("lib/uncruft/deprecatable.rb"), <<~MSG
        The deprecation warning should NOT reference deprecatable.rb as the caller,
        but got: #{warnings.first}
      MSG
    end
  end

  describe '.deprecate_method' do
    let(:klass) do
      Class.new do
        include Uncruft::Deprecatable

        def legacy_method
          "Hello Old World!"
        end

        deprecate_method(:legacy_method, message: "Please stop using this method!")
      end
    end

    it 'reports the caller location, not deprecatable.rb' do
      warnings = []
      Uncruft.deprecator.behavior = ->(message, _callstack, _deprecation_horizon, _gem_name) {
        warnings << message
      }

      result = subject.legacy_method

      expect(result).to eq("Hello Old World!")
      expect(warnings.length).to eq(1)
      expect(warnings.first).to include("deprecatable_spec.rb"), <<~MSG
        Expected the deprecation warning to reference the spec file as the caller,
        but got: #{warnings.first}
      MSG
      expect(warnings.first).not_to include("lib/uncruft/deprecatable.rb"), <<~MSG
        The deprecation warning should NOT reference deprecatable.rb as the caller,
        but got: #{warnings.first}
      MSG
    end

    context 'when the legacy method accepts arguments' do
      let(:klass) do
        Class.new do
          include Uncruft::Deprecatable

          def legacy_method(argument, keyword_argument:)
            <<~RESULT
              This is the argument: #{argument}
              This is the keyword_argument: #{keyword_argument}
              And here is the block: #{yield}
            RESULT
          end

          deprecate_method(:legacy_method, message: "Please stop using this method!")
        end
      end

      it 'forwards positional, keyword, and block arguments to the deprecated method' do
        warnings = []
        Uncruft.deprecator.behavior = ->(message, _callstack, _deprecation_horizon, _gem_name) {
          warnings << message
        }

        argument = "a positional argument"
        keyword_arg = "a keyword arg"

        result = subject.legacy_method(argument, keyword_argument: keyword_arg) { "returned from a block" }

        expect(result).to eq(<<~RESULT)
          This is the argument: a positional argument
          This is the keyword_argument: a keyword arg
          And here is the block: returned from a block
        RESULT
        expect(warnings.length).to eq(1)
        expect(warnings.first).to include("deprecatable_spec.rb"), <<~MSG
          Expected the deprecation warning to reference the spec file as the caller,
          but got: #{warnings.first}
        MSG
      end
    end
  end
end
