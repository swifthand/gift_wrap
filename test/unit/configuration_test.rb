require 'test_helper'
require 'domain/map'
require 'domain/legend'

class ConfigurationTest < Minitest::Test

## Setup Helpers #################################################

  ##
  # Since we're reconfiguring module-wide settings, we can't rely on a class defined
  # at load time to pick up on changes to the configuration during successive test cases.
  def build_presenter_class
    Class.new do
      include GiftWrap::Presenter
      unwrap_for :type
      unwrap_for :units, attribute: true
    end
  end


## Test Cases ##################################################################


  test "presenters include serializers when use_serializers is true" do
    GiftWrap.configure do |config|
      config.use_serializers = true
    end
    map       = Map.new("physical", ["here", "there"], "mi")
    presenter = build_presenter_class.new(map)
    assert_kind_of(ActiveModel::Serializers::JSON, presenter)
  end


  test "presenters do not include serializers when use_serializers is false" do
    GiftWrap.configure do |config|
      config.use_serializers = false
    end
    map       = Map.new("physical", ["here", "there"], "mi")
    presenter = build_presenter_class.new(map)
    refute_kind_of(ActiveModel::Serializers::JSON, presenter)
  end

end
