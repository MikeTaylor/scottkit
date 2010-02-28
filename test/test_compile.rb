require 'test/unit'
require 'scottkit/game'
require 'stringio'
require 'scottkit/withio'

class TestCompile < Test::Unit::TestCase #:nodoc:
  EXPECTED = [
              # Token,      Lexeme
              [ :room ],
              [ :symbol,    "chamber" ],
              [ :symbol,    "square chamber" ],
              [ :exit ],
              [ :direction, "east" ],
              [ :symbol,    "dungeon" ],
              [ :room ],
              [ :symbol,    "dungeon" ],
              [ :symbol,    "gloomy dungeon" ],
              [ :exit ],
              [ :direction, "west" ],
              [ :symbol,    "chamber" ],
              [ :eof ],
             ];

  def test_lexer
    game = ScottKit::Game.new({})
    lexer = ScottKit::Game::Compiler::Lexer.new(game, "data/tutorial/t1.sck")
    EXPECTED.each do |x| token, lexeme = *x
      got = lexer.lex
      assert_equal(token, got)
      assert_equal(lexeme, lexer.lexeme) if lexeme
    end
  end

  def test_parser
    game = ScottKit::Game.new({})
    # It's a clumsy API, but then we're peeking where we're not invited
    compiler = ScottKit::Game::Compiler.new(game, "data/tutorial/t6.sck")
    tree = compiler.parse
    got = tree.pretty_inspect
    expected = File.read("data/test/t6.pretty-print")
    # Remove hex object addresses from pretty-printed trees
    assert_equal(got.gsub(/0x\h+/, ""), expected.gsub(/0x\h+/, ""))
  end

  def test_code_generator
    game = ScottKit::Game.new({})
    f = StringIO.new
    withIO(nil, f) do
      game.compile_to_stdout("data/test/crystal.sck") or
        raise "couldn't compile crystal.sck"
    end
    assert_equal(f.string, File.read("data/test/crystal.sao"))
  end
end
