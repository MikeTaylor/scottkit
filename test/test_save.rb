require 'test/unit'
require 'scottkit/game'
require 'stringio'
require 'scottkit/withio'

class TestSave < Test::Unit::TestCase #:nodoc:
  # Can't use a setup() method here as the two test-cases need the
  # games to be initialised with different options.

  def test_save_crystal
    game = ScottKit::Game.new({ :random_seed => 12368, :echo_input => true })
    game.load(IO.read("games/test/crystal.sao"))
    withIO(File.new("games/test/crystal.save-script"), 
           File.new("/dev/null", "w")) do
      game.play()
    end
    assert_equal(File.read("TMP"), File.read("games/test/crystal.save-file"))
    File.unlink "TMP"
  end

  def test_resave_crystal
    game = ScottKit::Game.new({ :random_seed => 12368, :echo_input => true,
        :restore_file => "games/test/crystal.save-file" })
    game.load(IO.read("games/test/crystal.sao"))
    withIO(StringIO.new("save game\nTMP"), File.new("/dev/null", "w")) do
      game.play()
    end
    assert_equal(File.read("TMP"), File.read("games/test/crystal.save-file"))
    File.unlink "TMP"
  end
end
