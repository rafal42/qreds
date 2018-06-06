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

    it 'sorts the collection' do
      is_expected.to eq([1, 2, 3])
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
  end
end
