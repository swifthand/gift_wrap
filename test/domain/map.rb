##
# Everyone loves maps.
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
