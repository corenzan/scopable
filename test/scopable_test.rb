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

  test 'one scope, matching parameter' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    params = { fuzzy: 'fuzzy' }
    assert_scope(scopable.apply(params), :fuzzy, 'fuzzy')
  end

  test 'multiple scopes, matching parameters' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {}, jumbo: {})
    params = { fuzzy: 'fuzzy', jumbo: 'jumbo' }
    assert_scope(scopable.apply(params), :fuzzy, 'fuzzy')
    assert_scope(scopable.apply(params), :jumbo, 'jumbo')
  end

  test 'multiple scopes, missing one parameter' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {}, jumbo: {})
    params = { jumbo: 'jumbo' }
    assert_scope(scopable.apply(params), :jumbo, 'jumbo')
    refute_scope(scopable.apply(params), :fuzzy)
  end

  test 'matching param with blank value' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    params = { fuzzy: '' }
    refute_scope(scopable.apply(params), :fuzzy)
  end

  test 'absent param' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    refute_scope(scopable.apply, :fuzzy)
  end

  test 'matching param with true-like value' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    assert_scope(scopable.apply(fuzzy: 'on'), :fuzzy, true)
    assert_scope(scopable.apply(fuzzy: 'yes'), :fuzzy, true)
    assert_scope(scopable.apply(fuzzy: 'true'), :fuzzy, true)
  end

  test 'matching param with false-like value' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: {})
    assert_scope(scopable.apply(fuzzy: 'no'), :fuzzy, false)
    assert_scope(scopable.apply(fuzzy: 'off'), :fuzzy, false)
    assert_scope(scopable.apply(fuzzy: 'false'), :fuzzy, false)
  end

  test 'param option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { param: :f })
    params = { f: 'fuzzy' }
    assert_scope(scopable.apply(params), :fuzzy, 'fuzzy')
  end

  test 'value option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { value: 'fuzzy' })
    assert_scope(scopable.apply, :fuzzy, 'fuzzy')
  end

  test 'default option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { default: 'fuzzy' })
    assert_scope(scopable.apply, :fuzzy, 'fuzzy')
    params = { fuzzy: 'jumbo' }
    assert_scope(scopable.apply(params), :fuzzy, 'jumbo')
  end

  test 'required option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { required: true })
    assert_equal(:none, scopable.apply)
    params = { fuzzy: 'fuzzy' }
    assert_scope(scopable.apply(params), :fuzzy, 'fuzzy')
  end

  test 'if option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { if: -> { params[:quack] } })
    params = { fuzzy: 'fuzzy' }
    refute_scope(scopable.apply(params), :fuzzy)
    params = { fuzzy: 'fuzzy', quack: true }
    assert_scope(scopable.apply(params), :fuzzy, 'fuzzy')
  end

  test 'unless option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { unless: -> { params[:quack] } })
    params = { fuzzy: 'fuzzy', quack: true }
    refute_scope(scopable.apply(params), :fuzzy)
    params = { fuzzy: 'fuzzy' }
    assert_scope(scopable.apply(params), :fuzzy, 'fuzzy')
  end

  test 'block option' do
    model = Model.new
    scopable = Scopable.new(model, fuzzy: { block: -> { jumbo(value) } })
    params = { fuzzy: 'fuzzy' }
    assert_scope(scopable.apply(params), :jumbo, 'fuzzy')
  end
end
