lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rspec/expect_to_make_changes/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-expect_to_make_changes"
  spec.version       = Rspec::ExpectToMakeChanges.version
  spec.authors       = ["Tyler Rick"]
  spec.email         = ["tyler@tylerrick.com"]
  spec.license       = "MIT"

  spec.summary       = %q{expect {…}.to make_changes(…)}
  spec.description   = %q{Makes it easy to test that a block makes a number of changes, without requiring you to deeply nest a bunch of `expect { }` blocks within each other or rewrite them as `change` matchers.}
  spec.homepage      = "https://github.com/TylerRick/rspec-expect_to_make_changes"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.metadata["source_code_uri"]}/blob/master/Changelog.md"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
