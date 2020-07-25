require 'spec_helper'

RSpec.describe Uncruft::DeprecateAttribute do
  let(:my_name) { "Jess" }

  subject { klass.new }

  describe '#deprecate_attribute' do
    context 'when aliased_attribute is present' do
      let(:klass) do
        Class.new do
          include Uncruft::DeprecateAttribute

          attr_accessor :first_name

          deprecate_attribute(:first_name,
                              aliased_attribute: :legal_first_name,
                              message: "Please stop using this attribute, use this other attribute instead!")
        end
      end

      it 'applies deprecation warning when setting and getting deprecated attribute' do
        expect(ActiveSupport::Deprecation).to receive(:warn)
          .with("Please stop using this attribute, use this other attribute instead!")

        expect(subject.first_name = my_name).to eq my_name

        expect(ActiveSupport::Deprecation).to receive(:warn)
          .with("Please stop using this attribute, use this other attribute instead!")

        expect(subject.first_name).to eq my_name
      end

      it 'returns attribute when setting and getting aliased_attribute' do
        expect(subject.legal_first_name = my_name).to eq my_name

        expect(subject.legal_first_name).to eq my_name
      end
    end

    context 'when aliased_attribute is not present' do
      let(:klass) do
        Class.new do
          include Uncruft::DeprecateAttribute

          attr_accessor :first_name

          deprecate_attribute(:first_name,
                              message: "Please stop using this attribute!")
        end
      end

      it 'applies deprecation warning when setting and getting deprecated attribute' do
        expect(ActiveSupport::Deprecation).to receive(:warn)
          .with("Please stop using this attribute!")

        expect(subject.first_name = my_name).to eq my_name

        expect(ActiveSupport::Deprecation).to receive(:warn)
          .with("Please stop using this attribute!")

        expect(subject.first_name).to eq my_name
      end
    end
  end
end
