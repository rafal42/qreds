require 'spec_helper'

RSpec.describe GrapeReducers::Endpoint do
  let(:endpoint) { MockEndpoint.new(params) }
  let(:collection) { MockCollection.new([2, 3, 1]) }

  describe '#sort' do
    subject { endpoint.sort(collection) }
    let(:params) do
      {
        'sort' => {
          'simple' => 'asc'
        }
      }
    end

    it { is_expected.to eq([1, 2, 3]) }

    context 'with dynamic sorting - no predefined sort' do
      subject { endpoint.sort(collection).map(&:value) }
      let(:collection) { MockCollection.new([2, 3, 1].map { |i| SimpleObject.new(i) })}
      let(:params) do
        {
          'sort' => {
            'some_field' => 'desc'
          }
        }
      end

      it { is_expected.to eq([3, 2, 1]) }
    end
  end

  describe '#filter' do
    subject { endpoint.filter(collection) }
    let(:params) do
      {
        'filters' => {
          'equality' => 2
        }
      }
    end

    it 'filters the collection' do
      is_expected.to eq([2])
    end

    context 'with dynamic filtering - no predefined filter' do
      subject { endpoint.filter(collection).map(&:value) }
      let(:collection) { MockCollection.new([1, 2, 3].map { |i| SimpleObject.new(i) })}
      let(:params) do
        {
          'filters' => {
            'some_field_eq' => 2
          }
        }
      end

      it { is_expected.to eq([2]) }
    end
  end
end
