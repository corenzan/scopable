class Controller
  attr_accessor :params

  def initialize(params = {})
    @params = params.freeze
  end

  def self.helper_method(*args)
  end

  include Scopable

  def scoped_model
    scoped(Model, params)
  end
end
