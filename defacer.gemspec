# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'defacer/version'

Gem::Specification.new do |spec|
  spec.name          = "defacer"
  spec.version       = Defacer::VERSION
  spec.authors       = ["Bradley Buda"]
  spec.email         = ["bradleybuda@gmail.com"]
  spec.summary       = %q{Pure-ruby JavaScript minifier}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rkelly-remix', '0.0.6'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
