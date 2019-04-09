
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gillbus/v2/version"

Gem::Specification.new do |spec|
  spec.name          = "gillbus-v2"
  spec.version       = Gillbus::V2::VERSION
  spec.authors       = ["Roman Khrebtov"]
  spec.email         = ["khrebtov.dev@gmail.com"]

  spec.summary       = "Ruby wrapper for Gillbus GDS API v2"
  spec.description   = "Ruby wrapper for Gillbus GDS API v2"
  spec.homepage      = "https://github.com/busfor/gillbus-v2-ruby"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"
  spec.add_dependency "money"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "dotenv"
end
