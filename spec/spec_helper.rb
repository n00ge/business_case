# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require "business_case"

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |f| require f }
