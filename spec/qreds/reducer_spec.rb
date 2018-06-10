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

  subject { described_class.new(args).call }

  let(:functor_group) { 'Filters' }
  let(:query) { MockCollection.new([1, 2, 3]) }
  let(:params) { { 'equality' => 1 } }

  it 'calls specified functor' do
    is_expected.to eq([1])
  end

  context 'when params is empty' do
    let(:params) { {} }

    it 'returns the collection unchanged' do
      is_expected.to eq(query)
    end
  end

  context 'when passed a different resource_name' do
    let(:resource_name) { 'DifferentMockModel' }
    let(:args) { base_args.merge(resource_name: resource_name) }

    it 'calls the different resource' do
      is_expected.to eq([2, 3])
    end
  end

  context 'when cannot find a class' do
    let(:query) { MockCollection.new((1..3).map { |i| SimpleObject.new(i) }) }
    let(:params) { { 'some_field' => 2 } }

    subject { described_class.new(args).call }

    it 'uses the config default lambda' do
      is_expected.to eq(['transformed'])
    end
  end
end
