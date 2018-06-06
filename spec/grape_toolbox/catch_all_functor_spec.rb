require 'spec_helper'

RSpec.describe GrapeReducers::CatchAllFunctor do
  subject { described_class.new(collection, key, value, method_name).call.map(&:value) }

  let(:collection) { MockCollection.new((1..3).map { |i| SimpleObject.new(i) }) }
  let(:key) { 'some_field' }
  let(:value) { 2 }
  let(:method_name) { :where }

  it 'applies given method with key and value' do
    is_expected.to eq([2])
  end
end
