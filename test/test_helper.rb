require 'simplecov'

# Generate coverage report.
SimpleCov.start

require 'minitest/autorun'
require 'active_support/testing/declarative'

# Mock model for testing scope chains.
class Model
  def scopes
    @scopes ||= {}
  end

  def fuzzy(value = true)
    scopes.store(:fuzzy, value)
    self
  end

  def jumbo(value = true)
    scopes.store(:jumbo, value)
    self
  end

  def all
    scopes.store(:all, true)
    self
  end

  def none
    :none
  end
end

# Load the Gem.
require_relative '../lib/scopable'

# Run test suite.
require_relative 'scopable_test'
