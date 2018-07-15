require 'spec_helper'

RSpec.describe Qreds::Reducers::Filter do
  describe 'default lambda' do
    subject { described_class.(query, attr_name, value, operator, {}).explain }

    let(:query) { MockQuery.new }
    let(:attr_name) { 'some_field' }
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

      it 'calls where with the nested association, joins and groups properly' do
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
    subject { described_class.operator_mapping }

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
    subject { described_class.functor_group }

    it { is_expected.to eq('filters') }
  end
end
