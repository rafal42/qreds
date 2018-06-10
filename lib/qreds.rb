module Qreds
  require 'bundler/setup'

  require 'active_support'
  require 'active_support/core_ext'

  require_relative 'qreds/config'
  require_relative 'qreds/functor'
  require_relative 'qreds/catch_all_functor'
  require_relative 'qreds/reducer'
  require_relative 'qreds/endpoint'
end
