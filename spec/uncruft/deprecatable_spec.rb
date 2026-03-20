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

  def capture_callstack
    callstacks = []
    Uncruft.deprecator.behavior = ->(_message, callstack, *) {
      callstacks << callstack
    }
    yield
    callstacks
  end

  describe '.deprecate_attribute' do
    let(:klass) do
      Class.new do
        include Uncruft::Deprecatable

        attr_accessor :first_name

        deprecate_attribute(:first_name, message: "Please stop using this attribute!")
      end
    end

    it 'does not include deprecatable.rb in the callstack when setting' do
      callstacks = capture_callstack { subject.first_name = my_name }

      expect(callstacks.length).to eq(1)
      paths = callstacks.first.map(&:path)
      expect(paths).not_to include(a_string_including("deprecatable.rb")),
        "Expected no frame to reference deprecatable.rb, but got:\n#{callstacks.first.map.with_index { |cl, i|
                                                                       "  FRAME #{i}: #{cl}"
                                                                     }.join("\n")}"
    end

    it 'does not include deprecatable.rb in the callstack when getting' do
      subject.instance_variable_set(:@first_name, my_name)

      callstacks = capture_callstack { subject.first_name }

      expect(callstacks.length).to eq(1)
      paths = callstacks.first.map(&:path)
      expect(paths).not_to include(a_string_including("deprecatable.rb")),
        "Expected no frame to reference deprecatable.rb, but got:\n#{callstacks.first.map.with_index { |cl, i|
                                                                       "  FRAME #{i}: #{cl}"
                                                                     }.join("\n")}"
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

    it 'does not include deprecatable.rb in the callstack' do
      callstacks = capture_callstack { subject.legacy_method }

      expect(callstacks.length).to eq(1)
      paths = callstacks.first.map(&:path)
      expect(paths).not_to include(a_string_including("deprecatable.rb")),
        "Expected no frame to reference deprecatable.rb, but got:\n#{callstacks.first.map.with_index { |cl, i|
                                                                       "  FRAME #{i}: #{cl}"
                                                                     }.join("\n")}"
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
        callstacks = capture_callstack do
          result = subject.legacy_method("a positional argument", keyword_argument: "a keyword arg") { "returned from a block" }

          expect(result).to eq(<<~RESULT)
            This is the argument: a positional argument
            This is the keyword_argument: a keyword arg
            And here is the block: returned from a block
          RESULT
        end

        expect(callstacks.length).to eq(1)
        paths = callstacks.first.map(&:path)
        expect(paths).not_to include(a_string_including("deprecatable.rb")),
          "Expected no frame to reference deprecatable.rb, but got:\n#{callstacks.first.map.with_index { |cl, i|
                                                                         "  FRAME #{i}: #{cl}"
                                                                       }.join("\n")}"
      end
    end
  end
end
