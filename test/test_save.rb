require 'test/unit'
require 'scottkit/game'
require 'stringio'

class TestSave < Test::Unit::TestCase #:nodoc:
  # Can't use a setup() method here as the two test-cases need the
  # games to be initialised with different options.

  def test_save_crystal
    game = ScottKit::Game.new(random_seed: 12368, echo_input: true,
                              input: File.new("games/test/crystal.save-script"),
                              output: StringIO.new)
    game.load(IO.read("games/test/crystal.sao"))
    game.play()
    assert_equal(File.read("TMP"), File.read("games/test/crystal.save-file"))
    File.unlink "TMP"
  end

  def test_resave_crystal
    game = ScottKit::Game.new(random_seed: 12368, echo_input: true,
                              input: StringIO.new("save game\nTMP"),
                              output: StringIO.new,
                              restore_file: "games/test/crystal.save-file")
    game.load(IO.read("games/test/crystal.sao"))
    game.play()
    assert_equal(File.read("TMP"), File.read("games/test/crystal.save-file"))
    File.unlink "TMP"
  end
end
