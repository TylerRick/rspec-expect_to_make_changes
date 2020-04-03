require 'rspec/matchers/before_and_after'

RSpec::Matchers.define :make_changes do |*expected_changes|
  match(notify_expectation_failures: true) do |change_proc|
    expected_changes.map! do |expected_change|
      if Array === expected_change
        before_and_after(*expected_change)
      else
        expected_change
      end
    end

    compound = expected_changes.inject do |compound, expected_change|
      compound & expected_change
    end

    # TODO: aggregate_failures do
    expect(&change_proc).to compound
    #end
  end

  failure_message do |subject|
    " expected block to make changes:\n" +
    " but it did not."
  end

  def description
    super.sub(/\Amake changes */, '')
  end

  supports_block_expectations
end

RSpec::Matchers.alias_matcher :change_all, :check_all_before_and_after
RSpec::Matchers.alias_matcher :check_all, :check_all_before_and_after
RSpec::Matchers.alias_matcher :check_all_before_and_after, :make_changes
