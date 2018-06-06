require 'spec_helper'

RSpec.describe GrapeReducers::Reducer do
  let(:base_args) do
    {
      functor_group: functor_group,
      collection: collection,
      reducible: reducible,
      fallback_method: fallback_method
    }
  end
  let(:args) { base_args }
  let(:fallback_method) { nil }

  subject { described_class.new(args).call }

  let(:functor_group) { 'Filters' }
  let(:collection) { MockCollection.new([1, 2, 3]) }
  let(:reducible) { { 'equality' => 1 } }

  it 'calls specified functor' do
    is_expected.to eq([1])
  end

  context 'when reducible is empty' do
    let(:reducible) { {} }

    it 'returns the collection unchanged' do
      is_expected.to eq(collection)
    end
  end

  context 'when passed a different resource_name' do
    let(:resource_name) { 'DifferentMockModel' }
    let(:args) { base_args.merge(resource_name: resource_name) }

    it 'calls the different resource' do
      is_expected.to eq([2, 3])
    end
  end

  context 'when cannot find a class and fallback_method is eq to where' do
    let(:collection) { MockCollection.new((1..3).map { |i| SimpleObject.new(i) }) }
    let(:reducible) { { 'some_field' => 2 } }
    let(:fallback_method) { 'where' }

    subject { described_class.new(args).call.map(&:value) }

    it 'uses the fallback filter' do
      is_expected.to eq([2])
    end
  end

  context 'when cannot find a class and fallback_method is eq to order' do
    let(:collection) { MockCollection.new((1..3).map { |i| SimpleObject.new(i) }) }
    let(:reducible) { { 'some_field' => 'desc' } }
    let(:fallback_method) { 'order' }

    subject { described_class.new(args).call.map(&:value) }

    it 'uses the fallback sort' do
      is_expected.to eq([3, 2, 1])
    end
  end
end
