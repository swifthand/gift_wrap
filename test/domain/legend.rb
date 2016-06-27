##
# An object to associate with a map, for testing associations & wrapping thereof.
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
