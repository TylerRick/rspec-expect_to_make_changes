require 'ostruct'
require 'rspec/matchers/make_changes'
require 'rspec/matchers/before_and_after'

class SomethingExpected
  attr_accessor :some_value
  attr_accessor :other_value
end

# Copied from ../rspec-expectations/spec/rspec/matchers/built_in/change_spec.rb
# with all matchers wrapped in make_changes()
RSpec.describe "expect {…}.to make_changes(change(…))" do
  context "with a numeric value" do
    before(:example) do
      @instance = SomethingExpected.new
      @instance.some_value = 5
    end

    it "passes when actual is modified by the block" do
      expect { @instance.some_value = 6.0 }.to make_changes(
        change(@instance, :some_value)
      )
    end

    it "fails when actual is not modified by the block" do
      expect do
        expect {}.to make_changes(
          change(@instance, :some_value)
        )
      end.to fail_with("expected `SomethingExpected#some_value` to have changed, but is still 5")
    end

    it "fails when after value is different" do
      expect do
        expect { @instance.some_value = 6.0 }.to make_changes(
          change(@instance, :some_value).from(5).to(7.0)
        )
      end.to fail_with(/but is now 6\.0/)
    end

    it "provides a #description" do
      expect(make_changes(
        change(@instance, :some_value)
      ).description).to eq "change `SomethingExpected#some_value`"
    end
  end

  it "can specify the change of a variable's class" do
    val = nil

    expect {
      val = "string"
    }.to make_changes(
      change { val.class }.from(NilClass).to(String)
    )

    expect {
      expect {
        val = :symbol
      }.to make_changes(
        change { val.class }.from(String).to(NilClass)
      )
    }.to fail_with(/but is now Symbol/)
  end

  context "with boolean values" do
    before(:example) do
      @instance = SomethingExpected.new
      @instance.some_value = true
    end

    it "passes when actual is modified by the block" do
      expect { @instance.some_value = false }.to make_changes(
        change(@instance, :some_value)
      )
    end

    it "fails when actual is not modified by the block" do
      expect do
        expect {}.to make_changes(
          change(@instance, :some_value)
        )
      end.to fail_with("expected `SomethingExpected#some_value` to have changed, but is still true")
    end
  end

  # …

  describe "Passing matchers to `change`" do
    specify "you can pass a matcher to `by`" do
      k = 0
      expect { k += 1.05 }.to make_changes(
        change { k }.
          by( a_value_within(0.1).of(1.0) )
      )
    end
  end
end

# Similar to the previous section, but with multiple changee matchers passed in.
RSpec.describe "expect {…}.to make_changes(change(…), change(…), …)" do
  context "with a numeric value" do
    before(:example) do
      @instance = SomethingExpected.new
      @instance.some_value = 5
      @instance.other_value = 5
    end

    it "passes when actual is modified by the block" do
      expect { @instance.some_value = 6.0 }.to make_changes(
        change(@instance, :some_value).from(5),
        change(@instance, :some_value).by(1.0),
      )
    end

    it "fails when actual is not modified by the block" do
      expect do
        expect {}.to make_changes(
          change(@instance, :some_value),
          change(@instance, :other_value),
        )
      end.to fail_with(<<-End.chomp)
   expected `SomethingExpected#some_value` to have changed, but is still 5

...and:

   expected `SomethingExpected#other_value` to have changed, but is still 5
End
    end

    it "fails when after value is different" do
      expect do
        expect { @instance.some_value = 6.0 }.to make_changes(
          change(@instance, :some_value).from(5).to(7.0),
          change(@instance, :other_value).from(5).to(7.0)
        )
      end.to fail_with(/but is now 6\.0/)
    end

    it "provides a #description" do
      expect(make_changes(
        change(@instance, :some_value),
        change(@instance, :other_value),
      ).description).to eq "change `SomethingExpected#some_value` and change `SomethingExpected#other_value`"
    end
  end

  # …
end

RSpec.describe "expect {…}.to change(…) & change(…) (using only built-in matchers)" do
  it do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect {
      expect {
        expect {
          thing.a *= 0
          thing.b = -thing.b
          thing.c *= thing.c
        }.to change { thing.a }.from(1).to(0)
      }.to change { thing.b }.from(2).to(-2)
    }.to change { thing.c }.from(3).to(9)
  end

  it do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect {
      thing.a *= 0
      thing.b = -thing.b
      thing.c *= thing.c
    }.to (
      change { thing.a }.from(1).to(0) &
      change { thing.b }.from(2).to(-2) &
      change { thing.c }.from(3).to(9)
    )
  end

  it do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect {
      thing.a *= 0
      thing.b = -thing.b
      thing.c *= thing.c
    }.to make_changes(
      change { thing.a }.from(1).to(0) &
      change { thing.b }.from(2).to(-2) &
      change { thing.c }.from(3).to(9)
    )
  end
end

