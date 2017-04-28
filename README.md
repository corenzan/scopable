[![RubyGems](https://img.shields.io/gem/dt/scopable.svg?style=flat-square)](https://rubygems.org/gems/scopable)
[![Build](https://img.shields.io/travis/corenzan/scopable.svg?style=flat-square)](https://travis-ci.org/corenzan/scopable)
[![Code Climate](https://img.shields.io/codeclimate/github/corenzan/scopable.svg?style=flat-square)](https://codeclimate.com/github/corenzan/scopable)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/corenzan/scopable.svg?style=flat-square)](https://codeclimate.com/github/corenzan/scopable/coverage)

# Scopable

> Apply or skip model scopes based on options and request parameters.

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

First you need to set scopes in your controller:

```ruby
class PostsController < ApplicationController
  include Scopable

  scope :search, param: :q

  # ...
end
```

Then apply them when querying the model:

```ruby
class PostsController < ApplicationController
  include Scopable

  scope :search, param: :q

  def index
    @posts = scoped(Post, params)
  end
end
```

Now whenever the parameter `q` is present in `params`, the scope `#search` will be called on your model and given the value of `params[:q]` as argument. Otherwise you would have to write something like this:

```ruby
  if params[:q].present?
    @posts = Post.search(params[:q])
  else
    @posts = Post.all
  end
```

What would be fine, except you usually have multiple scopes, that might get combined depending on the presence or absence of parameters to produce the final query. Look how simple it becomes when using Scopable:

```ruby
class PostController < ApplicationController
  include Scopable

  # Filter by category.
  scope :category do |relation, value|
    relation.where(category_id: value.to_i)
  end

  # Fix N+1.
  scope :includes, force: :author

  # Pagination.
  scope :page, default: 1

  # Sort by creation date.
  scope :order, force: { created_at: :desc }

  def index
    @posts = scoped(Post, params)
  end
end
```

Now say a request is made looking like this:

```
/posts?category=2
```

The resulting query would be:

```ruby
Post.where(category_id: 2).includes(:author).page(1).order(created_at: :desc)
```

Please note that **order matters**. The scopes will be applied in the same order they are configured.

Also values like `true/false`, `on/off`, `yes/no` are **cast as boolean**, and when given a boolean value the scope is either called with no arguments or skipped entirely. For instance, if you set a scope like `scope :draft` then request the URL `/posts?draft=yes` it would be like just calling `Post.draft`. But if you request `/posts?draft=no` it does nothing.

### Options

No option is required. By default it assumes both scope and parameter have the same name.

Key         | Description
------------|--------------------------------------------------------------------------------------------------------------
`:param`    | Name of the parameter that activates the scope.
`:default`  | Default value for the scope in case the parameter is missing.
`:force`    | Force a value to the scope regardless of the request parameters.
`:required` | Calls `#none` on the model if parameter is absent (blank or nil) and there's no default value set.
`:only`     | String, Symbol or an Array of those. The scope will **only** be applied to these actions.
`:except`   | String, Symbol or an Array of those. The scope will be applied to all actions **except** these.
`&block`    | Block will be called in the context of the controller's action and will be given two parameters: the current relation and evaluated value.

## License

See [LICENSE](LICENSE).
