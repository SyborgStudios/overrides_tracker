require 'simplecov'
require 'coveralls'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

SimpleCov.start 'rails' do # <============= 2
  add_filter 'spec/'
  add_filter 'lib/external/require_all.rb'
  add_filter 'lib/overrides_tracker/version.rb'
  add_filter 'lib/overrides_tracker.rb'
end

Coveralls.wear!

require 'bundler/setup'
require 'overrides_tracker'
require 'rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.mock_with :rspec
  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
