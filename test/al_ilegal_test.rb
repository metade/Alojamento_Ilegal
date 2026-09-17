require "minitest/autorun"
require_relative "../lib/al_ilegal"

class AlIlegalTest < Minitest::Test
  def test_normalizes_leading_zeroes_and_whitespace_in_al_licenses
    assert_equal "1584", AlIlegal.parse_al_license("001584/AL")
    assert_equal "104882", AlIlegal.parse_al_license("104882\t/AL")
  end

  def test_normalizes_legacy_year_suffix
    assert_equal "22720", AlIlegal.parse_al_license("22720/2018")
  end

  def test_does_not_treat_tourist_undertaking_number_as_al_license
    assert_nil AlIlegal.parse_al_license("406/UT/2017")
  end

  def test_parses_coordinates_with_spaces_around_separator
    assert_equal [38.7530581, -9.181339], AlIlegal.parse_lat_long("38.7530581 ; -9.181339")
  end

  def test_parses_coordinates_without_spaces_and_with_decimal_commas
    assert_equal [38.7530581, -9.181339], AlIlegal.parse_lat_long("38,7530581;-9,181339")
  end
end
