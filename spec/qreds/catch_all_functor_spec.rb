require 'spec_helper'

RSpec.describe Qreds::CatchAllFunctor do
  subject { described_class.new(query, value, context, key, config).call.explain }

  let(:query) { MockQuery.new }
  let(:key) { 'some_field' }
  let(:value) { 2 }
  let(:context) { {} }
  let(:base_config) do
    {
      default_lambda: ->(query, attr_name, value, operator, context) do
        operator = '==' if operator.nil?
        query.where("#{attr_name} #{operator} ?", value)
      end
    }
  end
  let(:config) { Qreds::Config.new(base_config) }

  it "calls given lambda and returns it's value" do
    is_expected.to eq(
      where: {
        'some_field == ?' => [value]
      },
      order: {},
      joins: [],
      group: []
    )
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

      it "calls given lambda and returns it's value" do
        is_expected.to eq(
          where: {
            'some_field >= ?' => [value]
          },
          order: {},
          joins: [],
          group: []
        )
      end
    end
  end
end
