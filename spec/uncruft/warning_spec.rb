# frozen_string_literal: true

require 'spec_helper'

describe Uncruft::Warning do
  before do
    stub_const('Warning', Kernel) unless defined?(Warning)
  end

  it "doesn't block generic warnings" do
    expect(Uncruft.deprecator).not_to receive(:warn)
    warn
    warn('oh no, you should worry')
    Kernel.warn
    Kernel.warn('oh no, you should worry')
    Warning.warn('oh no, you should worry')
  end

  it "accepts kwargs from Kernel.warn" do # rubocop:disable RSpec/NoExpectationExample
    warn(uplevel: 1)
    warn('oh no, you should worry', uplevel: 1)
    Kernel.warn(uplevel: 1)
    Kernel.warn('oh no, you should worry', uplevel: 1)
  end

  context 'when warning includes the word "deprecation" or "deprecated"' do
    it 'treats it as a deprecation warning' do
      expect(Uncruft.deprecator).to receive(:warn).and_return('banana').exactly(6).times
      expect(warn('[dEpReCaTiOn] oh no, you should worry')).to eq 'banana'
      expect(Kernel.warn('[dEpReCaTiOn] oh no, you should worry')).to eq 'banana'
      expect(Warning.warn('[dEpReCaTiOn] oh no, you should worry')).to eq 'banana'
      expect(warn('oh no, this is DePrEcAtEd, so you should worry')).to eq 'banana'
      expect(Kernel.warn('oh no, this is DePrEcAtEd, so you should worry')).to eq 'banana'
      expect(Warning.warn('oh no, this is DePrEcAtEd, so you should worry')).to eq 'banana'
    end

    context 'and when warning includes caller info' do
      it 'strips out the path so that Uncruft.deprecator can append a new one' do
        path = caller_locations(0..0).first.path

        allow(Uncruft.deprecator).to receive(:warn).with('foo is deprecated!').and_return('hurray')
        expect(warn("#{path}: foo is deprecated!")).to eq('hurray')

        allow(Uncruft.deprecator).to receive(:warn).with('[DEPRECATION] bar is no more.').and_return('huzzah')
        expect(Kernel.warn("[DEPRECATION] bar is no more. #{path}:#{caller_locations(0..0).first.lineno}")).to eq('huzzah')

        allow(Uncruft.deprecator).to receive(:warn).with('Deprecation detected: banana --').and_return('we do our best...')
        expect(Warning.warn("Deprecation detected: banana -- #{caller(0..0).first}")).to eq('we do our best...')
      end

      it 'has a version-pinned entry for this Ruby/Rails combo' do
        expected = described_class.expected_internal_frames
        expect(expected).not_to be_nil,
          "No EXPECTED_INTERNAL_FRAMES entry for Ruby #{RUBY_VERSION} / Rails #{Rails::VERSION::STRING}. " \
          "Add one to Uncruft::Warning::EXPECTED_INTERNAL_FRAMES."
      end

      it 'only has expected internal frames at clocs[0] for this Ruby/Rails combo' do
        expected = described_class.expected_internal_frames
        pending 'No EXPECTED_INTERNAL_FRAMES entry for this combo' if expected.nil?

        caller_path = caller_locations(0..0).first.path

        received_frames = []
        allow(Uncruft.deprecator).to receive(:warn)
        original_find = described_class.instance_method(:find_caller_location)
        allow_any_instance_of(described_class).to receive(:find_caller_location).and_wrap_original do |_m, clocs| # rubocop:disable RSpec/AnyInstance
          received_frames << clocs.first
          original_find.bind_call(self, clocs)
        end

        warn("DEPRECATION WARNING: canary #{caller_path}")

        first_frame = received_frames.first
        is_expected_internal = expected.any? { |p| first_frame.path.include?(p) }
        is_caller = first_frame.path == caller_path

        expect(is_expected_internal || is_caller).to be(true),
          "Unexpected frame at clocs[0]: #{first_frame.path}:#{first_frame.lineno}. " \
          "Expected the caller (#{caller_path}) or one of #{expected.inspect}. " \
          "Ruby #{RUBY_VERSION} / Rails #{Rails::VERSION::STRING} may have changed caller frame layout — " \
          "update EXPECTED_INTERNAL_FRAMES in Uncruft::Warning."
      end

      it 'resolves the correct caller and strips its path from the message' do
        received_messages = []
        allow(Uncruft.deprecator).to receive(:warn) { |msg| received_messages << msg }

        path = caller_locations(0..0).first.path
        lineno = __LINE__ + 1
        warn("DEPRECATION WARNING: canary test! #{path}:#{lineno}")

        expect(received_messages.first).to include("canary test!")
        expect(received_messages.first).not_to include(path),
          "Expected caller path to be stripped, but got: #{received_messages.first}. " \
          "The caller frame offset for Ruby #{RUBY_VERSION} / Rails #{Rails::VERSION::STRING} may need " \
          "an entry in Uncruft::Warning::EXPECTED_INTERNAL_FRAMES."
      end
    end
  end
end
