require 'test/unit'
require 'scottkit/game'
require 'stringio'

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
    lexer = ScottKit::Game::Compiler::Lexer.new(game, "games/tutorial/t1.sck")
    EXPECTED.each do |x| token, lexeme = *x
      got = lexer.lex
      assert_equal(token, got)
      assert_equal(lexeme, lexer.lexeme) if lexeme
    end
  end

  def test_parser
    game = ScottKit::Game.new({})
    # It's a clumsy API, but then we're peeking where we're not invited
    compiler = ScottKit::Game::Compiler.new(game, "games/test/t6.sck")
    tree = compiler.parse
    got = tree.pretty_inspect
    expected = File.read("games/test/t6.pretty-print")
    # Remove hex object addresses from pretty-printed trees
    assert_equal(got.gsub(/0x\h+/, ""), expected.gsub(/0x\h+/, ""))
  end

  def test_code_generator
    game = ScottKit::Game.new({})
    compiled_game = StringIO.new
    game.compile(compiled_game, "games/test/crystal.sck") or
      raise "couldn't compile crystal.sck"
    assert_equal(compiled_game.string, File.read("games/test/crystal.sao"))
  end
end
