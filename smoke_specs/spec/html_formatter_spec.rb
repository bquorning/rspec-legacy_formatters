# encoding: utf-8
require 'rspec/legacy_formatters/html_formatter'

# this is a specific spec for #18

module RSpec
  module Core
    module Formatters
      RSpec.describe HtmlFormatter do

        let(:generated_html) do
          err, out = StringIO.new, StringIO.new
          err.set_encoding("utf-8") if err.respond_to?(:set_encoding)

          config = RSpec::Core::Configuration.new
          config.error_stream = err
          config.output_stream = out
          config.formatter = 'html'
          config.backtrace_formatter.inclusion_patterns = []

          my_reporter = RSpec::Core::Reporter.new(config)

          group = RSpec.describe "some examples" do
            it 'passes' do
              true
            end

            it 'fails' do
              fail
            end
          end
          group.run my_reporter

          out.string
        end

        before do
          allow(RSpec.configuration).to receive(:load_spec_files) do
            RSpec.configuration.files_to_run.map {|f| load File.expand_path(f) }
          end
        end

        describe 'produced HTML' do
          it 'is present' do
            expect(generated_html).to be
          end
        end
      end
    end
  end
end
