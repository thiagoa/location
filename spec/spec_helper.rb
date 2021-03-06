require 'simplecov'
require 'pry'

SimpleCov.start

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'shoulda/matchers'
require 'factory_girl'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.alias_example_to :expect_it
  config.filter_run_excluding external: true
  config.include FinderHelpers
end

RSpec::Core::MemoizedHelpers.module_eval do
  alias to should
  alias to_not should_not
end
