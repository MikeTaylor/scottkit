module ScottKit
  class Game
    private

    def quote(token) #:nodoc:
      if ((token !~ /^([!a-z_0-9-]+)$/i || token =~ /\n/) ||
          Compiler::Lexer::TOKENMAP[token])
        "\"#{token.gsub(/[""]/, '\'')}\""
      else
        token
      end
    end

    def decompile(f)
      f << "# #{@rooms.size} rooms, "
      f << "#{@items.size} items, "
      f << "#{@actions.size} actions\n"
      f << "# #{@messages.size} messages, "
      f << "#{defined?(@ntreasures) ? @ntreasures : "UNDEFINED"} treasures, "
      f << "#{@verbs.size} verbs/nouns\n"
      f.puts "ident #{@id}" if defined? @id
      f.puts "version #{@version}" if defined? @version
      f.puts "wordlen #{@wordlen}" if defined? @wordlen
      f.puts "maxload #{@maxload}" if defined? @maxload
      f.puts "lighttime #{@lamptime}" if defined? @lamptime
      f.puts "unknown1 #{@unknown1}" if defined? @unknown1
      f.puts "unknown2 #{@unknown2}" if defined? @unknown2
      f.puts "start #{quote roomname @startloc}" if defined? @startloc
      ### Do NOT change the nested if's to a single &&ed one: for
        # reasons that I do not at all understand, doing so results in
        # the protected statement being executed when @treasury is 0
      if defined? @treasury
        if @treasury != 0
          f.puts "treasury #{quote roomname @treasury}" 
        end
      end
      f.puts
      decompile_wordgroup(f, @verbs, "verb")
      decompile_wordgroup(f, @nouns, "noun")

      @rooms.each.with_index do |room, i|
        next if i == 0
        f.puts "room " << quote(roomname(i)) << " \"#{room.desc}\""
        room.exits.each.with_index do |exit, j|
          if exit != 0
            f.puts "\texit #{dirname(j)} #{quote roomname(exit)}"
          end
        end
        f.puts
      end

      @items.each.with_index do |item, i|
        f.puts "item #{quote itemname(i)} \"#{item.desc}\""
        f.puts "\tcalled #{quote item.name}" if item.name
        f.puts case item.startloc
               when ROOM_CARRIED then "\tcarried"
               when ROOM_NOWHERE then "\tnowhere"
               else "\tat #{quote roomname(item.startloc)}"
               end
        f.puts
      end

      @actions.each { |action| action.decompile(f) }
    end

    def decompile_wordgroup(f, list, label)
      canonical = nil
      synonyms = []
      printed = false

      list.each.with_index do |word, i|
        if (word =~ /^\*/)
          synonyms << word.sub(/^\*/, "")
        end
        if (word !~ /^\*/ || i == list.size-1)
          if synonyms.size > 0
            f.print "#{label}group #{quote canonical} "
            f.puts synonyms.map { |token| quote token }.join(" ")
            printed = true
          end
          canonical = word
          synonyms = []
        end
      end

      f.puts if printed
    end

    public :decompile # Must be visible to driver program
    public :quote # Needed for contained classes' decompile()/render() methods


    class Action
      def quote(*args); @game.quote(*args); end

      def decompile(f)
        emitted_noun_or_condition = false
        if self.verb == 0 then
          f << "occur"
          f << " " << self.noun << "%" if self.noun != 100
        else
          f << "action #{quote @game.verbs[self.verb]}"
          if self.noun != 0
            f << " #{quote @game.nouns[self.noun]}"
            emitted_noun_or_condition = true
          end
        end
        self.conds.each.with_index do |cond, i|
          f << (i == 0 ? " when " : " and ") << cond.render
          emitted_noun_or_condition = true
        end
        f << ":" if self.verb != 0 && !emitted_noun_or_condition
        f.puts
        args = @args.clone
        self.instructions.each do |instruction|
          f.puts "\t" + instruction.render(args)
        end
        if (self.comment != "")
          f.puts "\tcomment \"#{self.comment}\""
        end
        f.puts
      end
    end

    class Condition
      def quote(*args); @game.quote(*args); end

      def render
        type = OPS[@cond][1]
        res = quote(OPS[@cond][0])
        res += " " +
          quote(type == :room ? @game.roomname(@value) :
                type == :item ? @game.itemname(@value) :
                type == :number ? String(@value) : "ERROR") if
          type != :NONE
        res
      end
    end

    class Instruction
      def quote(*args); @game.quote(*args); end

      def render(args)
        if (@op == 0)
          return "NOP" # shouldn't happen
        elsif (@op <= 51)
          return "print #{quote @game.messages[@op]}"
        elsif (@op >= 102)
          return "print #{quote @game.messages[@op-50]}"
        end

        op = OPS[@op-52]
        return "UNKNOWN_OP" if !op
        op[0] + case op[1]
        when :item
          " #{quote @game.itemname(args.shift)}"
        when :room
          " #{quote @game.roomname(args.shift)}"
        when :number
          " #{@game.quote String(args.shift)}"
        when :item_item
          " #{quote @game.itemname(args.shift)}" +
          " #{quote @game.itemname(args.shift)}"
        when :item_room
          " #{quote @game.itemname(args.shift)}" +
          " #{quote @game.roomname(args.shift)}"
        when :NONE
          "" # Nothing to add
        else
          " UNKNOWN_PARAM"
        end
      end
    end
  end
end
