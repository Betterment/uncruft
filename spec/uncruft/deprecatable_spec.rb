# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uncruft::Deprecatable do
  let(:my_name) { "Jess" }

  subject { klass.new }

  around do |example|
    original_behavior = Uncruft.deprecator.behavior
    example.run
  ensure
    Uncruft.deprecator.behavior = original_behavior
  end

  describe '.deprecate_attribute' do
    let(:klass) do
      Class.new do
        include Uncruft::Deprecatable

        attr_accessor :first_name

        deprecate_attribute(:first_name, message: "Please stop using this attribute!")
      end
    end

    it 'reports the caller location, not deprecatable.rb, when setting' do
      callstacks = []
      Uncruft.deprecator.behavior = ->(_message, callstack, _deprecation_horizon, _gem_name) {
        callstacks << callstack
      }

      subject.first_name = my_name

      expect(callstacks.length).to eq(1)
      caller_file = callstacks.first.first.path
      expect(caller_file).not_to include("deprecatable.rb"), <<~MSG
        Expected the callstack to point to the caller, not deprecatable.rb.
        Got: #{callstacks.first.first}
      MSG
    end

    it 'reports the caller location, not deprecatable.rb, when getting' do
      subject.instance_variable_set(:@first_name, my_name)

      callstacks = []
      Uncruft.deprecator.behavior = ->(_message, callstack, _deprecation_horizon, _gem_name) {
        callstacks << callstack
      }

      subject.first_name

      expect(callstacks.length).to eq(1)
      caller_file = callstacks.first.first.path
      expect(caller_file).not_to include("deprecatable.rb"), <<~MSG
        Expected the callstack to point to the caller, not deprecatable.rb.
        Got: #{callstacks.first.first}
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
      callstacks = []
      Uncruft.deprecator.behavior = ->(_message, callstack, _deprecation_horizon, _gem_name) {
        callstacks << callstack
      }

      result = subject.legacy_method

      expect(result).to eq("Hello Old World!")
      expect(callstacks.length).to eq(1)
      caller_file = callstacks.first.first.path
      expect(caller_file).not_to include("deprecatable.rb"), <<~MSG
        Expected the callstack to point to the caller, not deprecatable.rb.
        Got: #{callstacks.first.first}
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
        callstacks = []
        Uncruft.deprecator.behavior = ->(_message, callstack, _deprecation_horizon, _gem_name) {
          callstacks << callstack
        }

        argument = "a positional argument"
        keyword_arg = "a keyword arg"

        result = subject.legacy_method(argument, keyword_argument: keyword_arg) { "returned from a block" }

        expect(result).to eq(<<~RESULT)
          This is the argument: a positional argument
          This is the keyword_argument: a keyword arg
          And here is the block: returned from a block
        RESULT
        expect(callstacks.length).to eq(1)
        caller_file = callstacks.first.first.path
        expect(caller_file).not_to include("deprecatable.rb"), <<~MSG
          Expected the callstack to point to the caller, not deprecatable.rb.
          Got: #{callstacks.first.first}
        MSG
      end
    end
  end
end
