class Model
  def self.scopes
    @@scopes ||= {}
  end

  def self.method_missing(name, value)
    scopes.store(name, value)
    self
  end
end
