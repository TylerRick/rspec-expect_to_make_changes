module RSpec::Matchers
  # Applied to a proc, specifies that its execution will cause some value to
  # change.
  #
  # Allows you to run a pair of related checks — one before the change and one after the change.
  # The checks can be any arbitrary RSpec expectations.
  #
  # @param [Proc] before_proc The expectation to check before making the change.
  # @param [Proc] after_proc The expectation to check after making the change.
  def before_and_after(before_proc, after_proc)
    BeforeAndAfter.new(before_proc, after_proc)
  end
end
RSpec::Matchers.alias_matcher :expect_before_and_after, :before_and_after
RSpec::Matchers.alias_matcher :check_before_and_after,  :before_and_after

# Modeled after RSpec::Matchers::BuiltIn::Change
class BeforeAndAfter < RSpec::Matchers::BuiltIn::BaseMatcher
  def initialize(before_proc, after_proc)
    @before_proc = before_proc
    @after_proc  = after_proc
  end

  def matches?(event_proc)
    @event_proc = event_proc
    perform_change(event_proc)
  end

  def supports_block_expectations?
    true
  end

private

  def perform_change(event_proc)
    reraise_with_prefix 'before making the change:' do
      @before_proc.call
    end

    return false unless Proc === event_proc
    event_proc.call

    reraise_with_prefix 'after making the change:' do
      @after_proc.call
    end
    true
  end

  def reraise_with_prefix(prefix)
    begin
      yield
    rescue RSpec::Expectations::ExpectationNotMetError
      raise $!, "#{prefix}\n#{indent_multiline_message($!.message)}", $!.backtrace
    end
  end

  def indent_multiline_message(message)
    message.lines.map do |line|
      line =~ /\S/ ? '   ' + line : line
    end.join
  end
end
