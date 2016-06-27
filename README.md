# Scopable

> Apply model scopes based on request parameters.

[![Code Climate](https://codeclimate.com/github/haggen/scopable/badges/gpa.svg)](https://codeclimate.com/github/haggen/scopable)
[![Test Coverage](https://codeclimate.com/github/haggen/scopable/badges/coverage.svg)](https://codeclimate.com/github/haggen/scopable/coverage)
[![Build](https://travis-ci.org/haggen/scopable.svg)](https://travis-ci.org/haggen/scopable)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scopable'
```

And then execute:

```shell
$ bundle
```

Or install it yourself with:

```shell
$ gem install scopable
```

## Usage

Configure scopes in your controller:

```ruby
class PostsController < ApplicationController
  include Scopable

  scope :search, param: :q

  # ...
end
```

Then apply it to your model:

```ruby
def index
  @posts = scoped(Post, params)
end
```

Now whenever the parameter `q` is present in `params`, `#search` will be called on your model passing the parameter's value as argument.

Another example:

```ruby
class PostController < ApplicationController
  include Scopable

  scope :by_date, param: :date do |scoped_model, value|
    scoped_model.where(created_at: Date.parse(value))
  end

  scope :by_author, param: :author

  scope :order, force: { created_at: :desc }

  def index
    @posts = scoped(Post, params)
  end
end
```

Based on the example above, if your parameters looked like this:

```ruby
{
  date: '6/1/2016',
  author: '2'
}
```

The final query would be:

```ruby
Post.where(created_at: '6/1/2016').by_author(2).order(created_at: :desc)
```

**Note that order matters!** The scopes will be applied in the same order they are configured.

### Options

No option is required. By default it assumes both scope and parameter have the same name.

Key         | Description
------------|----------------------------------------------------------------------------------------
`:param`    | Name of the parameter that activates the scope.
`:default`  | Default value for the scope in case the parameter is missing.
`:force`    | Force a value to the scope regardless of the parameters.
`:required` | Calls `#none` on the model parameter is absent and no default value is given.
`:only`     | The scope will only be applied to these actions.
`:except`   | The scope will be applied to all actions except these.
`&block`    | Block will be called in the context of the action and will be given the model and value.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/scopable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
