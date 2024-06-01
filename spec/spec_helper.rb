require "pretty_api"
require "active_record"
require "factory_bot"
require "hashdiff"
require "database_cleaner/active_record"

require_relative "app/controllers/organizations_controller"
require_relative "app/models/application_record"
require_relative "app/models/company_car"
require_relative "app/models/organization"
require_relative "app/models/phone"
require_relative "app/models/service"
require_relative "app/models/user"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load "#{File.dirname(__FILE__)}/app/db/schema.rb"

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  RSpec::Matchers.define :eq_hash do |expected|
    match do |actual|
      Hashdiff.best_diff(expected.try(:deep_symbolize_keys), actual.try(:deep_symbolize_keys)).blank?
    end
    failure_message do |actual|
      "expected that #{actual} would match #{expected}, but it differs: #{Hashdiff.best_diff(expected, actual)}"
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
