# frozen_string_literal: true

require 'spec_helper'

describe Uncruft::Railtie do
  let(:app) { Rails.application }
  let(:initializers) { app.initializers.tsort_each.select { |i| i.name.to_s.include?('deprecation') } }

  it 'injects the default deprecation handler' do
    expect { initializers.map { |i| i.run(app) } }.to change { Rails.application.config.active_support.deprecation }
      .from(nil).to(a_collection_containing_exactly(an_instance_of(Uncruft::DeprecationHandler)))
  end

  if Rails.gem_version > Gem::Version.new('7.1')
    before do
      allow(Uncruft).to receive(:record_deprecations?).and_return(true)
    end

    it 'includes deprecator into Rails.application.deprecators' do
      app.initialize!

      expect(app.deprecators[:uncruft]).to eq Uncruft.deprecator
    end
  end

  context 'when the configured behavior is :stderr' do
    before do
      Rails.application.config.active_support.deprecation = :stderr
    end

    it 'injects the default deprecation handler' do
      expect { initializers.map { |i| i.run(app) } }.to change { Rails.application.config.active_support.deprecation }
        .from(:stderr).to(a_collection_containing_exactly(an_instance_of(Uncruft::DeprecationHandler)))
    end
  end

  context 'when a custom deprecation behavior is already configured' do
    before do
      Rails.application.config.active_support.deprecation = :notify
    end

    it 'injects the default deprecation handler' do
      expect { initializers.map { |i| i.run(app) } }.to change { Rails.application.config.active_support.deprecation }
        .from(:notify).to(a_collection_containing_exactly(:notify, an_instance_of(Uncruft::DeprecationHandler)))
    end
  end
end
