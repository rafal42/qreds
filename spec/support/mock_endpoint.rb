class MockEndpoint
  include Qreds::Endpoint

  def initialize(params)
    @params = params
  end

  def declared(params, **_)
    params.with_indifferent_access
  end

  attr_reader :params
end
