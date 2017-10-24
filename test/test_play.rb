require 'test/unit'
require 'scottkit/game'
require 'stringio'
require 'scottkit/withio'

class TestPlay < Test::Unit::TestCase #:nodoc:
  def test_play_tutorial7; play("t7"); end
  def test_play_crystal; play("crystal"); end

  def play(name)
    game = ScottKit::Game.new({ :read_file =>
                                "games/test/#{name}.solution",
                                :random_seed => 12368, :no_wait => true })
    game.load(IO.read("games/test/#{name}.sao"))
    f = StringIO.new
    withIO(nil, f) { game.play }
    expected = File.read("games/test/#{name}.transcript")
    assert_equal(expected, f.string)
  end
end
