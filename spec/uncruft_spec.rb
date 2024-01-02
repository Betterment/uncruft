# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uncruft do
  describe '.record_deprecations?' do
    it 'handles common truthy and falsy values' do
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('1')
      expect(described_class.record_deprecations?).to be true
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('t')
      expect(described_class.record_deprecations?).to be true
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('T')
      expect(described_class.record_deprecations?).to be true
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('true')
      expect(described_class.record_deprecations?).to be true
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('TRUE')
      expect(described_class.record_deprecations?).to be true
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('0')
      expect(described_class.record_deprecations?).to be false
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('f')
      expect(described_class.record_deprecations?).to be false
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('F')
      expect(described_class.record_deprecations?).to be false
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('false')
      expect(described_class.record_deprecations?).to be false
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('FALSE')
      expect(described_class.record_deprecations?).to be false
      allow(ENV).to receive(:[]).with('RECORD_DEPRECATIONS').and_return('')
      expect(described_class.record_deprecations?).to be_nil
    end
  end

  describe '.ignorefile_path' do
    it 'uses rails root' do
      expect(described_class.ignorefile_path).to eq(Rails.root.join('config/deprecations.ignore'))
    end

    context 'when env var is set' do
      before do
        allow(ENV).to receive(:[]).with('UNCRUFT_IGNOREFILE_PATH').and_return('/path/to/file.txt')
      end

      it 'uses env var' do
        expect(described_class.ignorefile_path).to eq('/path/to/file.txt')
      end
    end
  end
end
