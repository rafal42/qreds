require 'bundler/setup'
require 'qreds'

Bundler.require(:default, :test)

require_relative 'support/filters'
require_relative 'support/mock_endpoint'
require_relative 'support/mock_model'
require_relative 'support/mock_query'
require_relative 'support/sort'
