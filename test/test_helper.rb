require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/reporters/turn_again_reporter'
Minitest::Reporters.use!(Minitest::Reporters::TurnAgainReporter.new)

##
# The following active_support and active_model files are the specific minimum
# dependencies for using ActiveModel::Serializers::JSON
require 'active_support/json'
require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_model/naming'
require 'active_model/serialization'
require 'active_model/serializers/json'

##
# And of course, require ourselves.
require 'gift_wrap'

##
# Blatantly stolen from ActiveSupport::Testing::Declarative
# Allows for test files such as
#   test "verify something" do
#     ...
#   end
# which become methods named test_verify_something, leaving a visual difference
# between tests themselves and any helper methods declared in the usual
# manner of `def some_helper_method`.
module DeclarativeTests
  def test(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end
end

class Minitest::Test
  extend DeclarativeTests
end

##
# ActiveRecord setup for testing use of GiftWrap::ActiveRecordPresenter
#
# TODO (possibly):
#   Have some sort of method for switching on/off inclusion and execution
#   of active_record in tests. The goal would be to ensure that no tests
#   unrelated to ActiveRecord accidentally come to rely on its presence, or on
#   the presence of the friends it pulls in (ActiveModel, ActiveSupport).
#
# Some ordering of some of these steps is important:
#   1. Set up in-memory sqlite3 connection.
#   2. Require the model class.
#   3. Load the database schema. Doing this before loading the model broke things?
#   4. Load a file that creates some user rows and run said creation method.
require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
require File.join(File.dirname(__FILE__), "domain", "user.rb")
require File.join(File.dirname(__FILE__), "database", "schema.rb")
require File.join(File.dirname(__FILE__), "fixtures", "user_records.rb")
UserRecords.create!
