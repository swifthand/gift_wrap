require 'test_helper'
require File.join(File.dirname(__FILE__), "..", "data", "user_records.rb")

UserRecords.create!

class GiftWrap::ActiveRecordPresenterTest < Minitest::Test

  class SimpleUserPresenter
    include GiftWrap::ActiveRecordPresenter

    unwrap_columns_for ::User

    unwrap_for :initials

    def email_with_display_name
      "#{first_name} #{last_name} <#{email}>"
    end

  end


  class NoAttributeUserPresenter
    include GiftWrap::ActiveRecordPresenter
    unwrap_columns_for ::User, attribute: false
  end


  class UserPresenterUsingOnly
    include GiftWrap::ActiveRecordPresenter
    unwrap_columns_for ::User, attribute: { only: [:first_name, :email, :last_name] }
  end


  class UserPresenterUsingExcept
    include GiftWrap::ActiveRecordPresenter
    unwrap_columns_for ::User, attribute: { except: [:first_name, :email, :last_name] }
  end


  def sample_user
    User.find(1)
  end


  test "can unwrap columns" do
    paulwall  = sample_user
    presenter = SimpleUserPresenter.new(paulwall)
    assert(presenter.respond_to?(:email))
    assert(presenter.respond_to?(:first_name))
    assert(presenter.respond_to?(:encrypted_password))
    assert_equal(paulwall.email, presenter.email)
  end


  test "can respond to additional instance methods" do
    paulwall  = sample_user
    presenter = SimpleUserPresenter.new(paulwall)
    assert_equal("Paul Wall <paulwall@example.com>", presenter.email_with_display_name)
  end


  test "can wrap methods as expected of a presenter" do
    paulwall  = sample_user
    presenter = SimpleUserPresenter.new(paulwall)
    assert_equal("PW", paulwall.initials)
    assert_equal("PW", presenter.initials)
  end


  test "columns are set as presenter attributes by default" do
    paulwall  = sample_user
    presenter = SimpleUserPresenter.new(paulwall)
    assert_includes(presenter.attributes.keys, 'email')
    assert_includes(presenter.attributes.keys, 'created_at')
    assert_includes(presenter.attributes.keys, 'updated_at')
    assert_includes(presenter.attributes.keys, 'first_name')
    assert_includes(presenter.attributes.keys, 'last_name')
    assert_includes(presenter.attributes.keys, 'sign_in_count' )
  end


  test "unwrap_columns_for can be asked to set no columns as attributes" do
    presenter = NoAttributeUserPresenter.new(sample_user)
    assert_equal({}, presenter.attributes)
  end


  test "unwrap_columns_for can specify attributes with :only" do
    presenter = UserPresenterUsingOnly.new(sample_user)
    assert_includes(presenter.attributes.keys, 'email')
    assert_includes(presenter.attributes.keys, 'first_name')
    assert_includes(presenter.attributes.keys, 'last_name')
    refute_includes(presenter.attributes.keys, 'created_at')
    refute_includes(presenter.attributes.keys, 'updated_at')
    refute_includes(presenter.attributes.keys, 'sign_in_count')
  end


  test "unwrap_columns_for can specify attributes with :except" do
    presenter = UserPresenterUsingExcept.new(sample_user)
    assert_includes(presenter.attributes.keys, 'created_at')
    assert_includes(presenter.attributes.keys, 'updated_at')
    assert_includes(presenter.attributes.keys, 'sign_in_count')
    refute_includes(presenter.attributes.keys, 'email')
    refute_includes(presenter.attributes.keys, 'first_name')
    refute_includes(presenter.attributes.keys, 'last_name')
  end

end
