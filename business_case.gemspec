# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "business_case"
  spec.version = "1.0.0"

  spec.author      = "n00ge"
  spec.email       = "n00ge@github.com"
  spec.summary     = "Clean Architecture use case interactors for Ruby"
  spec.description = "Clean Architecture use case interactors for Ruby. A modernized fork of collectiveidea/interactor with type-safe contracts and no runtime dependencies."
  spec.homepage    = "https://github.com/n00ge/business_case"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "LICENSE.txt",
    "README.md",
    "CHANGELOG.md",
    "UPGRADING.md"
  ]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", ">= 13.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/n00ge/business_case/issues",
    "changelog_uri" => "https://github.com/n00ge/business_case/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/n00ge/business_case",
    "rubygems_mfa_required" => "true"
  }
end
