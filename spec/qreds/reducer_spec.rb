require 'spec_helper'

RSpec.describe Qreds::Reducer do
  let(:base_args) do
    {
      query: query,
      params: params,
      config: config
    }
  end
  let(:args) { base_args }
  let(:fallback_method) { nil }

  let(:config) do
    Qreds::Config.new(
      default_lambda: ->(*_) { ['transformed'] },
      functor_group: functor_group
    )
  end

  subject { described_class.new(args).call.explain }

  let(:functor_group) { 'Filters' }
  let(:query) { MockQuery.new }
  let(:params) { { 'equality' => 1 } }

  it 'calls specified functor' do
    is_expected.to eq(
      where: { 'equality' => 1 },
      order: {},
      joins: [],
      group: []
    )
  end

  context 'when params is empty' do
    let(:params) { {} }

    it 'does not apply any changes' do
      is_expected.to eq(
        where: {},
        order: {},
        joins: [],
        group: []
      )
    end
  end

  context 'when passed a different resource_name' do
    let(:resource_name) { 'DifferentMockModel' }
    let(:args) { base_args.merge(resource_name: resource_name) }

    it 'calls the different resource' do
      is_expected.to eq(
        where: { 'equality != ?' => [1] },
        order: {},
        joins: [],
        group: []
      )
    end
  end

  context 'when cannot find a functor' do
    let(:query) do
      MockQuery.new.tap do |q|
        def q.model
          Integer
        end
      end
    end

    let(:params) { { 'some_field' => 2 } }

    subject { described_class.new(args).call }

    it 'uses the config default lambda' do
      is_expected.to eq(['transformed'])
    end
  end
end
