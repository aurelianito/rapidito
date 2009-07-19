=begin AFFERO_3
rapidito. Wiki database.
Copyright (C) 2009 Aureliano Calvo.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

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