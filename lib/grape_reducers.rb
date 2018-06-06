module GrapeReducers
  require 'bundler/setup'

  require 'active_support'
  require 'active_support/core_ext'

  require_relative 'grape_reducers/functor'
  require_relative 'grape_reducers/catch_all_functor'
  require_relative 'grape_reducers/reducer'
  require_relative 'grape_reducers/endpoint'
end
