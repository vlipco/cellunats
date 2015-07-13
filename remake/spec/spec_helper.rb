require_relative '../lib/cellunats.rb'
require 'byebug'
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end