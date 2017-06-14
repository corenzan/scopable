# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scopable/version'

Gem::Specification.new do |spec|
  spec.name          = 'scopable'
  spec.version       = Scopable::VERSION
  spec.authors       = ['Arthur Corenzan']
  spec.email         = ['arthur@corenzan.com']
  spec.summary       = 'Easy parametric model scoping in Rails.'
  spec.description   = 'Scopable allows you to create Scope objects that intelligently applies scopes Rails models based on a set of predefined rules and incoming parameters.'
  spec.homepage      = 'https://github.com/corenzan/scopable'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_runtime_dependency 'activesupport', '>= 5.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'minitest', '~> 5.10'
end
