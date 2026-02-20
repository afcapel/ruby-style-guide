# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "rubocop-afcapel"
  spec.version = "0.1.0"
  spec.authors = [ "Alberto Fernandez-Capel" ]
  spec.summary = "Extension of rubocop-rails-omakase with guardrails for common coding agent style mistakes"
  spec.homepage = "https://github.com/afcapel/rubocop-rules"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir["lib/**/*", "config/**/*", "LICENSE", "README.md"]

  spec.add_dependency "rubocop", ">= 1.0"
  spec.add_dependency "rubocop-rails-omakase"
end
