class Model
  def scopes
    @scopes ||= {}
  end

  def initialize(*attrs, &block)
    attrs.each do |name|
      define_singleton_method(name) do |value = true|
        scopes.store(name, value)
        self
      end
    end

    instance_exec(&block) if block_given?
  end
end
