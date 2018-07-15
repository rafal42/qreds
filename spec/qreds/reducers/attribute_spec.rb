require 'spec_helper'

RSpec.describe Qreds::Reducers::Attribute do
  let(:attribute) { described_class.new(attr_name) }
  let(:attr_name) { 'value' }

  describe '#sendable_name' do
    subject { attribute.sendable_name }

    it { is_expected.to eq(attr_name) }

    context 'when attr_name has 2 dot-separated terms' do
      let(:attr_name) { 'one.value' }

      it { is_expected.to eq('ones.value') }
    end

    context 'when attr_name has 3 dot-separated terms' do
      let(:attr_name) { 'one.two.value' }

      it { is_expected.to eq('twos.value') }
    end

    context 'when attr_name has more separated terms' do
      let(:attr_name) { 'one.two.three.four.five.value' }

      it { is_expected.to eq('fives.value') }
    end
  end

  describe '#apply_joins' do
    let(:query) { MockQuery.new }
    subject { attribute.apply_joins(query).explain }

    it do
      is_expected.to eq(
        where: {},
        order: {},
        joins: [],
        group: []
      )
    end

    context 'when there are two terms in attr_name' do
      let(:attr_name) { 'one.value' }

      it 'applies joins and group' do
        is_expected.to eq(
          where: {},
          order: {},
          joins: [{'one' => {}}],
          group: %i[id]
        )
      end
    end

    context 'when there are three terms in attr_name' do
      let(:attr_name) { 'one.two.value' }

      it 'applies joins and group' do
        is_expected.to eq(
          where: {},
          order: {},
          joins: [{'one' => { 'two' => {} }}],
          group: %i[id]
        )
      end
    end
  end
end
