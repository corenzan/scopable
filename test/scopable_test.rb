require 'minitest/autorun'
require 'active_support/testing/declarative'
require 'simplecov'

SimpleCov.start

require_relative '../lib/scopable'
require_relative 'support/model'

class TestModel < Minitest::Test
  extend ActiveSupport::Testing::Declarative

  test '#initialize' do
    model = Model.new
    assert_instance_of(Model, model)
  end

  test '#scopes' do
    model = Model.new
    assert_respond_to(model, :scopes)
  end

  test 'scope' do
    model = Model.new(:scope)
    assert_instance_of(Model, model.scope)
    assert_equal(true, model.scopes[:scope])
  end

  test 'multiple scopes' do
    model = Model.new(:a, :b, :c)
    assert_respond_to(model, :a)
    assert_respond_to(model, :b)
    assert_respond_to(model, :c)
  end
end

class TestScopable < Minitest::Test
  extend ActiveSupport::Testing::Declarative

  test '#initialize with zero arguments' do
    polygon_scope = Class.new(Scopable) do
      model :square
    end
    assert_equal(:square, polygon_scope.new.instance_variable_get(:@model))
  end

  test '#initialize with 1 argument' do
    polygon_scope = Class.new(Scopable) do
      model :square
    end
    assert_equal(:circle, polygon_scope.new(:circle).instance_variable_get(:@model))
  end

  test '#apply with empty params passes through' do
    vehicle_scope = Class.new(Scopable) do
      model :car
      scope :year
      scope :model
    end
    assert_equal(:car, vehicle_scope.new.apply)
  end

  test '.apply is a shorthand of #initialize + #apply' do
    vehicle_scope = Class.new(Scopable) do
      model :bike
    end
    assert_equal(:bike, vehicle_scope.apply)
  end

  test 'without matching scope passes through' do
    pet = Model.new(:mammal)
    pet_scope = Class.new(Scopable) do
      model pet
      scope :mammal
    end
    assert_nil(pet_scope.apply.scopes[:mammal])
  end

  test 'no options' do
    person = Model.new(:profile)
    person_scope = Class.new(Scopable) do
      model person
      scope :profile
    end
    assert_equal('fat', person_scope.apply(profile: 'fat').scopes[:profile])
  end

  test 'truthy values' do
    user = Model.new(:active)
    user_scope = Class.new(Scopable) do
      model user
      scope :active
    end
    assert_equal(true, user_scope.apply(active: 'true').scopes[:active])
    assert_equal(true, user_scope.apply(active: 'yes').scopes[:active])
    assert_equal(true, user_scope.apply(active: 'on').scopes[:active])
  end

  test 'falsy values' do
    user = Model.new(:active)
    user_scope = Class.new(Scopable) do
      model user
      scope :active
    end
    assert_equal(false, user_scope.apply(active: 'false').scopes[:active])
    assert_equal(false, user_scope.apply(active: 'no').scopes[:active])
    assert_equal(false, user_scope.apply(active: 'off').scopes[:active])
  end

  test 'option :param' do
    book = Model.new(:query)
    book_scope = Class.new(Scopable) do
      model book
      scope :query, param: :q
    end
    assert_equal('mermaids', book_scope.apply(q: 'mermaids').scopes[:query])
  end

  test 'option :value' do
    file = Model.new(:name)
    file_scope = Class.new(Scopable) do
      model file
      scope :name, value: 'a file'
    end
    assert_equal('a file', file_scope.apply(name: 'explorer.exe').scopes[:name])
  end

  test 'option :default' do
    directory = Model.new(:name)
    directory_scope = Class.new(Scopable) do
      model directory
      scope :name, default: 'system32'
    end
    assert_equal('system32', directory_scope.apply.scopes[:name])
    assert_equal('windows', directory_scope.apply(name: 'windows').scopes[:name])
  end

  test 'option :required' do
    account = Model.new(:number) do
      def none
        :none
      end
    end
    account_scope = Class.new(Scopable) do
      model account
      scope :number, required: true
    end
    assert_equal(:none, account_scope.apply)
    assert_equal('123', account_scope.apply(number: '123').scopes[:number])
  end

  test 'option :if' do
    record = Model.new(:sealed)
    record_scope = Class.new(Scopable) do
      model record
      scope :sealed, if: -> { params[:lawyer] }
    end
    assert_nil(record_scope.apply(sealed: true).scopes[:sealed])
    assert_equal(true, record_scope.apply(sealed: true, lawyer: true).scopes[:sealed])
  end

  test 'option :unless' do
    record = Model.new(:sealed)
    record_scope = Class.new(Scopable) do
      model record
      scope :sealed, unless: -> { !params[:lawyer] }
    end
    assert_nil(record_scope.apply(sealed: true).scopes[:sealed])
    assert_equal(true, record_scope.apply(sealed: true, lawyer: true).scopes[:sealed])
  end

  test 'option :block' do
    flower = Model.new(:family, :color)
    flower_scope = Class.new(Scopable) do
      model flower
      scope :romantic do
        family('Rosaceae').color('red')
      end
    end
    assert_equal('red', flower_scope.apply(romantic: true).scopes[:color])
    assert_equal('Rosaceae', flower_scope.apply(romantic: true).scopes[:family])
  end
end
