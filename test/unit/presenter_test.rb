require 'test_helper'
require 'domain/map'
require 'domain/legend'

class PresenterTest < Minitest::Test

## Test Implementation Classes #################################################


  ##
  # A presenter which adds a few new methods and attributes to a given Map.
  class SimpleMapPresenter
    include GiftWrap::Presenter

    attribute :metric?

    unwrap_for :type
    unwrap_for :units, attribute: true

    def metric?
      metric_map_units.include?(units)
    end

    def contains_region?(region_name)
      false # Implementation not important
    end

    private

    def metric_map_units
      ['m', 'km']
    end

  end

  ##
  # Gives an explicit name to the wrapped object for reference
  # internally to the class, and has a method which uses that reference
  # for use in proving that an internal reference is functioning.
  class ExplicitReferencePresenter
    include GiftWrap::Presenter

    wrapped_as :explicit_reference

    def uses_explicit_reference(msg_name)
      explicit_reference.send(msg_name)
    end

  end

  ##
  # Presenter intended to work with a Legend.
  class LegendPresenter
    include GiftWrap::Presenter

    unwrap_for :line_meaning

    attribute :red_lines

    def red_lines
      line_meaning(:red)
    end

    def yellow_lines
      line_meaning(:yellow)
    end

    def green_lines
      line_meaning(:green)
    end

  end

  ##
  # Map Presenter which wraps its :legend association, for use in testing associations
  # being wrapped in a presenter of their own.
  class LegendaryMapPresenter
    include GiftWrap::Presenter

    unwrap_for :type, :units

    wrap_association :legend, with: LegendPresenter

    def metric?
      metric_map_units.include?(units)
    end

    private

    def metric_map_units
      ['m', 'km']
    end

  end

  ##
  # Another presenter for legends as an alternative to test if overriding association
  # presenters on a per-instance basis functions.
  class MisleadingLegendPresenter
    include GiftWrap::Presenter

    unwrap_for :line_meaning

    def red_lines
      "no congestion"
    end

    def yellow_lines
      "no congestion"
    end

    def green_lines
      "no congestion"
    end

  end

  ##
  # Map Presenter which wraps its :legend association with the name :foobar
  class FoobarLegendMapPresenter
    include GiftWrap::Presenter

    unwrap_for :type, :units

    wrap_association :legend, with: LegendPresenter, as: :foobar

    def metric?
      metric_map_units.include?(units)
    end

    private

    def metric_map_units
      ['m', 'km']
    end

  end


## Setup Helpers #########################################################


  def physical_map
    Map.new("physical", ["here", "there"], "mi")
  end


  def map_with_legend
    Map.new("traffic", "downtown", "km", traffic_legend)
  end


  def traffic_legend
    Legend.new(
      { beige:  "land",
        blue:   "water"
      },
      { green:  "no congestion",
        yellow: "light congestion",
        red:    "heavy congestion",
        black:  "impassable"
      })
  end


## Test Cases ##################################################################


  test "unwrapped methods are delegated properly" do
    map       = physical_map
    presenter = SimpleMapPresenter.new(map)
    assert_equal(map.type, presenter.type)
    assert_equal(map.units, presenter.units)
  end


  test "methods not explicitly unwrapped are not accessible" do
    map       = physical_map
    presenter = SimpleMapPresenter.new(map)
    assert(map.respond_to?(:center))
    refute(presenter.respond_to?(:center))
  end


  test "attributes can include unwrapped methods" do
    attributes = SimpleMapPresenter.new(physical_map).attributes
    assert_includes(attributes.keys, 'units')
  end


  test "attributes do not include unwrapped methods by default" do
    attributes = SimpleMapPresenter.new(physical_map).attributes
    refute_includes(attributes.keys, 'type')
  end


  test "attributes hash include explicitly declared attributes" do
    attributes = SimpleMapPresenter.new(physical_map).attributes
    assert_includes(attributes.keys, 'metric?')
  end


  test "can reference a wrapped object internally via wrapped_as name" do
    map       = physical_map
    presenter = ExplicitReferencePresenter.new(map)
    assert_equal(map.type, presenter.uses_explicit_reference(:type))
    assert_equal(map.units, presenter.uses_explicit_reference(:units))
    assert_raises(NoMethodError) do |variable|
      presenter.explicit_reference
    end
  end


  test "associations can be wrapped with their own presenter class" do
    map       = map_with_legend
    presenter = LegendaryMapPresenter.new(map)
    assert(map.respond_to?(:legend))
    assert(presenter.respond_to?(:legend))
    assert(LegendPresenter === presenter.legend)
    assert(presenter.legend.respond_to?(:line_meaning))
    assert(presenter.legend.respond_to?(:red_lines))
    refute_includes(presenter.legend.attributes.keys, 'line_meaning')
    assert_includes(presenter.legend.attributes.keys, 'red_lines')
    assert_equal(presenter.legend.green_lines, 'no congestion')
    assert_equal(presenter.legend.red_lines, 'heavy congestion')
  end


  test "associations' class can be specified on a per-instance basis" do
    map       = map_with_legend
    presenter = LegendaryMapPresenter.new(map, associations: {
      legend: MisleadingLegendPresenter
    })
    assert(map.respond_to?(:legend))
    assert(presenter.respond_to?(:legend))
    assert(MisleadingLegendPresenter === presenter.legend)
    assert(presenter.legend.respond_to?(:line_meaning))
    assert(presenter.legend.respond_to?(:red_lines))
    assert_equal(presenter.legend.green_lines, 'no congestion')
    assert_equal(presenter.legend.red_lines, 'no congestion')
  end


  test "associations' name can be something other than assoication name" do
    map       = map_with_legend
    presenter = FoobarLegendMapPresenter.new(map)
    assert(map.respond_to?(:legend))
    assert(presenter.respond_to?(:foobar))
    assert(LegendPresenter === presenter.foobar)
    # Most of this mirrors the other association tests for good measure.
    assert(presenter.foobar.respond_to?(:line_meaning))
    assert(presenter.foobar.respond_to?(:red_lines))
    refute_includes(presenter.foobar.attributes.keys, 'line_meaning')
    assert_includes(presenter.foobar.attributes.keys, 'red_lines')
    assert_equal(presenter.foobar.green_lines, 'no congestion')
    assert_equal(presenter.foobar.red_lines, 'heavy congestion')
  end

end
