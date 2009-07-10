require 'test/unit'
require 'lang_hacks'

class TestLangHacks < Test::Unit::TestCase
  def test_casing
    assert_equal "AÁÁA", "aáÁA".upcase
    assert_equal "aááa", "aáÁA".downcase
  end
end