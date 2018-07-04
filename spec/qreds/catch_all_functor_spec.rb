require 'spec_helper'

RSpec.describe Qreds::CatchAllFunctor do
  subject { described_class.new(query, value, context, key, config).call.map(&:value) }

  let(:query) { MockCollection.new((1..3).map { |i| SimpleObject.new(i) }) }
  let(:key) { 'some_field' }
  let(:value) { 2 }
  let(:context) { {} }
  let(:base_config) do
    {
      default_lambda: ->(collection, attr_name, value, operator, context) do
        operator = '==' if operator.nil?
        collection.select { |x| x.public_send(attr_name).public_send(operator, value) }
      end
    }
  end
  let(:config) { Qreds::Config.new(base_config) }

  it "calls given lambda and returns it's value" do
    is_expected.to eq([2])
  end

  context 'when config has operator mapping' do
    let(:config) do
      Qreds::Config.new(
        **base_config,
        operator_mapping: {
          'gte' => '>='
        }
      )
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
