[![RubyGems](https://img.shields.io/gem/dt/scopable.svg?style=flat)](https://rubygems.org/gems/scopable)
[![Build](https://img.shields.io/travis/corenzan/scopable.svg?style=flat)](https://travis-ci.org/corenzan/scopable)
[![Code Climate](https://img.shields.io/codeclimate/github/corenzan/scopable.svg?style=flat)](https://codeclimate.com/github/corenzan/scopable)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/corenzan/scopable.svg?style=flat)](https://codeclimate.com/github/corenzan/scopable/coverage)

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

## About

**Scopable** is useful when you need to build one or more queries based on incoming parameters in the request. Very much like [has_scope](https://github.com/plataformatec/has_scope) except it's decoupled from the controller, making it easier to test and much more flexible.

### Example

Say you have a model and a controller for your blog. Something like this:

```
└── app
    ├── models
        └── post.rb
    └── controllers
        └── posts_controller.rb
```

First let's create a new directory named `scopes` along with `models` and `controllers`. There you create a file called `post_scope.rb`, and inside it you define a class that inherits from `Scopable`.

```ruby
class PostScope < Scopable
  model Post

  scope :search do
    where('title LIKE ?', value)
  end

  scope :published_on do
    where(published_at: value.to_time)
  end
end
```

Finally, in `PostsController` you use `PostScope` to conditionally apply the scopes based on incoming parameters.

```ruby
class PostsController < ApplicationController
  def index
    @posts = PostScope.apply(scope_params)
  end

  private

  def scope_params
    params.permit(:search, :published_on).to_h
  end
end
```

Now when any combination of the parameters `search` and `published_on` are present, their conditions are going to be applied. i.e. If youre request path looks like this:

```
/?search=bananas&published_on=2007-07-19
```

`@posts` is going to be same as:

```
Post.where('title LIKE ?', 'bananas').where(published_on: '2007-07-19 00:00:00 +0000')
```

You can also set some options when you're defining scopes for more advanced use cases. Read on.

#### Options

Key         | Description
------------|--------------------------------------------------------------------------------------------------------------
`:param`    | Name of the parameter that activates the scope.
`:default`  | Default value for the scope in case the parameter is missing.
`:value`    | Force a value to the scope regardless of the request parameters.
`:required` | Calls `#none` on the model if parameter is absent (blank or nil) and there's no default value set.
`:if`       | ...
`:unless`   | ...
`&block`    | Block will be used to produce the resulting relation with two parameters: the relation at this step and the scope value from params.

## Collaboration

If you'd like to contribute to the project, in any form, you're most welcome, but please bear in mind that as it is with any open-source software your suggestions are subject to the discretion of the project maintainers, and what you see as an issue, someone else may see as a feature.

We encourage you to:

- Open a new issue with suggestions, concerns, or problems you may have.
- Chip in existing discussions and present your opinion on the subject.
- Send pull-requests with test covered bug fixes or new features.
- Send pull-requests with new tests you miss in the suite.

Remember to:

- Be respectful.
- Use proper grammar in discussions and in commit messages.
- Follow the established coding style.
- Explain why you're making the changes in a pull-request.

## License

[The MIT License](LICENSE.md) © 2013 Arthur Corenzan
