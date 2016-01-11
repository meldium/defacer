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
  spec.description   = %q{Favors speed over size of minified JS, works on any ruby platform, works well with the Rails asset pipeline and Sprockets}
  spec.homepage      = "https://github.com/meldium/defacer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rkelly-remix', '0.0.7'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.2'

  # For benchmarking
  spec.add_development_dependency 'closure-compiler', '~> 1.1'
  spec.add_development_dependency 'terminal-table', '~> 1.4'
  spec.add_development_dependency 'uglifier', '~> 2.5'
end
