# frozen_string_literal: true

require_relative "lib/star_fetcher/version"

Gem::Specification.new do |spec|
  spec.name = "star-fetcher"
  spec.version = StarFetcher::VERSION
  spec.authors = ["Wolf Van den Zegel"]
  spec.email = ["wolf.vdz@protonmail.com"]

  spec.summary = "A minimal, dependency-free neofetch-like system fetcher."
  spec.description = "Prints a neofetch-style system summary with auto-selected " \
                     "openSUSE ASCII artwork. Ruby stdlib only."
  spec.homepage = "https://github.com/Nauclerus/star-fetcher"
  spec.license = "AGPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.4"

  spec.files = Dir[
    "lib/**/*.rb",
    "bin/star-fetcher",
    "ascii/*.txt",
    "README.md",
    "NOTICE",
    "LICENSE"
  ]
  spec.bindir = "bin"
  spec.executables = ["star-fetcher"]
  spec.require_paths = ["lib"]

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"
end
