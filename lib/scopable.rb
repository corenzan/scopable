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

      value = options[:value] || params[options[:param] || name] || options[:default]

      case
      when options[:block].present?
        block.call(relation, value)
      when value == true
        relation.send(name)
      when value.present?
        relation.send(name, value)
      when options[:required]
        relation.none
      else
        relation
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
