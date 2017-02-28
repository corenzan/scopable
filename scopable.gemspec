# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scopable/version'

Gem::Specification.new do |spec|
  spec.name          = 'scopable'
  spec.version       = Scopable::VERSION
  spec.authors       = ['Arthur Corenzan']
  spec.email         = ['arthur@corenzan.com']
  spec.summary       = %q{Apply or skip model scopes based on options and request parameters.}
  # spec.description   = %q{}
  spec.homepage      = 'https://github.com/haggen/scopable'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_runtime_dependency 'activesupport', '>= 3.2', '<= 5.0.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
end
