require 'test_helper'

class GiftWrap::PresenterTest < Minitest::Test

## Test Classes ################################################################

  class Map

    attr_reader :type, :center, :units, :legend
    attr_accessor :notes

    def initialize(type, center, units, legend = :asshole_mapmaker_forgot_legend)
      @type   = type
      @center = center
      @units  = units
      @notes  = ""
      @legend = legend
    end

    def shows_roads?
      maps_with_roads.include?(type)
    end

  private

    def maps_with_roads
      ['road', 'traffic', 'political']
    end

  end


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


  class Legend

    def initialize(colored_regions, colored_lines)
      @colored_regions  = colored_regions
      @colored_lines    = colored_lines
    end

    def region_meaning(color)
      @colored_regions[color]
    end

    def line_meaning(color)
      @colored_lines[color]
    end

  end


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


## End Test Classes ############################################################


  def physical_map
    Map.new("physical", ["here", "there"], "mi")
  end


  def map_with_legend
    Map.new("traffic", "downtown", "km", traffic_legend)
  end


  def traffic_legend
    Legend.new(
      { beige: "land",
        blue: "water"
      },
      { green: "no congestion",
        yellow: "light congestion",
        red: "heavy congestion",
        black: "impassable"
      })
  end


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
  end

end

