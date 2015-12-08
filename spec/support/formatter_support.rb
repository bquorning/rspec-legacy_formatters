module FormatterSupport

  def run_example_specs_with_formatter(formatter_option, normalize_output=true)
    options = RSpec::Core::ConfigurationOptions.new(%W[spec/rspec/core/resources/formatter_specs.rb --format #{formatter_option} --order defined])

    err, out = StringIO.new, StringIO.new
    err.set_encoding("utf-8") if err.respond_to?(:set_encoding)

    runner = RSpec::Core::Runner.new(options)
    configuration = runner.instance_variable_get("@configuration")
    configuration.backtrace_formatter.exclusion_patterns << /rspec_with_simplecov/
    configuration.backtrace_formatter.inclusion_patterns = []

    runner.run(err, out)

    output = out.string
    return output unless normalize_output
    output = normalize_durations(output)

    caller_line = RSpec::Core::Metadata.relative_path(caller.first)
    output.lines.reject do |line|
      # remove the direct caller as that line is different for the summary output backtraces
      line.include?(caller_line) ||

      # ignore scirpt/rspec_with_simplecov because we don't usually have it locally but
      # do have it on travis
      line.include?("script/rspec_with_simplecov") ||

      # this line varies a bit depending on how you run the specs (via `rake` vs `rspec`)
      line.include?('/exe/rspec:')
    end.join
  end

  def send_notification type, notification
    reporter.notify type, notification
  end

  def reporter
    @reporter ||= setup_reporter
  end

  def setup_reporter(*streams)
    config.add_formatter described_class, *streams
    @formatter = config.formatters.first
    @reporter = config.reporter
  end

  def output
    @output ||= StringIO.new
  end

  def config
    @configuration ||=
      begin
        config = RSpec::Core::Configuration.new
        config.output_stream = output
        config
      end
  end

  def configure
    yield config
  end

  def formatter
    @formatter ||=
      begin
        setup_reporter
        @formatter
      end
  end

  def example
    instance_double("RSpec::Core::Example",
                    :description      => "Example",
                    :full_description => "Example",
                    :execution_result => instance_double(RSpec::Core::Example::ExecutionResult, :exception => Exception.new).as_null_object ,
                    :metadata         => {}
                   )
  end

  def group
    class_double "RSpec::Core::ExampleGroup", :description => "Group"
  end

  def start_notification(count)
   ::RSpec::Core::Notifications::StartNotification.new count
  end

  def example_notification(specific_example = example)
   ::RSpec::Core::Notifications::ExampleNotification.for specific_example
  end

  def group_notification
   ::RSpec::Core::Notifications::GroupNotification.new group
  end

  def message_notification(message)
    ::RSpec::Core::Notifications::MessageNotification.new message
  end

  def null_notification
    ::RSpec::Core::Notifications::NullNotification
  end

  def seed_notification(seed, used = true)
    ::RSpec::Core::Notifications::SeedNotification.new seed, used
  end

  def summary_notification(duration, examples, failed, pending, time)
    ::RSpec::Core::Notifications::SummaryNotification.new duration, examples, failed, pending, time
  end

end
