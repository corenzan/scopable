require 'minitest/autorun'
require 'active_support/testing/declarative'

require_relative '../lib/scopable'

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
    end
    assert_equal(:car, vehicle_scope.new.apply)
  end

  test '.apply is a shorthand of #initialize + #apply' do
    vehicle_scope = Class.new(Scopable) do
      model :bike
    end
    assert_equal(:bike, vehicle_scope.apply)
  end

  test 'no matching scope passes through' do
    pet = OpenStruct.new(mammal: nil)
    pet_scope = Class.new(Scopable) do 
      model pet
      scope :mammal=
    end
    assert_nil(pet_scope.apply.mammal)
  end

  test 'no options' do
    person = OpenStruct.new(profile: nil)
    person_scope = Class.new(Scopable) do 
      model person
      scope :profile=
    end
    person_scope.apply('profile=' => 'fat')
    assert_equal('fat', person.profile)
  end

  test 'truthy values' do
    user = OpenStruct.new(active: nil)
    user_scope = Class.new(Scopable) do 
      model user
      scope :active=
    end
    user_scope.apply('active=' => 'true')
    assert(user.active)
    user_scope.apply('active=' => 'yes')
    assert(user.active)
    user_scope.apply('active=' => 'on')
    assert(user.active)
  end

  test 'option :param' do
    book = OpenStruct.new(query: nil)
    book_scope = Class.new(Scopable) do 
      model book
      scope :query=, param: :q
    end
    book_scope.apply(q: 'mermaids')
    assert_equal('mermaids', book.query)
  end
end