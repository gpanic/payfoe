require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/command_line.rb'
end

require_relative '../lib/payfoe'
require_relative 'support/shared_examples_for_datamappers'
require_relative 'support/utility'
