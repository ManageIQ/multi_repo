# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_repo/version'

Gem::Specification.new do |spec|
  spec.name          = "multi_repo"
  spec.version       = MultiRepo::VERSION
  spec.authors       = ["ManageIQ Authors"]
  spec.email         = ["contact@manageiq.org"]
  spec.description   = %q{MultiRepo is a library for managing multiple repositiories and running scripts against them.}
  spec.summary       = spec.description
  spec.homepage      = "http://github.com/ManageIQ/multi_repo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "colorize"
  spec.add_runtime_dependency "config"
  spec.add_runtime_dependency "json", "~> 2.9.1" # Pin json due to https://github.com/ruby/json/issues/752
  spec.add_runtime_dependency "licensee"
  spec.add_runtime_dependency "minigit"
  spec.add_runtime_dependency "more_core_extensions"
  spec.add_runtime_dependency "octokit", ">= 7.0.0"
  spec.add_runtime_dependency "optimist"
  spec.add_runtime_dependency "progressbar"
  spec.add_runtime_dependency "psych", ">=3"
  spec.add_runtime_dependency "rbnacl"
  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "travis"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "manageiq-style", ">= 1.5.4"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "simplecov", ">= 0.21.2"
end
