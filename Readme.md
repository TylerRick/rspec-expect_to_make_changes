# RSpec expect `before_and_after`

This small library makes it easy to test for a large number of changes, without requiring you to
deeply nest a bunch of `expect { }` blocks within each other or rewrite them as `change` matchers.

Sure, you could just write add a list of regular RSpec expectations about how the state should be
_before_ your action, and another list of expectations about how the state should be _after_ your
action, and call that a "test for how your action changes the state".

```ruby
  expect(thing.a).to eq 1
  expect(thing.b).to eq 2
  expect(thing.c).to eq 3
  perform_change
  expect(thing.c).to eq 9
  expect(thing.b).to eq -2
  expect(thing.a).to eq 0
```

But many times, your expectations occur in _pairs_: a "before" and an "after": one for the state of
something _before_ the action and a matching expectation for the state of the _same_ thing _after_
the action.

And as the number of pairs grows, it can be quite hard for the reader of your test to see which
expectations are related, and how. It can also be hard for the writer of the test to maintain, esp.
if they are relying on things like order and proximity alone to connect related before/after
expectations.

`make_changes` gives you a tool to make it explicit and _extremely_ clear that those 2
expectations are a pair that are very tightly related.

So instead of the above, you can rewrite it as explicit pairs like this:

```ruby
  expect {
    perform_change
  }.to make_changes([
    ->{ expect(thing.a).to eq 1 },
    ->{ expect(thing.a).to eq 0 },
  ], [
    ->{ expect(thing.b).to eq 2 },
    ->{ expect(thing.b).to eq -2 },
  ], [
    ->{ expect(thing.c).to eq 9 },
    ->{ expect(thing.c).to eq 9 },
  ])
```

or, using `change` matchers, like this:

```ruby
  expect {
    perform_change
  }.to make_changes(
    change { thing.a }.from(1).to(0),
    change { thing.b }.from(2).to(-2),
    change { thing.c }.from(3).to(9),
  )
```


RSpec _already_ provides a built-in matcher for expressing changes expected as a result of executing a block.
So you _could_ also rewrite our example like this and get much the same benefit:

```ruby
  expect {
    expect {
      expect {
        perform_change
      }.to change { thing.a }.from(1).to(0)
    }.to change { thing.b }.from(2).to(-2)
  }.to change { thing.c }.from(3).to(9)
```

Granted, that makes it _much_ clearer at a quick glance what changes are expected by your action.
But it also has some drawbacks:

1. You have to completely rewrite your expectations — which may have started out (as in our example)
   as good old plain `expect(something).to eq something` expectations — into a _very_ different
   `change()` matcher style.
2. You end up with extra nesting, which can make your tests look a bit unwieldy and harder to read
   than it needs to be.

RSpec provides compound (`and`/`&`) matchers that let you combine several matchers together and
treat them as one, so you can actually simplify that to just a single event block using just
built-in RSpec:
```ruby
  expect {
    perform_change
  }.to (
    change { thing.a }.from(1).to(0) &
    change { thing.b }.from(2).to(-2) &
    change { thing.c }.from(3).to(9)
  )
```

X Instead of treating this as a sequence of unrelated nested expectations, `make_changes` treats
this as a single action block that has _n_ related expectations describing the state before/after the
action.

`make_changes` tames the nesting, flattening it to a single block, and gives you the flexibility
to either leave your before/after expectations as "regular" `expect`s or use the `change()` matcher
style of expecting changes.

`change` is often all you need for changes to primitive values. But it isn't always enough for
doing more complex before/after checks. And it's not always convenient to rewrite existing
expectations to a different (`change`) syntax.

This flexibility gives you the power and flexibility to lets you express some things that you simply
couldn't express if you were limited to only the `change` matcher, such as things that you would
normally use another specialized matcher for, such as expectations on arrays or hashes:

```ruby
      [
        ->{ expect_too_close_to_pedestrians(car) },
        ->{ expect_sufficient_proximity_from_pedestrians(car) },
      ], [
        ->{ expect(instance.tags).to match_array [:old_tag] },
        ->{ expect(instance.tags).to match_array [:new_tag] },
      ], [
        ->{
          expect(team.members).to     include user_1
          expect(team.members).to_not include user_2
        },
        ->{ expect(team.members).to include user_1, user_2 },
      ]
```

It can sometimes be more readable or maintainable if you can just use/reuse regular expectations for
your before/after checks.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-make_changes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-make_changes


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/rspec-make_changes.
