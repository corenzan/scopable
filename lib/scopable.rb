module Scopable
  extend ActiveSupport::Concern

  def scopes
    self.class.scopes
  end

  def scoped(model, params)
    scopes.reduce(model) do |relation, scope|
      name, options = *scope

      # Controller actions where this scope should be applied.
      # Accepts either a literal value or a lambda. nil with disable the option.
      only = options[:only]
      only = instance_exec(&only) if only.respond_to?(:call)

      # Enfore :only option.
      next relation unless only.nil? || Array.wrap(only).map(&:to_s).include?(action_name)

      # Controller actions where this scope should be ignored.
      # Accepts either a literal value or a lambda. nil with disable the option.
      except = options[:except]
      except = instance_exec(&except) if except.respond_to?(:call)

      # Enfore :except option.
      next relation if except.present? && Array.wrap(except).map(&:to_s).include?(action_name)

      # Name of the request parameters which value will be used in this scope.
      # Defaults to the name of the scope.
      param = options.fetch(:param, name)

      # Use the value from the request parameter or fall back to the default.
      value = params[param]

      # If parameter is not present use the :default option.
      # Accepts either a literal value or a lambda.
      value = options[:default] if value.nil?

      # Forces the scope to use the given value given in the :force option.
      # Accepts either a literal value or a lambda.
      value = options[:force] if options.key?(:force)

      # If either :default or :force options were procs, evaluate them.
      value = instance_exec(&value) if value.respond_to?(:call)

      # The :required option makes sure there's a value present, otherwise return an empty scope (Model#none).
      required = options[:required]
      required = instance_exec(&required) if required.respond_to?(:call)

      # Enforce the :required option.
      break relation.none if required && value.nil?

      # Parses values like 'on/off', 'true/false', and 'yes/no' to an actual boolean value.
      case value.to_s
      when /\A(false|no|off)\z/
        value = false
      when /\A(true|yes|on)\z/
        value = true
      end

      # For advanced scopes that require more than a method call on the model.
      # When a block is given, it is ran no matter the scope value.
      # The proc will be given the model being scoped and the resulting value from the options above, and it'll be executed inside the context of the controller's action.
      block = options[:block]

      if block.nil? && value.nil?
        next relation
      end

      case
      when block.present?
        instance_exec(relation, value, &block)
      when value == true
        relation.send(name)
      else
        relation.send(name, value)
      end
    end
  end

  module ClassMethods
    def scopes
      @scopes ||= {}
    end

    def scope(name, options = {}, &block)
      scopes.store name, options.merge(block: block)
    end
  end
end
