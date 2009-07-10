require 'test/unit'
require 'rapidito'

class RapiditoDataTest < Test::Unit::TestCase
  def test_data
    markup = <<MARKUP
== Something ==
key1::value1
key2::value2

And something else
MARKUP
    assert_equal(
      { "key1" => "value1", "key2" => "value2" },
      Rapidito::Rapidito.new("http://some_url/").parse(markup).data
    )
  end
end