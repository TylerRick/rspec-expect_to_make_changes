require 'rspec/matchers/before_and_after'

class SomethingExpected
  attr_accessor :some_value
end

RSpec.describe "expect { ... }.to before_and_after(proc, proc)" do
  before(:example) do
    @instance = SomethingExpected.new
    @instance.some_value = 5
  end

  it 'passes' do
    expect { @instance.some_value = 6 }.to before_and_after(
      -> { expect(@instance.some_value).to eq 5 },
      -> { expect(@instance.some_value).to eq 6 }
    )
  end

  it 'fails before_proc' do
    expect do
      expect { @instance.some_value = 6 }.to before_and_after(
        -> { expect(@instance.some_value).to eq 0 },
        -> { expect(@instance.some_value).to eq 6 }
      )
    end.to fail_with(/before making the change:\n\s+expected: 0\s*got: 5/m)
  end

  it 'fails after_proc' do
    expect do
      expect { }.to before_and_after(
        -> { expect(@instance.some_value).to eq 5 },
        -> { expect(@instance.some_value).to eq 6 }
      )
    end.to fail_with(/after making the change:\n\s+expected: 6\s*got: 5/m)
  end

  context 'can be composed into a Compound' do
    it 'and' do
      expect { @instance.some_value = 6 }.to before_and_after(
        -> { expect(@instance.some_value).to be > 0 },
        -> { expect(@instance.some_value).to be < 100 }
      ).and(before_and_after(
        -> { expect(@instance.some_value).to eq 5 },
        -> { expect(@instance.some_value).to eq 6 }
      ))
    end

    xit 'or' do
      expect { @instance.some_value = 6 }.to before_and_after(
        -> { expect(@instance.some_value).to be > 0 },
        -> { expect(@instance.some_value).to be < 100 }
      ).or(before_and_after(
        -> { expect(@instance.some_value).to eq 20 },
        -> { expect(@instance.some_value).to eq 30 }
      ))
    end
  end

  context 'aliases' do
    it do
      expect { @instance.some_value = 6 }.to check_before_and_after(
        -> { expect(@instance.some_value).to eq 5 },
        -> { expect(@instance.some_value).to eq 6 }
      )
    end

    it do
      expect { @instance.some_value = 6 }.to expect_before_and_after(
        -> { expect(@instance.some_value).to eq 5 },
        -> { expect(@instance.some_value).to eq 6 }
      )
    end
  end
end
