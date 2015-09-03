# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qmeter/version'

Gem::Specification.new do |spec|
  spec.name          = "qmeter"
  spec.version       = Qmeter::VERSION
  spec.authors       = ["Rohit Bhore"]
  spec.email         = ["rohit.bhore@clariontechnologies.co.in"]

  spec.summary       = %q{Code quality report through metric_fu and brakeman gem}
  spec.description   = %q{Code quality report through metric_fu and brakeman gem}
  spec.homepage      = "https://github.com/rohitpbhore/qmeter.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "brakeman"
  spec.add_runtime_dependency "metric_fu"
  spec.add_runtime_dependency "railties"
  spec.add_runtime_dependency "terminal-table"
end
