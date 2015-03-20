require "scopable/version"

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
    scopes.reduce(resource) do |resource, scope|
      name, scope = *scope

      param, force, default, except, only, fn = scope.values_at(:param, :force, :default, :except, :only, :fn)

      force = self.instance_exec(&force) if force.respond_to?(:call)

      param = param || name
      value = force || params[param] || default

      value = nil if except.present? && Array.wrap(except).map(&:to_s).include?(action_name)
      value = nil unless only.nil? || Array.wrap(only).map(&:to_s).include?(action_name)

      if value.nil? || value.to_s =~ /\A(false|no|off)\z/
        scope.update(:active => false)
        resource
      else
        scope.update(:active => true)

        value = nil if value == 'nil'

        if fn
          self.instance_exec(resource, value, &fn)
        else
          if value.to_s =~ /\A(true|yes|on)\z/
            resource.send(name)
          else
            resource.send(name, value)
          end
        end
      end
    end
  end

  module ClassMethods
    def scope(name, opts = {}, &fn)
      scopes.store name, opts.merge(:fn => fn)
    end
  end
end
