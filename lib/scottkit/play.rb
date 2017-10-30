module ScottKit
  class Game
    # Returns 1 if the game was won, 0 otherwise
    def play
      prepare_to_play

      while !finished?
        prompt_for_turn

        if !(line = gets)
          # End of file -- we're done
          puts
          break
        end

        process_turn(line)
      end

      return @finished
    end

    def prepare_to_play
      @finished = nil
      @items.each { |x| x.loc = x.startloc }
      @flags = Array.new(NFLAGS) { false } # weird way to set a default
      @counters = Array.new(NFLAGS) { 0 }
      @saved_rooms = Array.new(NFLAGS) { 0 }
      @counter = 0
      @saved_room = 0
      @loc = defined?(@startloc) ? @startloc : 1
      @lampleft = defined?(@lamptime) ? @lamptime : 0
      @need_to_look = true;

      puts "ScottKit, a Scott Adams game toolkit in Ruby."
      puts "(C) 2010-2017 Mike Taylor <mike@miketaylor.org.uk>"
      puts "Distributed under the GNU GPL version 2 license."

      if file = options[:restore_file]
        restore(file)
        puts "Restored saved game #{file}"
      end

      if seed = options[:random_seed]
        puts "Setting random seed #{seed}"
        srand(seed)
      end

      @fh = nil
      if file = options[:read_file]
        @fh = File.new(file)
        raise "#$0: can't read input file '#{file}': #$!" if !@fh
      end
    end

    def prompt_for_turn
      run_matching_actions(0, 0)

      actually_look if @need_to_look

      print "Tell me what to do ? "
    end

    def process_turn(line)
      words = line.chomp.split
      if words.length == 0
        puts "I don't understand your command."
        return
      end

      execute_command(words[0], words[1])

      process_lighting
    end

    def finished?
      !@finished.nil?
    end

    private

    def process_lighting
      if items.size > ITEM_LAMP && items[ITEM_LAMP].loc != ROOM_NOWHERE && @lampleft > 0
        @lampleft -= 1
        if @lampleft == 0
          puts "Your light has run out"
          @flags[FLAG_LAMPDEAD] = true
          if is_dark
            need_to_look
          end
        elsif @lampleft < 25 && @lampleft % 5 == 0
        puts("Your light is growing dim.");
        end
      end
    end

    # Get a line from @fh if defined, otherwise $stdin
    def gets
      line = nil
      if (@fh)
        line = @fh.gets
        @fh = nil if !line
      end
      line = $stdin.gets if !line
      return nil if !line
      puts line if @fh || options[:echo_input]
      line
    end

    # Returns index of word in list, or nil if not in vocab
    # Word may be undefined, in which case 0 is returned
    def findword(word, list)
      return 0 if !word
      word = (word || "").upcase[0, @wordlen]
      list.each.with_index do |junk, index|
        target = list[index].upcase
        if word == target[0, @wordlen]
          return index
        elsif target[0] == "*" && word == target[1, @wordlen+1]
          while list[index][0] == "*"
            index -= 1
          end
          return index
        end
      end
      return nil
    end

    def execute_command(verb, noun)
      if (options[:wizard_mode] && verb)
        if wizard_command(verb, noun)
          return
        end
      end
      if verb.upcase == "#LOAD"
        restore(noun)
        return
      end

      verb = "inventory" if verb == "i"
      verb = "look" if verb == "l"
      @noun = noun
      vindex = findword(verb, verbs)
      nindex = findword(noun, nouns)
      if !vindex && !noun
        if tmp = findword(verb, nouns) || findword(verb, %w{XXX n s e w u d})
          vindex, nindex = VERB_GO, tmp
        end
      end

      if !vindex || !nindex
        puts "You use word(s) I don't know!"
        return
      end

      dputs :show_parse, "vindex=#{vindex}, nindex=#{nindex}"
      case run_matching_actions(vindex, nindex)
      when :success then return
      when :failconds then recognised_command = true
      when :nomatch then recognised_command = false
      end

      # Automatic GO
      1.upto 6 do |i|
        if vindex == VERB_GO && nindex == i
          puts "Dangerous to move in the dark!" if is_dark
          newloc = @rooms[@loc].exits[i-1]
          if newloc != 0
            @loc = newloc
            need_to_look
          elsif is_dark
            puts "I fell down and broke my neck."
            finish(0)
          else
            puts "I can't go in that direction."
          end
          return
        end
      end

      # Automatic GET/DROP
      if (vindex == VERB_GET)
        return autoget(nindex)
      elsif (vindex == VERB_DROP)
        return autodrop(nindex)
      end

      if (recognised_command)
        puts "I can't do that yet."
      else
        puts "I don't understand your command."
      end
    end

    def run_matching_actions(vindex, nindex)
      recognised_command = false
      @actions.each_index do |i|
        action = @actions[i]
        if vindex == action.verb &&
            (vindex == 0 || (nindex == action.noun || action.noun == 0))
          recognised_command = true
          case action.execute(vindex == 0)
          when :failconds
            # Do nothing
          when :success
            return :success if vindex != 0
          when :continue
            while true
              action = @actions[i += 1]
              break if !action || action.verb != 0 || action.noun != 0
              action.execute(false)
            end
            return :success if vindex != 0
          end
        end
      end
      return recognised_command ? :failconds : :nomatch
    end

    def wizard_command(verb, noun)
      optnames = {
        "c" => :show_conditions,
        "i" => :show_instructions,
        "r" => :show_random,
        "p" => :show_parse,
      }

      if verb.upcase == "#SG" # superget
        i = Integer(noun)
        if (i < 0 || i > @items.count)
          puts "#{i} out of range 0..#{@items.count}"
        else
          @items[i].loc = ROOM_CARRIED
          puts "Supergot #{@items[i].desc}"
        end
      elsif verb.upcase == "#GO" # teleport
        i = Integer(noun)
        if (i < 0 || i > @rooms.count)
          puts "#{i} out of range 0..#{@rooms.count}"
        else
          @loc = i
          need_to_look
        end
      elsif verb.upcase == "#WHERE" # find an item
        i = Integer(noun)
        if (i < 0 || i > @items.count)
          puts "#{i} out of range 0..#{@items.count}"
        else
          item = @items[i]
          loc = item.loc
          puts "#Item #{i} (#{item.desc}) at room #{loc} (#{rooms[loc].desc})"
        end
      elsif verb.upcase == "#SET"
        if (sym = optnames[noun])
          @options[sym] = true
        else
          puts "Option '#{noun}' unknown"
        end
      elsif verb.upcase == "#CLEAR"
        if (sym = optnames[noun])
          @options[sym] = false
        else
          puts "Option '#{noun}' unknown"
        end
      else
        return false
      end
      true
    end

    def autoget(nindex)
      return puts "What ?" if nindex == 0
      noun = @nouns[nindex].upcase[0, @wordlen]
      if !(item = @items.find { |x| x.name == noun && x.loc == @loc })
         puts "It's beyond my power to do that."
      elsif ncarried == @maxload
        puts "I've too much to carry!"
      else
        item.loc = ROOM_CARRIED
        puts "O.K."
      end
    end

    def autodrop(nindex)
      return puts "What ?" if nindex == 0
      noun = @nouns[nindex].upcase[0, @wordlen]
      if !(item = @items.find { |x| x.name == noun && x.loc == ROOM_CARRIED })
        puts "It's beyond my power to do that."
      else
        item.loc = @loc
        puts "O.K."
      end
    end

    def need_to_look(val = :always)
      @need_to_look = val
    end

    def actually_look #:nodoc:
      @need_to_look = nil;

      puts
      if is_dark
        return print "I can't see. It is too dark!\n\n"
      end

      room = @rooms[@loc]
      s = room.desc
      if s =~ /^\*/
        puts s.sub(/^\*/, "")
      else
        puts "I'm in a #{s}"
      end
      if (room.exits.find { |x| x != 0 })
        print "Obvious exits: "
        puts room.exits.each.with_index.map { |x, i| [ i, x ] }.
          select { |x| x[1] != 0 }.
          map { |x| dirname(x[0]).capitalize }.join(", ") + "."
      end
      if @items.find { |x| x.loc == @loc }
        print "I can also see: "
        puts @items.select { |x| x.loc == @loc }.
          map { |x| x.desc.gsub('`', '"') }.join(", ")
      end
      puts
    end

    def inventory #:nodoc:
      puts "I'm carrying:"
      carried = items.select { |x| x.loc == ROOM_CARRIED }.map { |x| x.desc }
      puts((carried.size == 0 ? "Nothing" : carried.join(" - ")) + ".")
    end

    def score #:nodoc:
      count = @items.select { |item|
        item.desc[0] == "*" && item.loc == @treasury
      }.count
      print "I've stored #{count} treasures.  "
      puts "On a scale of 0 to 100, that rates #{100*count/@ntreasures}."
      if (count == @ntreasures)
        puts "Well done."
        finish(1)
      end
    end

    def prompt_and_save #:nodoc:
      print "Filename: "
      name = gets || return
      name.chomp!
      save(name)
    end

    def finish(win) #:nodoc:
      puts "The game is now over."
      sleep 2 if !options[:no_wait]
      @finished = win
    end

    def ncarried #:nodoc:
      items.select { |x| x.loc == ROOM_CARRIED }.size
    end

    def is_dark
      return @flags[15] if @items.size <= ITEM_LAMP
      loc = @items[ITEM_LAMP].loc
      #puts "dark_flag=#{@flags[15]}, lamp(#{ITEM_LAMP}) at #{loc}"
      @flags[15] && loc != ROOM_CARRIED && loc != @loc
    end

    # Invoked from Instruction.execute()
    public :prompt_and_save, :need_to_look, :score, :ncarried, :inventory, :finish

    class Condition
      def evaluate
        loc = @game.loc
        item = @game.items[@value]
        case @cond
        when  0 then raise "unexpected condition code 0"
        when  1 then item.loc == ROOM_CARRIED
        when  2 then item.loc == loc
        when  3 then item.loc == ROOM_CARRIED || item.loc == loc
        when  4 then loc == @value
        when  5 then item.loc != loc
        when  6 then item.loc != ROOM_CARRIED
        when  7 then loc != @value
        when  8 then @game.flags[@value]
        when  9 then !@game.flags[@value]
        when 10 then @game.ncarried != 0
        when 11 then @game.ncarried == 0
        when 12 then item.loc != ROOM_CARRIED && item.loc != loc
        when 13 then item.loc != ROOM_NOWHERE
        when 14 then item.loc == ROOM_NOWHERE
        when 15 then @game.counter <= @value
        when 16 then @game.counter > @value
        when 17 then item.loc == item.startloc
        when 18 then item.loc != item.startloc
          # From the description, it seems that perhaps "moved" should
          # be true if the object has EVER been moved; but the ScottFree
          # code implements it as I have done here.
        when 19 then @game.counter == @value
        else raise "unimplemented condition code #@cond"
        end
      end
    end


    class Instruction
      # Returns true iff interpreter should continue to next action
      def execute(args)
        @game.dputs :show_instructions,
          "    executing #{self.render(args.clone)}"
        if (@op == 0)
          return false # shouldn't happen
        elsif (@op <= 51)
          @game.puts @game.messages[@op].gsub('`', '"')
          return false
        elsif (@op >= 102)
          @game.puts @game.messages[@op-50].gsub('`', '"')
          return false
        else case @op
        when 52 then
          if @game.ncarried == @game.maxload
            @game.puts "I've too much to carry!"
          else
            @game.items[args.shift].loc = ROOM_CARRIED
          end
        when 53 then @game.items[args.shift].loc = @game.loc
        when 54 then @game.loc = args.shift
        when 55 then @game.items[args.shift].loc = ROOM_NOWHERE
        when 56 then @game.flags[15] = true
        when 57 then @game.flags[15] = false
        when 58 then @game.flags[args.shift] = true
        when 59 then @game.items[args.shift].loc = ROOM_NOWHERE
        when 60 then @game.flags[args.shift] = false
        when 61 then
          @game.puts "I am dead."; @game.flags[15] = false;
          @game.loc = @game.rooms.size-1; @game.need_to_look
        when 62 then i = args.shift; @game.items[i].loc = args.shift
        when 63 then @game.finish(0)
        when 64 then @game.need_to_look
        when 65 then @game.score
        when 66 then @game.inventory
        when 67 then @game.flags[0] = true
        when 68 then @game.flags[0] = false
        when 69 then
          @game.items[ITEM_LAMP].loc = ROOM_CARRIED
          @game.lampleft = @game.lamptime
          @game.flags[FLAG_LAMPDEAD] = false
        when 70 then # do nothing
        when 71 then @game.prompt_and_save
        when 72 then
          item1 = @game.items[args.shift]
          item2 = @game.items[args.shift]
          item1.loc, item2.loc = item2.loc, item1.loc
        when 73 then return true
        when 74 then @game.items[args.shift].loc = ROOM_CARRIED
        when 75 then i1 = args.shift; i2 = args.shift
          @game.items[i1].loc = @game.items[i2].loc
        when 76 then @game.need_to_look
        when 77 then @game.counter -= 1
        when 78 then @game.print @game.counter, " "
        when 79 then @game.counter = args.shift
        when 80 then @game.loc, @game.saved_room = @game.saved_room, @game.loc
        when 81 then which = args.shift
          @game.counter, @game.counters[which] =
            @game.counters[which], @game.counter
        when 82 then @game.counter += args.shift
        when 83 then @game.counter -= args.shift
        when 84 then @game.print @game.noun
        when 85 then @game.puts @game.noun
        when 86 then @game.puts
        when 87 then which = args.shift
          @game.loc, @game.saved_rooms[which] =
            @game.saved_rooms[which], @game.loc
        #87 swap_specific_room unused in Adventureland/Pirate
        when 88 then sleep 2 if !@game.options[:no_wait]
        #88 wait unused in Adventureland/Pirate
        #89 draw unused in Adventureland/Pirate
        else raise "unimplemented instruction code #@op"
        end
        end
        return false
      end
    end


    class Action
      def execute(test_chance)
        log = ''
        all_conds_true = @conds.map { |x| t = x.evaluate
          log += "(#{x.render()})=#{t} ";
          t }.
        reduce(true) { |acc, val| acc && val }
        @game.dputs :show_conditions, "#{log}-> #{all_conds_true}"
        return :failconds if !all_conds_true

        if (test_chance && @verb == 0 && @noun < 100)
          # It's an occurrence and may be random
          dice = Integer(rand()*100)
          if dice >= @noun
            @game.dputs :show_random, "  #{dice} >= #{@noun}% -> nop"
            return :success
          else
            @game.dputs :show_random, "  #{dice} < #{@noun}%"
          end
        end

        args = @args.clone
        seen_continue = @instructions.reduce(false) do |acc, x|
          tmp = x.execute(args)
          acc || tmp
        end
        seen_continue ? :continue : :success
      end
    end
  end
end
