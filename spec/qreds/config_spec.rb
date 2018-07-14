require 'spec_helper'

RSpec.describe Qreds::Config do
  let(:query) { MockQuery.new }
  let(:attr_name) { 'some_field' }

  describe '.define_reducer' do
    let(:reducer) do
      test_strategy = -> (_helper_name, config) { config }

      described_class.define_reducer(:test_reducer, strategy: test_strategy) do |config|
        config.operator_mapping = {}
      end
    end

    it 'creates a reducer with defaults and allows changing any other keys' do
      expect(reducer.functor_group).to eq(:test_reducer)
      expect(reducer.operator_mapping).to eq({})
    end
  end

  describe 'sorting reducer' do
    let(:reducer) { described_class[:sort] }

    describe 'default lambda' do
      subject { reducer.default_lambda.call(query, attr_name, value, nil, {}).explain }
      let(:value) { 'desc' }

      it 'calls order with attr name and value' do
        is_expected.to eq(
          where: {},
          order: {
            'some_field' => value
          },
          joins: [],
          group: []
        )
      end
    end
  end

  describe 'filtering reducer' do
    let(:reducer) { described_class[:filter] }

    describe 'default lambda' do
      subject { reducer.default_lambda.call(query, attr_name, value, operator, {}).explain }

      let(:value) { 2 }
      let(:operator) { '> ?' }

      it 'calls where with attr name, value and operator' do
        is_expected.to eq(
          where: {
            'some_field > ?' => [value]
          },
          order: {},
          joins: [],
          group: []
        )
      end

      context 'when translated operator has more than one "?"' do
        let(:operator) { 'BETWEEN ? AND ?' }
        let(:value) { [2, 3] }

        it do
          is_expected.to eq(
            where: {
              'some_field BETWEEN ? AND ?' => value
            },
            order: {},
            joins: [],
            group: []
          )
        end
      end

      context 'when passing a nested association' do
        let(:attr_name) { 'an_association.another_association.some_field' }
        let(:value) { 6 }

        it 'calls where with the nested association and joins with it' do
          is_expected.to eq(
            where: {
              'another_association.some_field > ?' => [value]
            },
            order: {},
            joins: [{
              'an_association' => { 'another_association' => {} }
            }],
            group: %i[id]
          )
        end
      end
    end

    describe 'operator mapping' do
      subject { reducer.operator_mapping }

      it 'is suited to work with PostgreSQL' do
        is_expected.to eq(
          'lt' => '< ?',
          'lte' => '<= ?',
          'eq' => '= ?',
          'gt' => '> ?',
          'gte' => '>= ?',
          'in' => 'IN (?)',
          'btw' => 'BETWEEN ? AND ?'
        )
      end
    end

    describe 'functor_group' do
      subject { reducer.functor_group }

      it { is_expected.to eq('filters') }
    end
  end
end
