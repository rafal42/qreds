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
end
