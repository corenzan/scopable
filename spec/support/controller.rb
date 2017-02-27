class Controller
  include Scopable

  def initialize(action_name = nil, params = {})
    @action_name, @params = action_name, params.freeze
  end

  def params
    @params
  end

  def action_name
    @action_name.to_s
  end

  def relation
    scoped(Model.new, params)
  end
end
