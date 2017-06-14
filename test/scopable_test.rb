require 'minitest/autorun'
require 'active_support/testing/declarative'

require_relative '../lib/scopable'
require_relative 'support/model'

class TestModel < Minitest::Test
  extend ActiveSupport::Testing::Declarative

  test 'defines class method' do
    Pie = Class.new(Model) do
      scope :tasty
    end
    assert_respond_to(Pie, :tasty)
  end

  test 'tracks scope calls' do
    Person = Class.new(Model) do
      scope :age
    end
    Person.age(21)
    assert_equal(21, Person.scopes[:age])
  end
end

class TestScopable < Minitest::Test
  extend ActiveSupport::Testing::Declarative

  test '#initialize' do
    PostScope = Class.new(Scopable) do 
      model :post
    end
    assert_equal(:post, PostScope.new.instance_variable_get(:@model))
    assert_equal(:article, PostScope.new(:article).instance_variable_get(:@model))
  end

  test '#apply and .apply' do
    CarScope = Class.new(Scopable) do
      model :car
    end
    assert_raises(ArgumentError) do
      CarScope.new.apply
    end
    assert_equal(:car, CarScope.new.apply({}))
    assert_equal(:car, CarScope.apply({}))
  end

  test 'no options' do
    User = Class.new(Model) do
      scope :active
    end
    UserScope = Class.new(Scopable) do 
      model User
      scope :active
    end
    UserScope.apply(active: true)
    assert_equal(User.scopes[:active], true)
  end

  test 'param option' do
    Content = Class.new(Model) do
      scope :search
    end
    ContentScope = Class.new(Scopable) do 
      model Content
      scope :search, param: :q
    end
    ContentScope.apply(q: 'mermaids')
    assert_equal('mermaids', Content.scopes[:search])
  end
end