module ScottKit
  class Game
    NFLAGS = 16 #:nodoc: (The most that ScottFree save-game format supports)
    VERB_GO = 1 #:nodoc:
    VERB_GET = 10 #:nodoc:
    VERB_DROP = 18 #:nodoc:
    ITEM_LAMP = 9 #:nodoc:
    FLAG_DARK = 15 #:nodoc:
    FLAG_LAMPDEAD = 16 #:nodoc:
    ROOM_CARRIED = -1 #:nodoc:
    ROOM_OLDCARRIED = 255  #:nodoc: (from when all words were eight bits wide)
    ROOM_NOWHERE = 0 #:nodoc:

    # Constant once they've been initialised
    attr_reader :options, :nouns, :verbs, :rooms, :items, :messages,
        :maxload, :lamptime #:nodoc:

    # Variable during run (but mostly set only within this class)
    attr_reader :flags, :counters, :saved_rooms, :noun #:nodoc:
    attr_accessor :loc, :counter, :saved_room, :lampleft #:nodoc:

    private

    # Creates a new game, with no room, items or actions -- load must
    # be called to make the game ready for playing, or
    # compile_to_stdout can be called to generate a new game-file.
    # The options hash affects various aspects of how the game will be
    # loaded, played and compiled.  The following symbols are
    # recognised as keys in the options hash:
    #
    # [+wizard_mode+]       If specified, then the player can use
    #                       "wizard commands", prefixed with a hash,
    #                       as well as the usual commands: these
    #                       include +sg+ (superget, to take any item
    #                       whose number is specified), +go+ (teleport
    #                       to the room whose number is specified),
    #                       +where+ (to find the location of the item
    #                       whose number is specified), and +set+ and
    #                       +clear+ (to set and clear verbosity
    #                       flags).
    #
    # [+restore_file+]      If specified, the name of a saved-game
    #                       file to restore before starting to play.
    #
    # [+read_file+]         If specified, the name of a file of game
    #                       commands to be run after restoring s saved
    #                       game (if any) and before starting to read
    #                       commands from the user.
    #
    # [+echo_input+]        If true, then game commands are echoed
    #                       before being executed.  This is useful
    #                       primarily if input is being redirected
    #                       from a pipe or a file, so that it's
    #                       possible to see what the game's responses
    #                       are in response to.  (This is not needed
    #                       when <tt>:read_file</tt> is used.)
    #
    # [+random_seed+]       If a number is specified, it is used as
    #                       the random seed before starting to run the
    #                       game.  This is useful to get random events
    #                       happening at the same time every time, for
    #                       example when regression-testing a
    #                       solution.
    #
    # [+bug_tolerant+]      If true, then the game tolerates
    #                       out-of-range room-numbers as the locations
    #                       of items, and also compiles such
    #                       room-named using special names of the form
    #                       <tt>\_ROOM<i>number</i></tt>.  (This is not
    #                       necessary when dealing with well-formed
    #                       games, but <i>Buckaroo Banzai</i> is not
    #                       well-formed.)
    #
    # [+no_wait+]           If true, then the game does not pause when
    #                       running a +pause+ instruction, nor at the
    #                       end of the game.  This is useful to speed
    #                       up regression tests.
    #
    # [+show_tokens+]       The compiler shows the tokens it is
    #                       encountering as it lexically analyses the
    #                       text of a game source.
    #
    # [+show_random+]       Notes when a random occurrence is tested
    #                       to see whether it fires or not.
    #
    # [+show_parse+]        Shows the parsed verb and noun from each
    #                       game command.  (Note that this does _not_
    #                       emit information about parsing game
    #                       source.)
    #
    # [+show_conditions+]   Shows each condition that is tested when
    #                       determining whether to run an action,
    #                       indicating whether it is true or not.
    #
    # [+show_instructions+] Shows each instruction executed as part of
    #                       an action.
    #
    # The +show_random+, +show_parse+, +show_conditions+ and
    # +show_conditions+ flags can be set and cleared on the fly if the
    # game is being played in wizard mode, using the +set+ and +clear+
    # wizard commnds with the arguments +r+, +p+, +c+ and +i+
    # respectively.

    def initialize(options)
      @options = options
      @rooms, @items, @actions, @nouns, @verbs, @messages =
        [], [], [], [], [], []
    end

    # Virtual accessor
    def dark_flag #:nodoc:
      @flags[FLAG_DARK]
    end
    def dark_flag=(val) #:nodoc:
      @flags[FLAG_DARK] = val
    end

    # Loads the game-file specified by str.  Note that this must be
    # the _content_ of the game-file, not its name.
    #
    def load(str)
      @roombynumber = [ "_ROOM0" ]
      @roomregister = Hash.new(0) # name-stem -> number of registered instances
      @itembynumber = []
      @itemregister = Hash.new(0) # name-stem -> number of registered instances

      lexer = Fiber.new do
        while str != "" do
          if match = str.match(/^\s*(-?\d+|"(.*?)")\s*/m)
            dputs(:show_tokens, "token " + (match[2] ? "\"#{match[2]}\"" : match[1]))
            Fiber.yield match[2] || Integer(match[1])
            str = match.post_match
          else
            raise "bad token: #{str}"
          end
        end
      end

      (@unknown1, nitems, nactions, nwords, nrooms, @maxload,
       @startloc, @ntreasures, @wordlen, @lamptime, nmessages, @treasury) =
        12.times.map { lexer.resume }
      @actions = 0.upto(nactions).map do
        verbnoun = lexer.resume
        conds, args = [], []
        5.times do
          n = lexer.resume
          cond, value = n%20, n/20
          if cond == 0
            args << value
          else
            conds << Condition.new(self, cond, value)
          end
        end

        instructions = []
        2.times do
          n = lexer.resume
          [ n/150, n%150 ].each { |val|
            instructions << Instruction.new(self, val) if val != 0
          }
        end

        Action.new(self, verbnoun/150, verbnoun%150, conds, instructions, args)
      end

      @verbs, @nouns = [], []
      0.upto(nwords) do
        @verbs << lexer.resume
        @nouns << lexer.resume
      end

      @rooms = 0.upto(nrooms).map do
        exits = 6.times.map { lexer.resume }
        desc = lexer.resume
        Room.new(desc, exits)
      end

      @messages = 0.upto(nmessages).map { lexer.resume }

      @items = 0.upto(nitems).map do
        desc, name = lexer.resume, nil
        if match = desc.match(/^(.*)\/(.*)\/$/)
          desc, name = match[1], match[2]
        end
        startloc = lexer.resume
        startloc = ROOM_CARRIED if startloc == ROOM_OLDCARRIED
        Item.new(desc, name, startloc)
      end

      0.upto(nactions) do |i|
        @actions[i].comment =lexer.resume
      end

      @version, @id, @unknown2 = 3.times.map { lexer.resume }
      raise "extra text in adventure file" if lexer.resume
    end

    def roomname(i) #:nodoc:
      entityname(i, "room", @rooms, @roombynumber, @roomregister)
    end

    def itemname(i) #:nodoc:
      entityname(i, "item", @items, @itembynumber, @itemregister)
    end

    def entityname(i, caption, list, index, register)
      if i < 0 || i > list.size-1
        return "_#{caption.upcase}#{i}" if options[:bug_tolerant]
        raise "#{caption} ##{i} out of range 0..#{list.size-1}"
      end

      if name = index[i]
        return name
      end
      stem = list[i].desc
      stem = "VOID" if stem =~ /^\s*$/
      stem = stem.split.last.sub(/[^a-z]*$/i, "").sub(/.*?([a-z]+)$/i, '\1')
      count = register[stem]
      register[stem] += 1
      index[i] = count == 0 ? stem : "#{stem}#{count}"
    end

    def dirname(i) #:nodoc:
      %w{north south east west up down}[i]
    end

    def save(name)
      f = File.new(name, "w") or
        raise "#$0: can't save game to #{name}: #$!"
      f.print(0.upto(NFLAGS-1).map { |i|
        String(@counters[i]) + " " + String(@saved_rooms[i]) + "\n"
      }.join)
      f.print(0.upto(NFLAGS-1).reduce(0) { |acc, i|
                acc | (@flags[i] ? 1 : 0) << i })
      f.print " ", dark_flag ? 1 : 0
      f.print " ", @loc
      f.print " ", @counter
      f.print " ", @saved_room
      f.print " ", @lampleft, "\n"
      f.print @items.map { |item| "#{item.loc}\n" }.join
      f.close
      puts "Saved to #{name}"
    end

    def restore(name)
      f = File.new(name) or
        raise "#$0: can't restore game from #{name}: #$!"
      0.upto(NFLAGS-1) do |i|
        @counters[i], @saved_rooms[i] = f.gets.chomp.split.map(&:to_i)
      end
      # The variable _ in the next line is the unused one that holds
      # the redundant dark-flag from the save file. Some versions of
      # Ruby emit an irritating warning for this if the variable name
      # is anything else.
      tmp, _, @loc, @counter, @saved_room, @lampleft =
        f.gets.chomp.split.map(&:to_i)
      0.upto(NFLAGS-1) do |i|
        @flags[i] = (tmp & 1 << i) != 0
      end
      @items.each { |item| item.loc = f.gets.to_i }
    end

    def dputs(level, *args) #:nodoc:
      puts args.map { |x| "# #{x}" } if @options[level]
    end

    # Compiles the specified game-source file, writing the resulting
    # object file to stdout, whence it should be redirected into a
    # file so that it can be played.  Yes, this API is sucky: it would
    # be better if we had a simple compile method that builds the game
    # in memory in a form that can by played, and which can then also
    # be saved as an object file by some other method -- but that
    # would have been more work for little gain.
    #
    # The input file may be specified either as a filename or a
    # filehandle, or both.  If both are given, then the filename is
    # used only in reporting to help locate errors.  _Some_ value must
    # be given for the filename: an empty string is OK.
    #
    # (In case you're wondering, the main reason this has to be an
    # instance method of the Game class rather than a standalone
    # function is that its behaviour is influenced by the game's
    # options.)
    #
    def compile_to_stdout(filename, fh = nil)
      compiler = ScottKit::Game::Compiler.new(self, filename, fh)
      compiler.compile_to_stdout
    end

    public :load, :compile_to_stdout # Must be visible to driver program
    public :roomname, :itemname # Needed by Condition.render()
    public :dputs # Needed for contained classes' debugging output
    public :dirname # Needed by compiler
    public :dark_flag= # Invoked from Instruction.execute()


    class Condition #:nodoc:
      OPS = [# Name, type of corresponding parameter
             [ "param",      :NONE ],   # 0
             [ "carried",    :item ],   # 1
             [ "here",       :item ],   # 2
             [ "present",    :item ],   # 3
             [ "at",         :room ],   # 4
             [ "!here",      :item ],   # 5
             [ "!carried",   :item ],   # 6
             [ "!at",        :room ],   # 7
             [ "flag",       :number ], # 8
             [ "!flag",      :number ], # 9
             [ "loaded",     :NONE ],   # 10
             [ "!loaded",    :NONE ],   # 11
             [ "!present",   :item ],   # 12
             [ "exists",     :item ],   # 13
             [ "!exists",    :item ],   # 14
             [ "counter_le", :number ], # 15
             [ "counter_gt", :number ], # 16
             [ "!moved",     :item ],   # 17
             [ "moved",      :item ],   # 18
             [ "counter_eq", :number ], # 19
            ]
      OPStoindex = {}; OPS.each.with_index { |x, i| OPStoindex[x[0]] = i }
      OPStotype = {}; OPS.each { |x| OPStotype[x[0]] = x[1] }

      def initialize(game, cond, value)
        @game, @cond, @value = game, cond, value
      end
    end


    class Instruction #:nodoc:
      OPS = [# Name, type of corresponding parameters
             [ "get",                   :item ],      # 52
             [ "drop",                  :item ],      # 53
             [ "goto",                  :room ],      # 54
             [ "destroy",               :item ],      # 55
             [ "set_dark",              :NONE ],      # 56
             [ "clear_dark",            :NONE ],      # 57
             [ "set_flag",              :number ],    # 58
             [ "destroy2",              :item ],      # 59
             [ "clear_flag",            :number ],    # 60
             [ "die",                   :NONE ],      # 61
             [ "put",                   :item_room ], # 62
             [ "game_over",             :NONE ],      # 63
             [ "look",                  :NONE ],      # 64
             [ "score",                 :NONE ],      # 65
             [ "inventory",             :NONE ],      # 66
             [ "set_flag0",             :NONE ],      # 67
             [ "clear_flag0",           :NONE ],      # 68
             [ "refill_lamp",           :NONE ],      # 69
             [ "clear",                 :NONE ],      # 70
             [ "save_game",             :NONE ],      # 71
             [ "swap",                  :item_item ], # 72
             [ "continue",              :NONE ],      # 73
             [ "superget",              :item ],      # 74
             [ "put_with",              :item_item ], # 75
             [ "look2",                 :NONE ],      # 76
             [ "dec_counter",           :NONE ],      # 77
             [ "print_counter",         :NONE ],      # 78
             [ "set_counter",           :number ],    # 79
             [ "swap_room",             :NONE ],      # 80
             [ "select_counter",        :number ],    # 81
             [ "add_to_counter",        :number ],    # 82
             [ "subtract_from_counter", :number ],    # 83
             [ "print_noun",            :NONE ],      # 84
             [ "println_noun",          :NONE ],      # 85
             [ "println",               :NONE ],      # 86
             [ "swap_specific_room",    :number ],    # 87
             [ "pause",                 :NONE ],      # 88
             [ "draw",                  :number ],    # 89
            ]
      OPStoindex = {}; OPS.each.with_index { |x, i| OPStoindex[x[0]] = 52+i }
      OPStotype = {}; OPS.each { |x| OPStotype[x[0]] = x[1] }

      def initialize(game, op)
        @game, @op = game, op
      end
    end


    class Action #:nodoc:
      attr_reader :verb, :noun, :conds, :instructions, :args
      attr_accessor :comment

      def initialize(game, verb, noun, conds, instructions, args)
        @game, @verb, @noun, @conds, @instructions, @args =
          game, verb, noun, conds, instructions, args
      end
    end


    class Room #:nodoc:
      attr_reader :desc, :exits

      def initialize(desc, exits)
        @desc, @exits = desc, exits
      end
    end


    class Item #:nodoc:
      attr_reader :desc, :name, :startloc
      attr_accessor :loc

      def initialize(desc, name, startloc)
        @desc, @name, @startloc = desc, name, startloc
      end
    end
  end
end


require_relative 'compile'
require_relative 'decompile'
require_relative 'play'
