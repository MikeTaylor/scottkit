require 'test/unit'
require 'scottkit/game'
require 'stringio'

class TestDecompile < Test::Unit::TestCase #:nodoc:
  def test_decompile_crystal
    game = ScottKit::Game.new({})
    game.load(IO.read("games/test/crystal.sao"))
    f = StringIO.new()
    game.decompile(f)
    assert_equal(f.string, File.read("games/test/crystal.decompile"))
  end
end
