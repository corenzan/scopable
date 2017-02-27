require 'active_support/all'
require_relative '../lib/scopable.rb'
require_relative 'support/controller.rb'
require_relative 'support/model.rb'

describe Scopable do
  it 'creates class variable #scopes' do
    expect(Controller).to respond_to(:scopes)
    expect(Controller.scopes).to eq({})
  end

  it 'adds class method #scope' do
    expect(Controller).to respond_to(:scope)
  end

  it 'adds instance method #scoped' do
    expect(Controller.new).to respond_to(:scoped)
  end

  #
  # Test single scope, no options, with and without matching parameters.
  #
  describe 'with one optional scope' do
    let :controller do
      Class.new(Controller) do
        scope :search
      end
    end

    context 'without matching parameters' do
      subject :action do
        controller.new
      end

      it 'should skip the scope' do
        expect(action.relation.scopes).to be_empty
      end
    end

    context 'with one matching parameter' do
      subject :action do
        controller.new(nil, search: 'test')
      end

      it 'should apply the scope' do
        expect(action.relation.scopes).to include(search: 'test')
      end
    end
  end

  #
  # Test two optional scopes, with 0, 1, and 2 matching parameters.
  #
  describe 'with two optional scope' do
    let :controller do
      Class.new(Controller) do
        scope :search
        scope :page
      end
    end

    context 'with no matching parameters' do
      subject :action do
        controller.new
      end

      it 'should skip the scope' do
        expect(action.relation.scopes).to be_empty
      end
    end

    context 'with one matching parameter' do
      subject :action do
        controller.new(nil, search: 'test')
      end

      it 'should apply one of the scopes' do
        expect(action.relation.scopes.size).to eq(1)
        expect(action.relation.scopes).to include(search: 'test')
      end
    end

    context 'with two matching parameters' do
      subject :action do
        controller.new(nil, search: 'test', page: 2)
      end

      it 'should apply both scopes' do
        expect(action.relation.scopes.size).to eq(2)
        expect(action.relation.scopes).to include(search: 'test', page: 2)
      end
    end
  end

  #
  # Test :required option.
  #
  describe 'with :required option' do
    let :controller do
      Class.new(Controller) do
        scope :active, required: true
      end
    end

    context 'with no matching parameters' do
      subject :action do
        controller.new
      end

      it 'should apply #none' do
        expect(action.relation.scopes).to include(none: true)
      end
    end

    context 'with one parameter matching' do
      subject :action do
        controller.new(nil, active: 'yes')
      end

      it 'should apply one of the scopes' do
        expect(action.relation.scopes.size).to eq(1)
        expect(action.relation.scopes).to include(active: true)
      end
    end
  end

  #
  # Test :except option.
  #
  describe 'with :except option' do
    let :controller do
      Class.new(Controller) do
        scope :filter, except: :index
      end
    end

    context 'with matching parameter in the exception action' do
      subject :action do
        controller.new(:index, filter: 'yes')
      end

      it 'should skip the scope' do
        expect(action.relation.scopes).to be_empty
      end
    end

    context 'with matching parameter in a different action' do
      subject :action do
        controller.new(nil, filter: 'yes')
      end

      it 'should apply the scope' do
        expect(action.relation.scopes).to include(filter: true)
      end
    end
  end

  #
  # Test :only option.
  #
  describe 'with :only option' do
    let :controller do
      Class.new(Controller) do
        scope :filter, only: :index
      end
    end

    context 'with matching parameter in the only action' do
      subject :action do
        controller.new(:index, filter: 'yes')
      end

      it 'should apply the scope' do
        expect(action.relation.scopes).to include(filter: true)
      end
    end

    context 'with matching parameter in a different action' do
      subject :action do
        controller.new(nil, filter: 'yes')
      end

      it 'should skip the scope' do
        expect(action.relation.scopes).to be_empty
      end
    end
  end

  #
  # Test :param option.
  #
  describe 'with :param option' do
    let :controller do
      Class.new(Controller) do
        scope :search, param: :q
      end
    end

    context 'with matching parameter' do
      subject :action do
        controller.new(nil, q: 'test')
      end

      it 'should apply the scope' do
        expect(action.relation.scopes).to include(search: 'test')
      end
    end

    context 'without matching parameter' do
      subject :action do
        controller.new(nil, search: 'test')
      end

      it 'should skip the scope' do
        expect(action.relation.scopes).to be_empty
      end
    end
  end

  #
  # Test :default option.
  #
  describe 'with :default option' do
    let :controller do
      Class.new(Controller) do
        scope :page, default: 1
      end
    end

    context 'with matching parameter' do
      subject :action do
        controller.new(nil, page: 2)
      end

      it 'should overwrite the default value' do
        expect(action.relation.scopes).to include(page: 2)
      end
    end

    context 'without matching parameter' do
      subject :action do
        controller.new(nil)
      end

      it 'should use the default value' do
        expect(action.relation.scopes).to include(page: 1)
      end
    end
  end

  #
  # Test :force option.
  #
  describe 'with :force option' do
    let :controller do
      Class.new(Controller) do
        scope :sort, force: :id
      end
    end

    context 'without matching parameter' do
      subject :action do
        controller.new(nil)
      end

      it 'should use the forced value' do
        expect(action.relation.scopes).to include(sort: :id)
      end
    end

    context 'with matching parameter' do
      subject :action do
        controller.new(nil, sort: :name)
      end

      it 'should still use the forced value' do
        expect(action.relation.scopes).to include(sort: :id)
      end
    end
  end
end
