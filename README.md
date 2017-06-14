<div align="center">
  <a href="https://rubygems.org/gems/scopable"><img alt="RubyGems" src="https://img.shields.io/gem/dt/scopable.svg?style=flat-square"></a>
  <a href="https://travis-ci.org/corenzan/scopable"><img alt="Build" src="https://img.shields.io/travis/corenzan/scopable.svg?style=flat-square"></a>
  <a href="https://codeclimate.com/github/corenzan/scopable"><img alt="Code Climate" src="https://img.shields.io/codeclimate/github/corenzan/scopable.svg?style=flat-square"></a>
  <a href="https://codeclimate.com/github/corenzan/scopable/coverage"><img alt="Test Coverage" src="https://img.shields.io/codeclimate/coverage/github/corenzan/scopable.svg?style=flat-square"></a>
</div>

# Scopable

> Easy parametric model scoping in Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scopable'
```

And then execute:

```shell
$ bundle install
```

Or install it yourself with:

```shell
$ gem install scopable
```

## Usage

TODO: Update for 2.0.0.

### Options

No option is required. By default it assumes both scope and parameter have the same name.

Key         | Description
------------|--------------------------------------------------------------------------------------------------------------
`:param`    | Name of the parameter that activates the scope.
`:default`  | Default value for the scope in case the parameter is missing.
`:value`    | Force a value to the scope regardless of the request parameters.
`:required` | Calls `#none` on the model if parameter is absent (blank or nil) and there's no default value set.
`:if`       | ...
`:unless`   | ...
`&block`    | Block will be used to produce the resulting relation with two parameters: the relation at this step and the scope value from params.

## License

MIT. See [LICENSE.md](LICENSE.md) for full notice.
