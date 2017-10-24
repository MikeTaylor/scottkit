# -*- coding: utf-8 -*-

require 'pp'

module ScottKit
  class Game
    class Compiler
      private

      # Creates a new compiler for the specified game, set up ready to
      # compile the game in the specified file.
      #
      # The input file may be specified either as a filename or a
      # filehandle, or both.  If both are given, then the filename is
      # used only in reporting to help locate errors.  _Some_ value
      # must be given for the filename: an empty string is OK.
      #
      # (In case you're wondering, the main reason this has to be
      # passed a Game object is that the behaviour of compile is
      # influenced by the game's options.)
      #
      def initialize(game, filename, fh = nil)
        @game = game
        @lexer = Lexer.new(game, filename, fh)
      end

      # Compiles the specified game-source file, writing the resulting
      # object file to stdout, whence it should be redirected into a
      # file so that it can be played.  Yes, this API is sucky: it
      # would be better if we had a simple compile method that builds
      # the game in memory in a form that can by played, and which can
      # then also be saved as an object file by some other method --
      # but that would have been more work for little gain.
      #
      def compile_to_stdout
        begin
          tree = parse
          generate_code(tree)
          true
        rescue
          return false if String($!) == "syntax error"
          raise
        end
      end

      def parse
        ident, version, unknown1, unknown2, start, treasury, maxload,
        wordlen, lighttime, lightsource =
          nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
        rooms = [ CRoom.new(nil, nil, {}) ]
        items, actions, verbgroups, noungroups = [], [], [], []

        while peek != :eof
          case peek
          when :ident then skip; ident = match :symbol
          when :version then skip; version = match :symbol
          when :unknown1 then skip; unknown1 = match :symbol
          when :unknown2 then skip; unknown2 = match :symbol
          when :start then skip; start = match :symbol
          when :treasury then skip; treasury = match :symbol
          when :maxload then skip; maxload = match :symbol
          when :wordlen then skip; wordlen = match :symbol
          when :lighttime then skip; lighttime = match :symbol
          when :lightsource then skip; lightsource = match :symbol
          when :room then rooms << parse_room
          when :item then items << parse_item(rooms.size-1)
          when :action then actions << parse_action
          when :occur then actions << parse_occur
          when :verbgroup then verbgroups << parse_wordgroup
          when :noungroup then noungroups << parse_wordgroup
          else match nil, "new directive"
          end
        end

        if peek != :eof
          error "additional text remains after parsing"
        end

        CGame.new(ident, version, unknown1, unknown2, start, treasury,
                  maxload, wordlen, lighttime, lightsource, rooms,
                  items, actions, verbgroups, noungroups)
      end

      def parse_room
        match :room
        name = match :symbol
        desc = match :symbol
        exits = {}
        while peek == :exit
          match :exit
          direction = match :direction
          dest = match :symbol
          exits[direction] = dest
        end
        CRoom.new(name, desc, exits)
      end

      def parse_item(last_room)
        match :item
        name = match :symbol
        desc = match :symbol
        called, where = nil, nil
        while true
          case peek
          when :called then match :called; called = match :symbol
          when :at then match :at; where = match :symbol
          when :nowhere then match :nowhere; where = ROOM_NOWHERE
          when :carried then match :carried; where = ROOM_CARRIED
          else break
          end
        end
        CItem.new(name, desc, called, where ? where : last_room)
      end

      def parse_action
        match :action
        verb = match :symbol
        if peek == :when
          noun = nil
        elsif peek == ":" # to terminate single-word actions if no conditions
          skip
          noun = nil
        else
          noun = match :symbol
          skip if peek == ":" # optional
        end

        conds, instructions, comment = parse_actionbody
        CAction.new(verb, noun, conds, instructions, comment)
      end

      def parse_occur
        match :occur
        if peek == :percentage
          chance = match :percentage
          skip if peek == ":" # optional
        else
          chance = nil
        end

        conds, instructions, comment = parse_actionbody
        CAction.new(nil, chance, conds, instructions, comment)        
      end

      def parse_actionbody
        conds = []
        while peek == :when || peek == :and
          skip
          op = match([:symbol, :carried, :at])
          type = Condition::OPStotype[op] or
            error "unknown condition op '#{op}'"
          case type
          when :NONE then val = 0 # Any numeric value is fine here
          when :number then val = match :symbol
          when :room then val = match :symbol
          when :item then val = match :symbol
          else error "condition op '#{op}' has unknown type '#{type}'"
          end
          conds << [ op, val ]
        end

        instructions = []
        while peek == :symbol
          op = match :symbol
          if op == "print"
            val = [ match(:symbol) ]
          else
            type = Instruction::OPStotype[op] or
              error "unknown instruction op '#{op}'"
            case type
            when :NONE then val = []
            when :number then val = [ match(:symbol) ]
            when :room then val = [ match(:symbol) ]
            when :item then val = [ match(:symbol) ]
            when :item_item then val = [ match(:symbol), match(:symbol) ]
            when :item_room then val = [ match(:symbol), match(:symbol) ]
            else error "instruction op '#{op}' has unknown type '#{type}'"
            end
          end
          instructions << [ op, val ]
        end

        comment = nil
        if peek == :comment
          skip
          comment = match :symbol
        end

        [ conds, instructions, comment ]
      end

      def parse_wordgroup
        skip
        words = []
        while peek == :symbol
          words << match(:symbol)
        end
        words
      end

      # Skip over the current token
      def skip; match peek; end

      # Delegators through to the lexer class: just to keep parser source terse
      def peek; @lexer.peek; end
      def match(token, estr = nil); @lexer.match token, estr; end
      def error(str); @lexer.error str; end


      def generate_code(tree)
        lintOptions = @game.options[:lint] || ''
        @had_errors = false
        rooms = tree.rooms
        items = tree.items

        if (@game.options[:teleport])
          rooms.each.with_index { |room, i|
            next if i == 0
            instructions = [
              [ "print", "*** Fzing! ***" ],
              [ "goto", room.name ],
              [ "look" ]
            ]
            tree.actions.push CAction.new('teleport', room.name, [],
                                          instructions, '')
          }
        end

        if (@game.options[:superget])
          items.each.with_index { |item, i|
            next if i == 0
            instructions = [
              [ "print", "*** Fzapp! ***" ],
              [ "superget", item.name ],
            ]
            tree.actions.push CAction.new('sg', item.name, [],
                                          instructions, '')
          }
        end

        if tree.lightsource then
          # The light-source is always item #9, so swap as necessary
          lindex = items.index { |x| x.name == tree.lightsource } or
            gerror "lightsource '#{tree.lightsource}' does not exist"
          if (lindex != ITEM_LAMP)
            items << CItem.new(nil, "", nil, 0) while items.size <= ITEM_LAMP
            items[lindex], items[ITEM_LAMP] = items[ITEM_LAMP], items[lindex]
          end
        end

        # Make name->index maps for rooms and items
        roommap = { "_ROOM0" => 0 }
        itemmap = {}
        rooms.each.with_index { |room, index| roommap[room.name] = index }
        items.each.with_index { |item, index| itemmap[item.name] = index }

        startindex, treasuryindex = [ [ tree.start, "start" ],
                                      [ tree.treasury, "treasury" ]
                                      ].map {
          |ref| loc, caption = *ref
          !loc ? 1 : roommap[loc] or
            gerror "#{caption} room '#{loc}' does not exist"
        }

        begin # lint
          no_exits = []
          dead_ends = []
          rooms.each.with_index do |room, index|
            next if index == 0
            next if 
            if room.exits.length == 0
              no_exits.push room.name
            elsif room.exits.length == 1
              dead_ends.push room.name
            end
          end
          if lintOptions.match('e') && no_exits.length > 0
            gwarning "#{no_exits.length} rooms with no exits: " + no_exits.map { |x| "'#{x}'" }.join(', ')
          end
          if lintOptions.match('E') && dead_ends.length > 0
            gwarning "#{dead_ends.length} rooms that are dead ends: " + dead_ends.map { |x| "'#{x}'" }.join(', ')
          end
        end

        # Resolve room names in exits
        rooms.each do |room|
          room.exits.each do |dir, dest|
            room.exits[dir] = roommap[dest] or
              gerror "'#{dest}' (#{dir} from #{room.name}) does not exist"
          end
        end

        # Resolve room names in item locations
        items.each do |item|
          if item.where.class == String
            num = room_by_name(item.where, roommap) or
              gerror "location '#{item.where}' for #{item.desc}) does not exist"
            item.where = num
          end
        end

        # Map each verb and noun to group of all its synonyms
        @wordlen = Integer(tree.wordlen ||= 3)
        verbtogroup, nountogroup = [ tree.verbgroups,
                                     tree.noungroups ].map { |groups|
          groups = groups.map { |list| list.map { |word| word.upcase[0, @wordlen] } }
          res = {}
          groups.each do |list|
            list.each { |word| res[word] = list }
          end
          res
        }

        # Compile vocabulary, including synonyms.
        verbs = [ "AUT" ]
        nouns = [ "ANY" ]
        verbmap, nounmap = {}, {}

        # Verb 1 is GO, verb 10 is GET, verb 18 is DROP (always).
        [ ["go", 1], ["get", 10], ["drop", 18] ]. each do |pair|
          insert_word(verbtogroup, verbs, verbmap, *pair)
        end
        # Nouns 1-6 are directions: no synonyms possible
        0.upto(5).each do |i|
          insert_word(nountogroup, nouns, nounmap, @game.dirname(i), i+1)
        end


        # Messages from actions will be accumulated here
        messages = [ "" ]       # Maps message-number to message
        messagemap = {}         # Maps message to message-number

        # Instructions must not exceed four per batch
        actions = []
        tree.actions.each do |action|
          ins, acc = action.instructions, []
          while ins.size > 4
            acc.concat ins.shift(3)
            acc.push [ "continue" ]
          end
          acc.concat ins
          acc.push [0] while acc.size % 4 != 0

          # We now have batches of four instructions; each but the
          # first must be placed in a new action.
          action.instructions = acc.shift(4)
          actions << action
          actions << CAction.new(nil, 0, [], acc.shift(4), "cont", []) while
            acc.count != 0
        end

        # Resolve room and item names in actions and occurrences
        actions.each do |action|
          if action.verb
            # Actual actions
            action.verb = insert_word(verbtogroup, verbs, verbmap, action.verb)
            if action.noun
              action.noun = insert_word(nountogroup, nouns, nounmap,
                                        action.noun)
            else
              action.noun = 0
            end
          else
            # Occurrences
            action.verb = 0
            action.noun = Integer(action.noun || 100)
          end

          action.conds.each do |cond|
            op, arg = cond[0], cond[1]
            opcode = Condition::OPStoindex[op]
            type = Condition::OPStotype[op]
            raise "impossible unknown condition op '#{op}'" if
              !opcode || !type
            cond[0] = opcode
            case type
            when :NONE then # nothing to do
            when :number then cond[1] = Integer(cond[1])
            when :room then cond[1] = roommap[arg] or
                gerror "unknown room in condition '#{arg}'"
            when :item then cond[1] = itemmap[arg] or
                gerror "unknown item in condition '#{arg}'"
            else gerror "condition op '#{op}' has unknown type '#{type}'"
            end
          end

          gathered_args = []
          action.instructions.each do |ins|
            op, args = ins[0], ins[1]
            arg0, arg1 = *args
            if op == 0
              next
            elsif op == "print"
              arg0.gsub!('\n', "\n");
              arg0.gsub!('\t', "\t");
              if !(msgno = messagemap[arg0])
                messages << arg0
                msgno = messagemap[arg0] = messages.size-1
              end
              ins[0] = msgno <= 51 ? msgno : msgno+50
              next
            end
            opcode = Instruction::OPStoindex[op]
            type = Instruction::OPStotype[op]
            raise "impossible unknown instruction op '#{op}'" if
              !opcode || !type
            ins[0] = opcode
            case type
            when :NONE then # nothing to do
            when :number then gathered_args << Integer(arg0)
            when :room then gathered_args << (roommap[arg0] or
                gerror "unknown room in instruction '#{arg0}'")
            when :item then gathered_args << (itemmap[arg0] or
                gerror "unknown item in instruction '#{arg0}'")
            when :item_item then gathered_args << (itemmap[arg0] or
                gerror "unknown item in instruction '#{arg0}'")
              gathered_args << (itemmap[arg1] or
                gerror "unknown item in instruction '#{arg1}'")
            when :item_room then gathered_args << (itemmap[arg0] or
                gerror "unknown item in instruction '#{arg0}'")
              gathered_args << (roommap[arg1] or
                gerror "unknown room in instruction '#{arg1}'")
            else gerror "instruction op '#{op}' has unknown type '#{type}'"
            end
          end
          action.gathered_args = gathered_args
        end

        # Add auto-get names of items to vocabulary
        items.each do |item|
          insert_word(nountogroup, nouns, nounmap, item.called) if item.called
        end

        1.upto([ verbs.size-1, nouns.size-1 ].max) do |i|
          verbs[i] = "" if !verbs[i]
          nouns[i] = "" if !nouns[i]
        end

        return if @had_errors

        # Write header
        puts tree.unknown1 || 0
        puts items.size-1
        puts actions.size-1
        puts verbs.size-1
        puts rooms.size-1
        puts tree.maxload || -1
        puts startindex
        puts items.select { |x| x.desc[0] == "*" }.count
        puts tree.wordlen
        puts tree.lighttime || -1
        puts messages.size-1
        puts treasuryindex
        puts # Blank line

        # Actions
        actions.each do |action|
          print 150*action.verb + action.noun, " "

          print action.conds.map { |x| String(x[0] + 20 * x[1]) + " " }.join
          print action.gathered_args.map { |x| String(20*x) + " " }.join
          nconds = action.conds.size + action.gathered_args.size
          raise "condition has #{nconds} conditions" if nconds > 5
          (5-nconds).times { print "0 " }

          ins = action.instructions.map { |x| x[0] }
          (4-ins.count).times { ins << 0 }
          puts "#{150*ins[0] + ins[1]} #{150*ins[2] + ins[3]}\n"
        end
        puts # Blank line

        # Vocab
        verbs.each.with_index do |verb, i|
          puts "\"#{verb}\" \"#{nouns[i]}\""
        end
        puts # Blank line

        # Rooms
        rooms.each do |room|
          0.upto(5).each do |i|
            exit = room.exits[@game.dirname(i)]
            print(exit ? exit : 0, " ")
          end
          print "\"#{room.desc}\"\n"
        end
        puts # Blank line

        # Messages
        messages.each do |message|
          puts "\"#{message}\"\n"
        end
        puts # Blank line

        # Items
        items.each do |item|
          desc = item.desc
          desc += "/" + item.called.upcase[0, @wordlen] + "/" if item.called
          puts "\"#{desc}\" #{item.where}"
        end
        puts # Blank line

        # Action comments
        actions.each do |action|
          puts "\"#{action.comment || ""}\"\n"
        end
        puts # Blank line

        # Trailer
        puts tree.version || 0
        puts tree.ident || 0
        puts tree.unknown2 || 0
      end

      def room_by_name(loc, roommap)
        if @game.options[:bug_tolerant] && loc[0,5] == "_ROOM"
          Integer(loc[5,999])
        else
          roommap[loc]
        end
      end

      # Complex API here, sorry.  If word, or an equivalent word
      # according to synmap, is not already in list and map, inserts
      # it and its synonyms into both, with map hashing words to the
      # index they appear at.  Word is inserted at index if specified
      # and otherwise at the first free slot, or off the end if there
      # are no free slots.  Synonyms, if any, follow thereafter in a
      # block.  Returns the index of the word in list
      def insert_word(synmap, list, map, word, index = nil)
        word = word.upcase[0, @wordlen]
        syn = synmap[word] || [word]
        canonical = syn[0]
        return map[canonical] if map[canonical]
        if !index
          index = 1
          index += 1 while syn.each_index.any? { |i| list[index+i] != nil }
        end

        firstindex = index
        syn.each do |thisword|
          if list[index]
            return(gerror "can't insert word '#{thisword}' " +
                   "@at position #{index} -- got '#{list[index]}'")
          end
          list[index] = index == firstindex ? thisword : "*"+thisword
          map[thisword] = firstindex
          index += 1
        end
        firstindex
      end

      def gerror(str)
        $stderr.puts "error: #{str}"
        @had_errors = true
        0
      end

      def gwarning(str)
        $stderr.puts "warning: #{str}"
        0
      end

      public :compile_to_stdout # Must be visible to Game.compile()
      public :parse # Used by test_compile.rb


      CGame = Struct.new(:ident, :version, :unknown1, :unknown2,
                         :start, :treasury, :maxload, :wordlen,
                         :lighttime, :lightsource, :rooms, :items,
                         :actions, :verbgroups, :noungroups) #@private
      CRoom = Struct.new(:name, :desc, :exits) #@private
      #@private
      CItem = Struct.new(:name, :desc, :called, :where)
      # @private
      CAction = Struct.new(:verb, :noun, :conds, :instructions,
                           :comment, :gathered_args)


      class Lexer #:nodoc:
        attr_reader :lexeme

        TOKENMAP = {
          "start" => :start,
          "treasury" => :treasury,
          "ident" => :ident,
          "version" => :version,
          "unknown1" => :unknown1,
          "unknown2" => :unknown2,
          "maxload" => :maxload,
          "wordlen" => :wordlen,
          "lighttime" => :lighttime,
          "lightsource" => :lightsource,
          "room" => :room,
          "exit" => :exit,
          "north" => :direction, "south" => :direction, "east" => :direction,
          "west" => :direction, "up" => :direction, "down" => :direction,
          "item" => :item,
          "called" => :called,
          "at" => :at,
          "nowhere" => :nowhere,
          "carried" => :carried,
          "action" => :action,
          "occur" => :occur,
          "when" => :when,
          "and" => :and,
          "comment" => :comment,
          "verbgroup" => :verbgroup,
          "noungroup" => :noungroup,
        }

        def initialize(game, filename, fh = nil)
          if !fh
            fh = File.new(filename)
          end
          @game, @filename, @fh = game, filename, fh
          @linenumber = 0
          @buffer = ""
          @lookahead = nil
        end

        def error(str)
          filename = (defined? @filename) ? @filename : "<UNKNOWN>"
          $stderr.puts "#{filename}:#{@linenumber}:#{str}"
          raise "syntax error"
        end

        def lex
          token = _lex
          @game.dputs :show_tokens, "token: #{render(token)}"
          token
        end

        def _lex
          @buffer.lstrip!
          while @buffer == "" do
            if !(@buffer = @fh.gets)
              return :eof
            end
            @linenumber += 1
            @buffer.chomp!
            @buffer.rstrip!
            @buffer.lstrip!
          end

          if @buffer[0] == "#"
            # Comment runs to end of line
            @buffer = ""
            return _lex # Be honest, a GOTO would be better here
          elsif match = @buffer.match(/^"(.*?)"/)
            @lexeme, @buffer = match[1], match.post_match
            :symbol
          elsif match = @buffer.match(/^"(.*)/)
            # Multi-line string -- can include hashes and indents
            s = match[1]
            while @buffer = @fh.gets
              @linenumber += 1
              @buffer.chomp!
              if match = @buffer.match(/(.*?)"/)
                @lexeme = s + "\n" + match[1]
                @buffer = match.post_match
                break
              else
                s += "\n" + @buffer
              end
            end
            :symbol
          elsif match = @buffer.match(/^(\d+)%/)
            @lexeme, @buffer = match[1], match.post_match
            :percentage
          elsif match = @buffer.match(/^([!a-z_0-9-]+)/i)
            @lexeme, @buffer = match[1], match.post_match
            TOKENMAP[@lexeme] || :symbol
          else
            # Must be a single character
            @lexeme = @buffer[0]
            @buffer[0] = ""
            @lexeme
          end
        end

        def peek
          @lookahead ||= lex
        end

        def match(expected, estr = nil)
          token = peek
          @lookahead = nil
          if (expected.kind_of?(Array))
            ok = expected.any? {|x| token == x}
          else
            ok = token == expected
          end
          if (!ok)
            error("expected #{estr || expected}, got #{render(token)}" +
                  " (before `#{@buffer.lstrip}')")
          end
          @lexeme
        end

        def render(token)
          extra = render_lexeme(token, @lexeme)
          extra ? "#{token} #{extra}" : token
        end

        def render_lexeme(token, lexeme)
          if token == :direction
            lexeme
          elsif token == :symbol
            "\"#{lexeme}\""
          elsif token == :percentage
            "'#{lexeme}%'"
          else
            nil
          end
        end
      end
    end
  end
end
