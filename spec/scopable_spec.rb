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

  context 'with one optional scope set' do
    let :controller do
      Class.new(Controller) do
        scope :one
      end
    end

    context 'and no matching parameters' do
      let :action do
        controller.new
      end

      it 'skips the scope' do
        expect(action.scoped_model.scopes).to be_empty
      end
    end

    context 'and with one matching parameter' do
      let :action do
        controller.new(one: '1')
      end

      it 'applies the scope' do
        expect(action.scoped_model.scopes.first).to eq([:one, '1'])
      end
    end
  end
end
