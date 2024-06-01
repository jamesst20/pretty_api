require "active_support/concern"

require_relative "pretty_api/version"
require_relative "pretty_api/utils/hash"
require_relative "pretty_api/active_record/orm"
require_relative "pretty_api/errors/nested_errors"
require_relative "pretty_api/helpers"
require_relative "pretty_api/active_record/associations"
require_relative "pretty_api/parameters/nested_attributes"

module PrettyApi
  singleton_class.attr_accessor :destroy_missing_associations
  self.destroy_missing_associations = true

  singleton_class.attr_accessor :max_nested_attributes_depth
  self.max_nested_attributes_depth = 1
end
