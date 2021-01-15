require 'test/unit'
require 'scottkit/game'
require 'stringio'
require 'digest/md5'

class TestPlayAdams < Test::Unit::TestCase #:nodoc:
  def test_play_adams
    %w{01 04}.each do |num|
      play("adv#{num}")
    end
  end

  def play(name)
    gamefile = "games/adams/#{name}.dat"

    if(File::readable?(gamefile))
      game = ScottKit::Game.new(output: StringIO.new,
                                read_file: "games/test/adams/#{name}.solution",
                                random_seed: 12368, no_wait: true )
      game.load(IO.read gamefile)
      game.play
      digest = Digest::MD5.hexdigest(game.output.string)
      expected = File.read("games/test/adams/#{name}.transcript.md5").chomp
      assert_equal(expected, digest)
    else
      if self.respond_to? :skip
        skip "no game file #{gamefile}"
      else
        # Crappy older version of Test::Unit
        puts "skipping '#{name}' because no gamefile"
      end
    end
  end
end
