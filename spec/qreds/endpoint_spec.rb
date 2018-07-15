require 'spec_helper'

RSpec.describe Qreds::Endpoint do
  let(:endpoint) { MockEndpoint.new(params) }
  let(:query) { MockQuery.new }
  let(:reducer) { double }
  let(:reduced_query) { double }

  describe '#sort' do
    subject { endpoint.sort(query) }
    let(:params) do
      {
        'sort' => {
          'simple' => 'asc'
        }
      }
    end

    it 'builds a reducer, calls it and returns the call value' do
      expect(Qreds::Reducer).to receive(:new).with(
        query: query,
        params: {
          'simple' => 'asc'
        },
        config: Qreds::Config[:sort],
        context: {}
      ).and_return(reducer)
      expect(reducer).to receive(:call).and_return(reduced_query)

      is_expected.to be(reduced_query)
    end

    it 'properly reduces the query' do
      expect(subject.explain).to eq(
        where: {},
        order: { 'simple' => 'asc' },
        joins: [],
        group: []
      )
    end
  end

  describe '#filter' do
    subject { endpoint.filter(query) }
    let(:params) do
      {
        'filters' => {
          'equality' => 2
        }
      }
    end

    it 'builds a reducer, calls it and returns the call value' do
      expect(Qreds::Reducer).to receive(:new).with(
        query: query,
        params: {
          'equality' => 2
        },
        config: Qreds::Config[:filter],
        context: {}
      ).and_return(reducer)

      expect(reducer).to receive(:call).and_return(reduced_query)

      is_expected.to be(reduced_query)
    end

    it 'properly reduces the query' do
      expect(subject.explain).to eq(
        where: { 'equality' => 2 },
        order: {},
        joins: [],
        group: []
      )
    end
  end
end
