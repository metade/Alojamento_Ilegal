require "minitest/autorun"
require_relative "../lib/al_ilegal"

class AlIlegalTest < Minitest::Test
  def test_parses_coordinates_with_spaces_around_separator
    assert_equal [38.7530581, -9.181339], AlIlegal.parse_lat_long("38.7530581 ; -9.181339")
  end

  def test_parses_coordinates_without_spaces_and_with_decimal_commas
    assert_equal [38.7530581, -9.181339], AlIlegal.parse_lat_long("38,7530581;-9,181339")
  end
end
