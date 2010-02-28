require 'test/unit'
require 'scottkit/game'
require 'stringio'
require 'digest/md5'
require 'scottkit/withio'

class TestPlayAdams < Test::Unit::TestCase #:nodoc:
  def test_play_adams
    %w{01 02 04}.each do |num|
      play("adv#{num}")
    end
  end

  def play(name)
    gamefile = "data/adams/#{name}.dat"

    if(File::readable?(gamefile))
      game = ScottKit::Game.new({ :read_file =>
                                  "data/test/adams/#{name}.solution",
                                  :random_seed => 12368, :no_wait => true })
      game.load(IO.read gamefile)
      f = StringIO.new
      withIO(nil, f) { game.play }
      digest = Digest::MD5.hexdigest(f.string)
      expected = File.read("data/test/adams/#{name}.transcript.md5").chomp
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
