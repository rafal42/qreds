require 'spec_helper'

RSpec.describe GrapeReducers::CatchAllFunctor do
  subject { described_class.new(collection, key, value, config).call.map(&:value) }

  let(:collection) { MockCollection.new((1..3).map { |i| SimpleObject.new(i) }) }
  let(:key) { 'some_field' }
  let(:value) { 2 }
  let(:base_config) do
    {
      default_lambda: ->(collection, attr_name, value, operator) do
        operator = '==' if operator.nil?
        collection.select { |x| x.public_send(attr_name).public_send(operator, value) }
      end
    }
  end
  let(:config) { base_config }

  it "calls given lambda and returns it's value" do
    is_expected.to eq([2])
  end

  context 'when config has operator mapping' do
    let(:config) do
      {
        **base_config,
        operator_mapping: {
          'gte' => '>='
        }
      }
    end

    it 'raises a RuntimeError' do
      expect { subject }.to raise_error(RuntimeError)
    end

    context 'when operator is used as key suffix' do
      let(:key) { 'some_field_gte' }

      it { is_expected.to eq([2, 3]) }
    end
  end
end
