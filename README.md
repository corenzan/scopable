[![RubyGems](https://img.shields.io/gem/dt/scopable.svg?style=flat-square)](https://rubygems.org/gems/scopable)
[![Build](https://img.shields.io/travis/corenzan/scopable.svg?style=flat-square)](https://travis-ci.org/corenzan/scopable)
[![Maintainability](https://img.shields.io/codeclimate/maintainability/corenzan/scopable.svg?style=flat-square)](https://codeclimate.com/github/corenzan/scopable/maintainability)
[![Test Coverage](https://img.shields.io/codeclimate/c/corenzan/scopable.svg?style=flat-square)](https://codeclimate.com/github/corenzan/scopable/test_coverage)

# Scopable

> Easy parametric query building in Rails.

## Installation

Simply add it to your Gemfile.

```ruby
gem 'scopable'
```

And update your Gems.

```shell
$ bundle update
```

Please note that as of version 2.0 **the API has drastically changed**. If you're **already using version 1.x** and don't want to update your application right now, you should stick with it:

```ruby
gem 'scopable', '~> 1.0'
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

Finally, in `PostsController` you use `PostScope.resolve` to conditionally resolve the scopes based on given parameters.

```ruby
class PostsController < ApplicationController
  def index
    @posts = PostScope.resolve(scope_params)
  end

  private

  def scope_params
    params.permit(:search, :published_on).to_h
  end
end
```

Now when any combination of the parameters `search` and `published_on` are present, their respective conditions are going to be applied on the relation. i.e. If your request path looks like this:

```
/?search=bananas&published_on=2007-07-19
```

`@posts` will look like this:

```
Post.where('title LIKE ?', 'bananas').where(published_on: '2007-07-19 00:00:00 +0000')
```

You can also pass some options when you're defining scopes for more advanced use cases. Read on.

#### Options

Key         | Description
------------|--------------------------------------------------------------------------------------------------------------
`:param`    | Name of the parameter that activates the scope.
`:default`  | Default value for the scope in case the parameter is missing.
`:value`    | Force a value to the scope regardless of the request parameters.
`:required` | Calls `#none` on the model if parameter is absent (blank or nil) and there's no default value set.
`:if`       | ...
`:unless`   | ...
`&block`    | Block will be executed in the context of the relation plus two local methods `value` and `params`.

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
