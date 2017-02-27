class Model
  def scopes
    @scopes ||= {}
  end

  def method_missing(name, value = true)
    scopes.store(name, value)
    self
  end
end
