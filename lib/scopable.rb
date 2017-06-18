require 'active_support'
require 'active_support/core_ext'

class Scopable
  def initialize(model = nil)
    @model = model || self.class.model
  end

  def apply(params = {})
    params.symbolize_keys!
    self.class.scopes.reduce(@model) do |relation, scope|
      name, options = *scope

      # Resolve param name.
      param = options[:param] || name

      # Resolve a value for the scope.
      value = options[:value] || params[param] || options[:default]

      if value.nil?
        options[:required] ? relation.none : relation
      elsif options[:block].present?
        options[:block].call(relation, value)
      elsif value == true
        relation.send(name)
      else
        relation.send(name, value)
      end
    end
  end

  def self.apply(params = {})
    new.apply(params)
  end

  def self.model(model = nil)
    @model ||= model
  end

  def self.scopes
    @scopes ||= {}
  end

  def self.scope(name, options = {}, &block)
    scopes.store name, options.merge(block: block)
  end
end
