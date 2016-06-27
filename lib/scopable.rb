 module Scopable
  extend ActiveSupport::Concern

  included do
    cattr_reader :scopes do
      Hash.new
    end

    helper_method :active_scopes
  end

  def active_scopes
    scopes.map do |name, scope|
      name if scope[:active]
    end.compact
  end

  def scoped(resource, params)
    scopes.reduce(resource) do |scoped_resource, scope|

      # Scopable expects a scope (method) with
      # the same name of the scope.
      name, scope = *scope

      # By default Scopable will look for
      # a parameter with same name of the scope.
      # You can provide a :param option to change that.
      param = scope[:param]

      # When the parameter is not present
      # you can set a default value.
      default = scope[:default]

      # When you don't want the value
      # coming in the request parameters.
      force = scope[:force]

      # When :required is true and
      # there's no value present and no
      # default set it will apply #none.
      # required = scope[:required]

      # Array with the names of actions
      # you'd like to ignore this scope.
      except = scope[:except]

      # Array with the names of actions
      # this scopes will be applied for.
      only = scope[:only]

      # The block will be invoked in the
      # context of the action and will receive
      # both the resource and the value of the scope.
      block = scope[:block]

      # A value can be forced, come from the
      # request parameters or have a default.
      value = force || params[param || name] || default

      # If value still nil and the scope
      # is required exit with #none.
      # break scoped_resource.none if required && value.nil?

      # Apple :only and :except rules.
      value = nil if except.present? && Array.wrap(except).map(&:to_s).include?(action_name)
      value = nil unless only.nil? || Array.wrap(only).map(&:to_s).include?(action_name)

      # Values like 'off', 'false' and 'no' are
      # considered signals to disable the scope
      # and treated like the value's empty.
      value = nil if value.to_s =~ /\A(false|no|off)\z/

      # Values like 'on', 'true' and 'yes' are
      # considered signals to tell the scope is binary:
      # either on or off, and receives no argument.
      value = true if value.to_s =~ /\A(true|yes|on)\z/

      if value.blank?
        scope.update(active: false)
        scoped_resource
      else
        scope.update(active: true)
        if block.present?
          instance_exec(scoped_resource, value, &block)
        else
          scoped_resource.send(name, value)
        end
      end
    end
  end

  module ClassMethods
    def scope(name, options = {}, &block)
      scopes.store name, options.merge(block: block)
    end
  end
end
