require 'spec_helper'

RSpec.describe Uncruft::DeprecateMethod do
  let(:my_name) { "Jess" }

  subject { klass.new }

  describe '.deprecate_method' do
    let(:klass) do
      Class.new do
        include Uncruft::DeprecateMethod

        attr_accessor :first_name

        deprecate_method(:first_name,
          message: "Please stop using this attribute!")
      end
    end

    it 'applies deprecation warning when setting deprecated attribute' do
      expect(ActiveSupport::Deprecation).to receive(:warn).once
        .with("Please stop using this attribute!")

      expect(subject.first_name = my_name).to eq my_name
    end

    it 'applies deprecation warning when getting deprecated attribute' do
      subject.instance_variable_set(:@first_name, my_name)

      expect(ActiveSupport::Deprecation).to receive(:warn)
        .with("Please stop using this attribute!")

      expect(subject.first_name).to eq my_name
    end
  end
end
