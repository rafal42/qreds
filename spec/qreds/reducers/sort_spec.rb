require 'spec_helper'

RSpec.describe Qreds::Reducers::Sort do
  describe 'default lambda' do
    let(:query) { MockQuery.new }
    let(:attr_name) { 'some_field' }
    let(:value) { 'desc' }

    subject { described_class.(query, attr_name, value, nil, {}).explain }

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
