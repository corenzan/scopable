class ScopableTest < Minitest::Test
  extend ActiveSupport::Testing::Declarative

  def assert_scope(scopable, scope, value)
    assert_includes(scopable.scopes, scope)
    assert_equal(value, scopable.scopes[scope])
  end

  def refute_scope(scopable, scope)
    refute_includes(scopable.scopes, scope)
    assert_nil(scopable.scopes[scope])
  end

  test 'initialize' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {}, jumbo: {})
    assert_equal(model, scopable.model)
    assert_includes(scopable.scopes, :fuzzy)
    assert_includes(scopable.scopes, :jumbo)
  end

  test 'dsl' do
    model = Model.new
    scopable = Class.new(Scopable) do
      model model
      scope :fuzzy
      scope :jumbo
    end
    assert_equal(model, scopable.new.model)
    assert_includes(scopable.new.scopes, :fuzzy)
    assert_includes(scopable.new.scopes, :jumbo)
  end

  test 'always call #all' do
    model = Model.new
    scopable = Scopable.new(model, {})
    params = {}
    assert_scope(scopable.resolve(params), :all, true)
  end

  test 'one scope, matching parameter' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    params = { fuzzy: 'fuzzy' }
    assert_scope(scopable.resolve(params), :fuzzy, 'fuzzy')
  end

  test 'multiple scopes, matching parameters' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {}, jumbo: {})
    params = { fuzzy: 'fuzzy', jumbo: 'jumbo' }
    assert_scope(scopable.resolve(params), :fuzzy, 'fuzzy')
    assert_scope(scopable.resolve(params), :jumbo, 'jumbo')
  end

  test 'multiple scopes, missing one parameter' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {}, jumbo: {})
    params = { jumbo: 'jumbo' }
    assert_scope(scopable.resolve(params), :jumbo, 'jumbo')
    refute_scope(scopable.resolve(params), :fuzzy)
  end

  test 'matching param with blank value' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    params = { fuzzy: '' }
    refute_scope(scopable.resolve(params), :fuzzy)
  end

  test 'absent param' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    refute_scope(scopable.resolve, :fuzzy)
  end

  test 'matching param with truthy value' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    assert_scope(scopable.resolve(fuzzy: 'on'), :fuzzy, true)
    assert_scope(scopable.resolve(fuzzy: 'yes'), :fuzzy, true)
    assert_scope(scopable.resolve(fuzzy: 'true'), :fuzzy, true)
  end

  test 'matching param with falsey value' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    refute_scope(scopable.resolve(fuzzy: 'no'), :fuzzy)
    refute_scope(scopable.resolve(fuzzy: 'off'), :fuzzy)
    refute_scope(scopable.resolve(fuzzy: 'false'), :fuzzy)
  end

  test 'param option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { param: :f })
    params = { f: 'fuzzy' }
    assert_scope(scopable.resolve(params), :fuzzy, 'fuzzy')
  end

  test 'value option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { value: 'fuzzy' })
    assert_scope(scopable.resolve, :fuzzy, 'fuzzy')
  end

  test 'default option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { default: 'fuzzy' })
    assert_scope(scopable.resolve, :fuzzy, 'fuzzy')
    params = { fuzzy: 'jumbo' }
    assert_scope(scopable.resolve(params), :fuzzy, 'jumbo')
  end

  test 'required option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { required: true })
    assert_equal(:none, scopable.resolve)
    params = { fuzzy: 'fuzzy' }
    assert_scope(scopable.resolve(params), :fuzzy, 'fuzzy')
  end

  test 'if option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { if: -> { params[:quack] } })
    params = { fuzzy: 'fuzzy' }
    refute_scope(scopable.resolve(params), :fuzzy)
    params = { fuzzy: 'fuzzy', quack: true }
    assert_scope(scopable.resolve(params), :fuzzy, 'fuzzy')
  end

  test 'unless option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { unless: -> { params[:quack] } })
    params = { fuzzy: 'fuzzy', quack: true }
    refute_scope(scopable.resolve(params), :fuzzy)
    params = { fuzzy: 'fuzzy' }
    assert_scope(scopable.resolve(params), :fuzzy, 'fuzzy')
  end

  test 'block option matching' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { block: -> { jumbo(value) } })
    params = { fuzzy: 'fuzzy' }
    assert_scope(scopable.resolve(params), :jumbo, 'fuzzy')
  end

  test 'block option miss' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { block: -> { jumbo(value) } })
    params = {}
    refute_scope(scopable.resolve(params), :jumbo)
  end

  test 'block option with falsey value' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { block: -> { jumbo(value) } })
    params = { fuzzy: false }
    refute_scope(scopable.resolve(params), :jumbo)
  end

  test 'block delegator' do
    model = Model.new
    params = { fuzzy: 'fuzzy' }
    scopable = Scopable.new(model, {})
    delegator = scopable.delegator(model, 'fuzzy', params)
    assert_respond_to(delegator, :all)
    assert_equal('fuzzy', delegator.value)
    assert_equal(params, delegator.params)
  end
end
