require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/reporters/turn_again_reporter'
Minitest::Reporters.use!(Minitest::Reporters::TurnAgainReporter.new)

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
# ActiveRecord Setup for use of GiftWrap::ActiveRecordPresenter
require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

require File.join(File.dirname(__FILE__), "database", "user.rb")
load File.join(File.dirname(__FILE__), "database", "schema.rb")
