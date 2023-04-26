require 'spec_helper'

RSpec.describe Uncruft::DeprecationHandler do
  let(:ignorefile_path) { Rails.root.join('config/deprecations.ignore') }

  before do
    FileUtils.rm_f(ignorefile_path)
  end

  subject { described_class.new }

  describe '#call' do
    let(:absolute_path) { Rails.root.join('chicken/nuggets.rb') }
    let(:line_number) { 123 }
    let(:caller_label) { '<something>' }
    let(:message) { "Warning: BAD called from #{caller_label} at #{absolute_path}:#{line_number}" }
    let(:expected_ignorefile_entry) { 'Warning: BAD called from <something> at chicken/nuggets.rb' }
    let(:expected_error) { "#{expected_ignorefile_entry}:123" }
    let(:expected_error_message) do
      <<~ERROR.strip
        #{expected_error}

        To resolve this error, adjust your code according to the instructions above.
        If you did not introduce this error or are unsure why you are seeing it,
        you will find additional guidance at the URL below:
        https://github.com/Betterment/uncruft/blob/main/GUIDE.md
      ERROR
    end

    it 'sanitizes the message and raises an error' do
      expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
    end

    context 'when recording new deprecations' do
      before do
        allow(Uncruft).to receive(:record_deprecations?).and_return(true)
      end

      it 'sanitizes the message and writes it to the file' do
        expect { subject.call(message, '') }.to change { File.exist?(ignorefile_path) }.from(false).to(true)
        expect(File.read(ignorefile_path)).to include(expected_ignorefile_entry)
      end

      context 'when timecop is enabled' do
        let(:test_started) { Time.zone.now }

        it 'ignores time travel and writes the current time' do
          Timecop.travel(test_started - 100.years) do
            subject.call(message, '')

            file_updated = Time.zone.parse(JSON.parse(File.read(ignorefile_path))['updated'])
            expect(file_updated).to be_within(1.second).of(test_started)
          end
        end
      end
    end

    context 'when caller is an erb file' do
      let(:caller_label) { '_app_views_bananas_show__1234_567890' }
      let(:expected_ignorefile_entry) { 'Warning: BAD called from chicken/nuggets.rb' }

      it 'sanitizes the message and raises an error' do
        expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
      end
    end

    context 'when caller is "top (required)"' do
      let(:caller_label) { '<top (required)>' }
      let(:expected_ignorefile_entry) { 'Warning: BAD called from <global scope> at chicken/nuggets.rb' }

      it 'sanitizes the caller and raises an error' do
        expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
      end
    end

    context 'when caller is "main"' do
      let(:caller_label) { '<main>' }
      let(:expected_ignorefile_entry) { 'Warning: BAD called from <global scope> at chicken/nuggets.rb' }

      it 'sanitizes the caller and raises an error' do
        expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
      end
    end

    context 'when message includes custom gem path' do
      let(:absolute_path) { Pathname.new('/banana/banana/banana/gems/chicken/nuggets.rb') }
      let(:expected_ignorefile_entry) { "Warning: BAD called from <something> at $GEM_PATH/chicken/nuggets.rb" }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('GEM_HOME').and_return('/banana/banana/banana')
      end

      it 'sanitizes the message and raises an error' do
        expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
      end

      context 'when gem home is nested' do
        let(:absolute_path) { Pathname.new('/banana/banana/banana/arbitrary/gem/path/gems/chicken/nuggets.rb') }

        it 'sanitizes the message and raises an error' do
          expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
        end
      end

      context 'when gem is vendored' do
        let(:absolute_path) { Rails.root.join('vendor/cache/chicken/nuggets.rb') }

        it 'sanitizes the message and raises an error' do
          expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
        end

        context 'when gem is vendored elsewhere' do
          let(:absolute_path) { Rails.root.join('../../vendor/cache/chicken/nuggets.rb') }

          it 'sanitizes the message and raises an error' do
            expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
          end
        end
      end
    end

    context 'when caller is not a filepath' do
      let(:absolute_path) { '(pry)' }
      let(:expected_ignorefile_entry) { 'Warning: BAD called from <something> at (pry)' }

      it 'sanitizes the message and raises an error' do
        expect { subject.call(message, '') }.to raise_error(RuntimeError, expected_error_message)
      end
    end

    context 'when ignorefile exists' do
      let(:message) { "Warning: BAD called from #{absolute_path}:#{line_number}" }
      let(:file_content) do
        <<~IGNOREFILE
          {
            "ignored_warnings": [
              "Warning: BAD called from chicken/nuggets.rb"
            ],
            "updated": "2018-06-05 15:20:12 -0400",
            "rails_version": "5.1.6"
          }
        IGNOREFILE
      end

      before do
        File.write(ignorefile_path, file_content)
      end

      it 'does not raise an error and leaves the file intact' do
        expect(File.read(ignorefile_path)).to eq(file_content)
        expect { subject.call(message, '') }.not_to change { File.read(ignorefile_path) }
      end

      context 'when recording new deprecations' do
        let(:line_number) { '456' }

        before do
          allow(Uncruft).to receive(:record_deprecations?).and_return(true)
        end

        it 'does not raise an error and leaves the file intact' do
          expect(File.read(ignorefile_path)).to eq(file_content)
          expect { subject.call(message, '') }.not_to raise_error
          expect(File.read(ignorefile_path)).to include('Warning: BAD called from chicken/nuggets.rb')
        end
      end
    end
  end
end
