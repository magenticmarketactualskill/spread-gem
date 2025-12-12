require_relative 'lib/spread_gem/version'

Gem::Specification.new do |spec|
  spec.name          = "spread-gem"
  spec.version       = SpreadGem::VERSION
  spec.authors       = ["SpreadGem Team"]
  spec.email         = ["team@spreadgem.example.com"]

  spec.summary       = "Ruby wrapper for SpreadJS distributed object synchronization"
  spec.description   = "Provides a Ruby interface to SpreadJS for real-time object replication across instances using WebSocket connections"
  spec.homepage      = "https://github.com/spreadjs/spread-gem"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.3.6"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/spreadjs/spread-gem"
  spec.metadata["changelog_uri"] = "https://github.com/spreadjs/spread-gem/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{lib,bin}/**/*") + %w[README.md CHANGELOG.md LICENSE.txt]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_runtime_dependency "websocket-client-simple", "~> 0.8"
  spec.add_runtime_dependency "json", "~> 2.7"
  spec.add_runtime_dependency "concurrent-ruby", "~> 1.2"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
