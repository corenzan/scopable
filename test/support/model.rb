class Model
  def self.scopes
    @scopes ||= {}
  end

  def self.scope(name)
    define_singleton_method(name) do |value = true|
      scopes.store(name, value)
    end
  end
end