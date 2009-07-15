require 'test/unit'
require 'rapidito'

class RapiditoHtmlTest < Test::Unit::TestCase

  def assert_rapidito_structure( expected, markup )
    assert_equal "<div class=\"rapidito\">#{expected}</div>", Rapidito::Rapidito.new("http://base/").parse(markup).to_html
  end
  
  EXPECTED_MARKUP_FORMATTING = [
    [ 'Hello <a href="http://base/Nicol&#225;s">Nicol&#225;s</a>', "Hello _Nicolás" ],
    [ "no markup", "no markup" ],
    [ 'plain <i>italic</i> plain', "plain ''italic'' plain" ],
    [ 'plain <b>bold</b> plain', "plain '''bold''' plain" ],
    [ 'plain <i>italic</i> plain <i>italic</i> plain', "plain ''italic'' plain ''italic'' plain" ],

    [ '<i>italic <b>both</b> italic</i> <b>bold <i>both</i> bold</b>', 
      "''italic '''both''' italic'' '''bold ''both'' bold'''"],

    [ '<i>italic <u>both</u></i><u> underline</u> nothing', 
      "''italic __both'' underline__ nothing" ],

    [ '<b><i>bold-italic</i> bold</b> nothing', 
      "'''''bold-italic'' bold''' nothing" ],

    [ '<b><i>bold-italic</i></b><i> italic</i> nothing', 
      # '<i><b>bold-italic</b> italic</i> nothing' would be better but this is good enough
      "'''''bold-italic''' italic'' nothing" ],

    [ '<del>deleted</del>', "~~deleted~~" ],
    [ '<sup>superscript</sup>', "^superscript^" ],
    [ '<sub>subscript</sub>', ",,subscript,," ],

    [ "<b>bold</b>, <b>''' can be bold too</b>, and <b>! </b>",
        "'''bold''', '''!''' can be bold too''', and '''! '''" ],
        
    [ "Bang!", "Bang!" ],
    [ "Bang!!", "Bang!!" ],
    [ "Bang! in the middle", "Bang! in the middle"],
    
    [ "<tt> {{{ ''aaa'' }}} </tt> <b>bbbb</b> }}}", 
      "{{{ {{{ ''aaa'' }}} }}} '''bbbb''' }}}" ],
      
    [ "<tt>verbatim</tt>", "`verbatim`"],
    
    [ '<a href="http://base/Some_link">Some link</a>', 
      "Some_link" ],
    [ 'Hello <a href="http://base/Nicol&#225;s_Calvo">Nicol&#225;s Calvo</a>', 
      "Hello Nicolás_Calvo" ],
    
  ]
  
  def test_formatting
    EXPECTED_MARKUP_FORMATTING.each do
      |expected, markup|
      assert_rapidito_structure "<p>#{expected}</p>", markup
    end
  end
  
  def test_paragraph_division
    markup = <<MARKUP
Paragraph ''formatted''

'''Second paragraph'''
MARKUP
    expected = "<p>Paragraph <i>formatted</i></p>"
    expected += "<p><b>Second paragraph</b>\n</p>"
    assert_rapidito_structure expected, markup
  end
  
  def test_paragraph_ending_with_bang
    assert_rapidito_structure "<p>Bang!</p><p>Bang!</p>", "Bang!\n\nBang!"
  end

  def test_heading
    assert_rapidito_structure \
      "<h1>title <i>with format</i></h1><p>paragraph</p>", 
      "= title ''with format'' =\nparagraph"
      
    assert_rapidito_structure \
      "<h1>title with \\r</h1><p>paragraph</p>", 
      "= title with \\r =\r\nparagraph"
      
    assert_rapidito_structure \
      "<h1>title <i>format not closed</i></h1><p>paragraph</p>", 
      "= title ''format not closed =\nparagraph"
      
    assert_rapidito_structure \
      "<p>== Not a title</p>", "== Not a title"
      
    assert_rapidito_structure \
      "<p>== Not a title</p><p>And something else</p>", 
      "== Not a title\nAnd something else"
  end
  
  def test_eol_and_verbatim
    assert_rapidito_structure \
      "<p>{{{ Ended with carriage return\n</p>",
      "{{{ Ended with carriage return\n"
      
    assert_rapidito_structure \
      "<p>{{{ <b>bold</b>!</p>",
      "{{{ '''bold'''!"
  end
  
  def test_list
    assert_rapidito_structure \
      "<ul><li>Item 1</li><li>Item 2</li></ul>", 
      " * Item 1\n * Item 2"
      
    assert_rapidito_structure \
      "<p>Paragraph</p>"+
        "<ul><li>Item 1</li><li>Item 2</li></ul>"+
        "<p>Paragraph</p>", 
      "Paragraph\n * Item 1\n * Item 2\nParagraph"
      
    assert_rapidito_structure \
      "<ul><li>Normal <b>bold</b></li><li><b>Bold</b> normal</li></ul>",
      " * Normal '''bold\n * Bold''' normal"
    
    assert_rapidito_structure \
      "<ul><li>Level 1<ul><li>Level 2<ul><li>Level 3</li></ul></li></ul></li>" +
        "<li>Level 1 again</li></ul>",
      " * Level 1\n" +
        "   * Level 2\n" +
        "    * Level 3\n" +
        "  * Level 1 again"
    
    assert_rapidito_structure \
      "<ol><li>Item 1</li><li>Item 2</li></ol>", 
      " 1. Item 1\n 1. Item 2"
      
    assert_rapidito_structure \
      "<ol><li>Item 1<ul><li>Subitem 1</li><li>Subitem 2</li></ul></li></ol>",
      " 1. Item 1\n  * Subitem 1\n  * Subitem 2"
    
    assert_rapidito_structure \
      "<ul><li>Item 1</li></ul><ol><li>Item 2</li></ol>",
      " * Item 1\n 1. Item 2"

    assert_rapidito_structure \
      '<ol start="134"><li>Item 1</li><li>Item 2</li></ol>',
      " 134. Item 1\n 1. Item 2"
      
    assert_rapidito_structure \
      '<ul><li>Parent<ol start="134"><li>Item 1</li><li>Item 2</li></ol></li></ul>',
      " * Parent\n  134. Item 1\n  1. Item 2"

    assert_rapidito_structure \
      '<ol class="lower_roman"><li>Item 1</li><li>Item 2</li></ol>', 
      " ii. Item 1\n i. Item 2"

  end
  
  def test_blockquote
    assert_rapidito_structure \
      "<blockquote><p>Multiline blockquote content</p></blockquote><p>And a paragraph</p>",
      " Multiline\n  blockquote\n content\nAnd a paragraph"
  end
  
  def test_definition_list
    assert_rapidito_structure \
      "<dl><dt>key</dt><dd>value</dd></dl>",
      "key:: value"
      
    assert_rapidito_structure \
      "<dl><dt>key1</dt><dd>value1</dd><dt>key2</dt><dd>value2</dd></dl>",
      "key1:: value1\nkey2:: value2"
  end 
  
  def test_pre
    assert_rapidito_structure \
      "<p>Paragraph</p><pre>'''Formatting'''\nand new line</pre><p>And another paragraph</p>",
      "Paragraph\n{{{\n'''Formatting'''\nand new line\n}}}\nAnd another paragraph"
  end
end