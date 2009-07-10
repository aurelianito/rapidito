require 'test/unit'
require 'rapidito/tokenizer'

include Rapidito

class TokenizerTest < Test::Unit::TestCase
  
  def test_no_token
    tok = Tokenizer.new
    tok.source = "aaaa"
    assert_equal true, tok.has_next?
    assert_equal ["aaaa", :text], tok.next_token
    assert_equal false, tok.has_next?
  end
  
  def assert_all_tokens( expected, tokenizer )
    assert_equal expected, 
      tokenizer.all_tokens.map { |token, kind| [token.to_s, kind] }
  end
  
  def test_two_delimiters
    tok = Tokenizer.new( 
      /\|/, /;;/ 
    )
    
    tok.source = "aa|bbb;;;;cccc"
    assert_all_tokens \
      [ ["aa", :text], ["|", /\|/], ["bbb", :text], 
        [";;", /;;/], [";;", /;;/], ["cccc", :text] ], 
      tok
    
    tok.source = "aa;;bbb||cccc"
    assert_all_tokens \
      [ ["aa", :text], [";;", /;;/], ["bbb", :text], 
        ["|", /\|/], ["|", /\|/], ["cccc", :text] ], 
      tok
  end
  
  def test_choose_longest_match
    tok = Tokenizer.new( 
      /aa/, /aaa/
    )
    tok.source = "aaaa"
    assert_all_tokens [ ["aaa", /aaa/], ["a", :text ] ], tok
  end
  
  def test_reset_precache
    tok = Tokenizer.new( 
      /\|/, /,/
    )
    tok.source = "original start|original end"
    tok.next_token
    tok.source = "new start,new end"
    assert_equal ["new start", :text], tok.next_token
  end
  
  def test_almost_finished
    tok = Tokenizer.new( /!/ )
    tok.source = "bang!"
    tok.next_token
    assert_equal true, tok.has_next?
    tok.next_token
    assert_equal false, tok.has_next?
  end
  
  def test_carriage_return_ending
    tok = Tokenizer.new( /!/ )
    tok.source = "bang!\n"
    tok.next_token
    assert_equal true, tok.has_next?
    tok.next_token
    assert_equal true, tok.has_next?
    assert_equal "\n", tok.next_token[0].to_s
    assert_equal false, tok.has_next?
  end
  
  def test_transparent_caching
    tok = Tokenizer.new( /!/ )
    tok.source = "bang!pum"
    tok.next_token
    
    assert_equal "!pum", tok.source
  end
  
  def test_match_klass
    tok = Tokenizer.new( /!/ )
    tok.source = "!bang!pum"
    
    assert_equal \
      [MatchData, String, MatchData, String], 
      tok.all_tokens.map { |tok, kind| tok.class }
  end
end