RSpec.describe "expect {…}.to make_changes(change_array, …)" do
  it do
    array = ['food', 'water']
    expect { array << 'spinach' }.to make_changes([
      ->{ expect(array).not_to include 'spinach' },
      ->{ expect(array).to     include 'spinach' },
    ])
  end

  it do
    thing = OpenStruct.new(a: 1)
    expect {
      thing.a *= 0
    }.to make_changes([
      ->{ expect(thing.a).to eq 1 },
      ->{ expect(thing.a).to eq 0 },
    ])
  end

  it do
    thing = OpenStruct.new(a: 1)
    expect {
      thing.a *= 0
    }.to make_changes(before_and_after(
      ->{ expect(thing.a).to eq 1 },
      ->{ expect(thing.a).to eq 0 },
    ))
  end

  it do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect {
      thing.a *= 0
      thing.b = -thing.b
      thing.c *= thing.c
    }.to make_changes([
      ->{ expect(thing.a).to eq 1 },
      ->{ expect(thing.a).to eq 0 },
    ], [
      ->{ expect(thing.b).to eq 2 },
      ->{ expect(thing.b).to eq(-2) },
    ], [
      ->{ expect(thing.c).to eq 3 },
      ->{ expect(thing.c).to eq 9 },
    ])
  end
end


RSpec.describe "expect {…}.to make_changes(…) (mixing Compound::And and BeforeAndAfter array)" do
  it do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect {
      thing.a *= 0
      thing.b = -thing.b
      thing.c *= thing.c
    }.to make_changes((
      change { thing.a }.from(1).to(0) &
      change { thing.b }.from(2).to(-2)
    ), [
      ->{ expect(thing.c).to eq 3 },
      ->{ expect(thing.c).to eq 9 },
    ])
  end

  it do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect {
      thing.a *= 0
      thing.b = -thing.b
      thing.c *= thing.c
    }.to make_changes(
      before_and_after(
        ->{ expect(thing.a).to be >= 1 },
        ->{ expect(thing.a).to be <  1 },
      ), (
        change { thing.a }.by(-1) &
        change { thing.b }.from(2).to(-2)
      ), [
        ->{ expect(thing.c).to eq 3 },
        ->{ expect(thing.c).to eq 9 },
      ]
    )
  end

  it 'expectations[0].before failure' do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect do
      expect {
        thing.a *= 0
        thing.b = -thing.b
        thing.c *= thing.c
      }.to make_changes(
        before_and_after(
          ->{ expect(thing.a).to be >  1 },
          ->{ expect(thing.a).to be <  1 },
        ), (
          change { thing.a }.by(-1) &
          change { thing.b }.from(2).to(-2)
        ), [
          ->{ expect(thing.c).to eq 3 },
          ->{ expect(thing.c).to eq 9 },
        ]
      )
    end.to fail_with(<<-End.chomp)
before making the change:
   expected: > 1
        got:   1
    End
  end

  it 'expectations[1][0] failure' do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect do
      expect {
        thing.a *= 0
        thing.b = -thing.b
        thing.c *= thing.c
      }.to make_changes(
        before_and_after(
          ->{ expect(thing.a).to be >= 1 },
          ->{ expect(thing.a).to be <  1 },
        ), (
          change { thing.a }.by(-99) &
          change { thing.b }.from(2).to(-2)
        ), [
          ->{ expect(thing.c).to eq 3 },
          ->{ expect(thing.c).to eq 9 },
        ]
      )
    end.to fail_with('expected `thing.a` to have changed by -99, but was changed by -1')
  end

  it 'expectations[2].after failure' do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect do
      expect {
        thing.a *= 0
        thing.b = -thing.b
        thing.c *= thing.c
      }.to make_changes(
        before_and_after(
          ->{ expect(thing.a).to be >= 1 },
          ->{ expect(thing.a).to be <  1 },
        ), (
          change { thing.a }.by(-1) &
          change { thing.b }.from(2).to(-2)
        ), [
          ->{ expect(thing.c).to eq 3 },
          ->{ expect(thing.c).to eq 99 },
        ]
      )
    end.to fail_with(<<-End)
after making the change:

   expected: 99
        got: 9

   (compared using ==)
End
  end

  # TODO: Doesn't currently aggregate failures, but that might be good to add, at least as an option
  # you can pass to make_changes?
  it 'expectations[0].before + expectations[1][0] + expectations[2].after failures' do
    thing = OpenStruct.new(a: 1, b: 2, c: 3)
    expect do
      expect {
        thing.a *= 0
        thing.b = -thing.b
        thing.c *= thing.c
      }.to make_changes(
        before_and_after(
          ->{ expect(thing.a).to be >  1 },
          ->{ expect(thing.a).to be <  1 },
        ), (
          change { thing.a }.by(-99) &
          change { thing.b }.from(2).to(-2)
        ), [
          ->{ expect(thing.c).to eq 3 },
          ->{ expect(thing.c).to eq 99 },
        ]
      )
    end.to fail_with(<<-End.chomp)
before making the change:
   expected: > 1
        got:   1
    End
  end
end

RSpec.context 'make_changes aliases' do
  before(:example) do
    @instance = SomethingExpected.new
    @instance.some_value = 5
  end

  it do
    expect { @instance.some_value = 6 }.to check_all(
      before_and_after(
        -> { expect(@instance.some_value).to eq 5 },
        -> { expect(@instance.some_value).to eq 6 }
      )
    )
  end

  it do
    expect { @instance.some_value = 6 }.to check_all_before_and_after(
      before_and_after(
        -> { expect(@instance.some_value).to eq 5 },
        -> { expect(@instance.some_value).to eq 6 }
      )
    )
  end
end
