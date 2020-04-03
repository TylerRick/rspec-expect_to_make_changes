require "bundler/setup"
require 'rspec/support/spec'
require 'rspec/support/spec/in_sub_process'

require "rspec/expect_to_make_changes"

Dir['./spec/support/**/*'].each do |f|
  require f.sub(%r{\./spec/}, '')
end

module CommonHelperMethods
  def with_env_vars(vars)
    original = ENV.to_hash
    vars.each { |k, v| ENV[k] = v }

    begin
      yield
    ensure
      ENV.replace(original)
    end
  end

  def dedent(string)
    string.gsub(/^\s+\|/, '').chomp
  end

  # We have to use Hash#inspect in examples that have multi-entry
  # hashes because the #inspect output on 1.8.7 is non-deterministic
  # due to the fact that hashes are not ordered. So we can't simply
  # put a literal string for what we expect because it varies.
  if RUBY_VERSION.to_f == 1.8
    def hash_inspect(hash)
      "\\{(#{hash.map { |key, value| "#{key.inspect} => #{value.inspect}.*" }.join "|"}){#{hash.size}}\\}"
    end
  else
    def hash_inspect(hash)
      RSpec::Matchers::BuiltIn::BaseMatcher::HashFormatting.
        improve_hash_formatting hash.inspect
    end
  end
end

RSpec.configure do |config|
  config.include CommonHelperMethods

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

