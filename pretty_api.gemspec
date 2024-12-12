require_relative "lib/pretty_api/version"

Gem::Specification.new do |spec|
  gemspec = File.basename(__FILE__)

  spec.name = "pretty-api"
  spec.version = PrettyApi::VERSION
  spec.authors = ["James St-Pierre"]
  spec.email = ["Jamesst20@gmail.com"]

  spec.summary = "Pretty API for Rails"
  spec.description = "Simplify the usage of accepts_nested_attributes_for in Rails applications."
  spec.homepage = "https://github.com/jamesst20/pretty_api"
  spec.license = "MIT"

  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0.0"
  spec.files = `git ls-files`.split("\n").reject do |f|
    (f == gemspec) || f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
  end

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jamesst20/pretty_api"
  spec.metadata["changelog_uri"] = "https://github.com/jamesst20/pretty_api/blob/master/CHANGELOG.md"

  spec.add_dependency "rails", ">= 7.0", "< 9.0"
end
