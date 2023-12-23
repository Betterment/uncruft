require 'spec_helper'

RSpec.describe Uncruft::Deprecatable do
  let(:my_name) { "Jess" }

  subject { klass.new }

  describe '.deprecate_attribute' do
    let(:klass) do
      Class.new do
        include Uncruft::Deprecatable

        attr_accessor :first_name

        deprecate_attribute(:first_name,
                            message: "Please stop using this attribute!")
      end
    end

    it 'applies deprecation warning when setting deprecated attribute' do
      expect(Uncruft.deprecator).to receive(:warn).once
        .with("Please stop using this attribute!")

      expect(subject.first_name = my_name).to eq my_name
    end

    it 'applies deprecation warning when getting deprecated attribute' do
      subject.instance_variable_set(:@first_name, my_name)

      expect(Uncruft.deprecator).to receive(:warn)
        .with("Please stop using this attribute!")

      expect(subject.first_name).to eq my_name
    end
  end

  describe '.deprecate_method' do
    let(:klass) do
      Class.new do
        include Uncruft::Deprecatable

        def legacy_method
          "Hello Old World!"
        end

        deprecate_method(:legacy_method,
                         message: "Please stop using this method!")
      end
    end

    it 'applies deprecation warning when calling the deprecated method' do
      expect(Uncruft.deprecator).to receive(:warn)
        .with("Please stop using this method!")

      expect(subject.legacy_method).to eq "Hello Old World!"
    end
  end
end
