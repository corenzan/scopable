# Scopable

> Apply scopes to your query based on available parameters

[![Code Climate](https://codeclimate.com/github/haggen/scopable/badges/gpa.svg)](https://codeclimate.com/github/haggen/scopable)
[![Test Coverage](https://codeclimate.com/github/haggen/scopable/badges/coverage.svg)](https://codeclimate.com/github/haggen/scopable/coverage)
[![Build](https://travis-ci.org/haggen/scopable.svg)](https://travis-ci.org/haggen/scopable)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scopable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scopable

## Usage

Configure scopes in your controller:

```ruby
class PostsController < ApplicationController
  include Scopable

  scope :search, :param => :q

  # ...
end
```

Then apply it to your model:

```ruby
def index
  @posts = scoped(Post, params)
end
```

Now, whenever the parameter `q` is present at `params`, it will call `#search` on your model passing its value as argument.

TODO: Add more examples.
TODO: Layout `scope` options.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/scopable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
