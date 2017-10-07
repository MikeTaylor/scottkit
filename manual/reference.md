The ScottKit reference manual
=============================

This is the Reference Manual for the Scott Adams Adventure toolkit,
ScottKit, which is freely available as a Ruby gem or from
[http://github.com/MikeTaylor/scottkit](http://github.com/MikeTaylor/scottkit)

Like the software itself, this manual was written by
Mike Taylor &lt;mike@miketaylor.org.uk&gt;

> **NOTE.**
> This manual was adapted from that of my old Perl module [Games::ScottAdams](http://www.miketaylor.org.uk/tech/advent/sac/Manual.html)
> and may not yet be fully updated to reflect the better syntax of ScottKit.
> Please let me know about any mistakes!


## Synopsis

	# foo.sck - definition file for Scott Adams adventure "foo"

	room swamp "dismal swamp"
	  exit north meadow
	  exit east edge
	  exit west grove

	item mud "Evil smelling mud"
	  called mud

	action take mud when here mud and carried bites
	  get mud
	  destroy bites
	  print "BOY that really hit the spot!"


## Description

The Scott Adams toolkit, `scottkit`, allows you create adventure games in
a straightforward syntax, and compiles them into the format that was
used in the classic Scott Adams adventures - and which is therefore
now understood by ScottFree and various other interpreters for
those old games.

If you're running a Linux system, there's a fair chance that you
already have such an interpreter on your system - it's probably called
`scottfree`, `ScottCurses`, `GnomeScott` or something similar.
Certainly Red Hat Linux distributions from 4.0 onwards (and maybe much
earlier) have come with Scott Adams interpreters.

This manual describes the syntax of the `sck` file which `scottkit`
compiles into Scott Adams format.

All of the examples are taken from Scott Adams' first game, the
classic *Adventureland* - a game dripping with atmosphere and
nostalgia which I can't recommend highly enough.


## Overview

Comments may appear anywhere in a ScottKit file, and have no effect on
the compiled adventure.  They are introduced by a hash character
(`#`) and extend to the end of the line.

Completely blank lines (and those which are completely blank after
comments have been removed) may appear anywhere in the file, and have
no effect on the compiled adventure.

All data is introduced by a *directive* - that is, a line which
begins with a recognised keyword
specifying which directive is being used.  Common examples include
`room`, `exit`, `item` and `action`.  Directive names are
case-insensitive, so that `room`, `ROOM`, `Room` and indeed
`rOoM` all mean the same thing.

We describe the directives in four categories, corresponding to the
four fundamental concepts in Scott Adams adventures: the *rooms*
through which the player moves, the *items* found in those rooms, the
*actions* which the player can perform, and *global parameters*.

With one exception, the order in which directives and their associated
data appear is not significant.  This yields important flexibility in
how the adventure definition file is laid out: for example, all the
rooms may appear together followed by the items, or each room may be
followed by the items which appear in it; items not initially in play
may be listed first or all, or at the end, or after the rooms in which
they will be brought into being during the game.

The one exception to this order-independence is that the order in
which actions appear is significant, because on each turn, each
possible action is considered in the order that appear.  Ordering
issues are discussed in more detail in the section about the
`action` directive, but in summary: while the order of actions
relative to other actions is in some cases significant, the position
of actions relative to rooms, items and global parameters is not.
Actions may be moved ahead of and behind rooms, items and global
parameters with impunity.


## Rooms

The first fundamental concept of Scott Adams adventures is the rooms:
a connnected network of nodes between which the player can move using
the four primary compass directions plus Up and Down.  With typical
topography, after moving north from one room to another, it's possible
to move south back to the first room - but the system does not enforce
this, making it possible to create complex mazes.

Each room in a ScottKit file is identified by a unique name - typically
short, and made up of alphanumerics, possibly with underscores,
although the only restriction enforced is that it may not contain any
whitespace characters (space, tab, *etc.*)

After its name comes a description enclosed in double quotes (which
may extend across multiple lines) and a set of available exits, each
exit specifying its destination room.


### room

	room chamber "root chamber under the stump"

Creates a new room whose name is the word immediately after the
`room` directive, on the same line.  The following string is the
description of this room, which is what the player sees.  (The name,
by contrast, is used only by `scottkit` itself, as an identifying tag when
the room must be referred to when defining an exit, item or action.)

For historical reasons, Scott Adams interpreters such as ScottFree
emit the string "I'm in a " (or "You're in a ", if the appropriate
option is specified) before room descriptions, so that the room
defined above would be described as

	I'm in a root chamber under the stump

When this behaviour is not desired, it can be overridden by beginning
the room description with an asterisk (`*`), which is not printed but
inhibits the automatic initial string.  For example, the room
definition

	room ledge1 "*I'm on a narrow ledge by a chasm. Across the chasm is
	the Throne-room"

is described to the player simply as

	I'm on a narrow ledge by a chasm. Across the chasm is
	the Throne-room

### exit

	exit up stump

Specifies that it's possible to move from the most recently defined
room in the direction indicated by the first argument, and that doing
so takes the player to the destination indicated by the second
argument.  Rooms may have any number of exits from zero to all
six.

The first argument to the `%room` directive must be one of the directions
`north`,
`south`,
`east`,
`west`,
`up` or
`down`
(or their upper-case equivalents), indicating exits in the specified
directions.

The second argument must be the name of a room defined somewhere in
the ScottKit file.  The destination room's definition may be either
previous or subsequent - forward references are just fine.

It's OK for an exit to lead back to the room it came from, and for
more than one exit to lead in the same direction, as in the following
example:

	room forest "forest"
	  exit north forest
	  exit south forest
	  exit east meadow
	  exit west forest


## Items

The second fundamental concept of Scott Adams adventures is the items:
things that reside in a room, and in some cases can be picked up,
carried around and left in other rooms.  Typically, some of the items
are "objects" like axes and keys, while others are "scenery" like
trees, signs, *etc.*

As with rooms, each item in a ScottKit file is identified by a unique
name - typically a short, alphanumeric-plus-underscores name.  Because
the concepts of room and item are so distinct in the Scott Adams
model, it's OK for a room and an item to share the same name.  In fact
this is often the obvious thing to do - for example, consider a
situtation where the player can see a tunnel, then type `ENTER
TUNNEL` to move inside the tunnel.  In this case, it's natural for
both the tunnel item and the tunnel room to have the name `tunnel`.

Apart from its name, an item is defined by its location and possibly
by a name by which it's called when getting or dropping it - see below.

### item

	item rubies "*Pot of RUBIES*"

Creates a new item whose name is the word immediately after the
`item` directive, on the same line. The following string is the
description of this item, which is what the player sees.  (The name is
used only as an identifying tag.)

If the item description begins with an asterisk (`*`) then it is considered
to be a treasure: it, along with any other treasures, must be
deposited in the treasury (see below) in order to score points.  The
asterisk is displayed to the user; traditionally, another asterisk
appears at the end of treasure descriptions, but this is not enforced.

### at

	at chamber

By default, each item starts the game in the last room defined before
its `item` directive; this means that sequences like the following
do The Right Thing:

	room lake "*I'm on the shore of a lake"
	item water "water"
	item fish "*GOLDEN FISH*"

However, in some cases, it may be convenient to define items at some
other point in a ScottKit file - for example, some authors may prefer to
list all rooms together, then all items together.  In such cases,
an item may be relocated to its correct starting room by providing a
`at` directive followed by the name of that room:

	room lake "*I'm on the shore of a lake"
	room meadow "sunny meadow"
	item water "water"
	at lake

Items defined earlier in the ScottKit file than the first `room`
directive are by default not in the game when it starts (though they
may subsequently be brought into the game by DROP actions or similar -
see below.)  This can of course be changed with `at` directives,
since here as everywhere else, forward references to rooms that have
not yet been defined are OK.

### nowhere

	nowhere

Conversely, when defining an item that should not initially be in
play, it may be convenient to place the definition at a point in the
ScottKit file that places it in a room.  In this case, the `nowhere`
directive can be used to start it off out of play.  This is
particularly useful if, for example, an item initially in play is
later to be replaced by one that is initially absent:

	room stump "damp hollow stump in the swamp"
	item wbottle "Water in bottle:
	item ebottle "Empty bottle"
	  nowhere
	  # will come into play when water is drunk

### %getdrop

	%getdrop lamp

Some of the items in a game - those described above as "objects"
rather than "scenery" - can be picked up and dropped.  Rather than
laboriously coding these actions by hand, it's possible to have the
game automatically handle the GET and DROP actions.  In order to do
this, it needs to know the word the user will use to specify the item,
and this is what the `%getdrop` directive provides:

	%item lamp
	Old fashioned brass lamp
	%getdrop lamp

If no `%getdrop` name is provided, then it will not be possible for
the player to pick up or drop the item unless explicit actions are
coded to make this possible.

## Actions

The third fundamental concept of Scott Adams adventures is the
actions: things which the player can do, or which can happen to him,
which result in changes to the state of the world.

State consists primarily of the items' locations, but there are also
some boolean flags, integer counters and saved room-numbers.  The
flags are all set to be false at the start of the game; flag number
15 is special, and indicates whether or not it's dark.  If it is, then
the player can't see without a light source.

No-one seems to know for sure how many flags were supported by the
original Scott interpreters, but by inspection, *Adventureland* uses
flags 1 to 17, missing out flag 6 for some reason, and making only a
single reference to flag 4 (so that it's not really "used" in
any meaningful sense.)

=over 4

=item *

**Note.** The only reference to flag 4 is that it's cleared when the axe is
thrown at the bear, misses and breaks the mirror (and it's never
tested anywhere).  Inspection of the other axe-throwing actions
suggests that this is a mistake, and that Scott intended to clear flag
3.  And sure enough, the behaviour if you say `at bear` twice after
`throw axe` is wrong: it understands the context-less second `at
bear` command instead of refusing is and saying "What?":

	Tell me what to do ? throw axe
	In 2 words tell me at what...like: AT TREE

	Tell me what to do ? at bear
	OH NO... Bear dodges... CRASH!

	Tell me what to do ? at bear
	OK, I threw it.
	A voice BOOOOMS out:
	please leave it alone

	Tell me what to do ? at bear
	What?

This is not really relevant to ScottKit, but interesting trivia
nevertheless.  It's funny to find someone's bug twenty-two years after
it was created!

=back

Anyway, ScottFree implements 32 flags, and a comment in the source
code says that the author's never seen a game that uses a flag
numbered higher than that.

There are sixteen counters available, and sixteen slots in which room
numbers can be stored.  The latter can be used to implement
sophisticated vehicles and spells which return the player to a room
that was specified earlier - for example, the `YOHO` spell in
*Sorceror of Claymorgue Castle*, which moves you first to a
destination, then back to where you first cast it (I think.)

=over 4

=item *

[Truth is, I'm not at all sure how the
room-number slots are used; this facility is not used at all in
*Adventureland*, which is the game I'm most familiar with; and
looking at the reverse-engineered *Claymorgue* actions doesn't help
much.]

=back

There are four other elements of game state: the player's current
room, indications of which of the sixteen counters and room-number
slots are current (since some operations act on the "current
counter" and the "current location slot") and the number of turns
for which the light source will continue to function.  You don't need
to worry about this stuff much: it's mostly taken care of behind the
scenes.

### %action

	%action open door
	here closed_door
	carried key

Introduces a new action which occurs when the player types a command
equivalent to the one specified.  Equivalent here means using the
specified verb or a synonym together with the specified noun or a
synonym - so depending on how the game is set up, `UNLOCK PORTAL`
might be equivalent to `OPEN DOOR`.

The `%action` directive may optionally be followed on the same line
by a verb alone instead of a verb-noun pair as above; in this case,
the action occurs whenever the user provides any input beginning with
that word - he may provide the verb alone or with any noun.

The lines following the `%action` directive, up to but not including
the next directive, are conditions, all of which must be satisfied in
order for the results (see below) to happen.  There is no facility for
specifying that conditions should be OR'red together.

Each condition consists of a single-word opcode, followed by zero or
more parameters as required by the opcode.  The following condition
opcodes are supported:

=over 4

=item `at` *ROOM*

True if the player's current room is *ROOM*, which must be the name
of a room defined somewhere in the ScottKit file.

=item `carried` *ITEM*

True if the player is carrying *ITEM*, which must be the name
of an item defined somewhere in the ScottKit file.

=item `here` *ITEM*

True if *ITEM* is in the player's current room.

=item `accessible` *ITEM*

True if *ITEM* is either being carried by the player or in the
player's current room (i.e. if either `carried ITEM` or `here
ITEM` is true.)

=item `exists` *ITEM*

True if *ITEM* is in the game (i.e. is not "nowhere").

=item `moved` *ITEM*

True if *ITEM* has been moved from its original location.  This
includes the cases where an item initially not in play has been
brought into play or vice versa, and where an item initially carried
has been dropped or vice versa.  This only tests the current
situation, not *ITEM*'s history - so if *ITEM* is moved from its
original room, then put back there, this test will return false.

=item `loaded`

True if the player is carrying at least one item.

=item `flag` *NUM*

True if flag number *NUM* is set.

=item `counter_eq` *NUM*

True if the current counter's value is *NUM*.  (A different counter
may be nominated as "current" by the `select_counter` action.)

=item `counter_le` *NUM*

True if the current counter's value is *NUM* or less.

=item `counter_ge` *NUM*

True if the current counter's value is *NUM* or more.

=back

The sense of the
`at`,
`carried`,
`here`,
`accessible`,
`exists`,
`moved`,
`loaded`,
and
`flag`
opcodes may be negated by prefixed them with an exclamation mark
(`!`).  There is no direct way to test for the negation of the three
counter-related conditions.

### %result

	%result
	destroy closed_door
	drop open_door
	msg It creaks open.

Introduces a sequence of results which occur if the previous
`%action` or `%occur` (see below) directive is satisfied.  The lines
following the `%result` directive, up to, but not including, the next
directive, are the resulting actions, which are executed in sequence.

Each result action consists of a single-word opcode, followed by zero
or more parameters as required by the opcode.  The following condition
opcodes are supported:

=over 4

=item `moveto` *room*

Moves to the specified *room* and displays its description.

=item `look`

Redisplays the description of the current room, the obvious exits and
any visible items.  This is done automatically whenever the player
moves (with the `moveto` action), `get`s an item from the current
room, or `drop`s an item.  So far as I can tell, it need only be done
explicitly when changing the value of the darkness flag.

=item `look2`

Exactly the same as `look`, but implemented using a different
op-code in the compiled game file.

=item `get` *item*

The specified *item* is put in the player's inventory, unless too
many items are already being carried (Cf. the `superget` action).
This works even with items that can't be picked up and dropped
otherwise.

=item `superget` *item*

The specified *item* is put in the player's inventory, even if too
many items are already being carried.  This can be used to give the
player things he doesn't want, such as the chigger bites in
*Adventureland*.

=item `drop` *item*

The specified *item* is put in the player's current location,
irrespective of whether it was previous carried, there, elsewhere or
nowhere (out of the game).  This is the standard way to bring into the
game items which begin nowhere.

=item `put` *item* *room*

Puts the specified *item* in the specified *room*.

=item `put_with` *item* *item*

Puts the first-specified item into the same location as the second.

=item `swap` *item* *item*

Exchanges the two specified items, so that each occupies the location
previously occupied by the other.  This can be used to switch one
object out of the game while bringing another in, as well as for
swapping objects that are already in the game.

=item `destroy` *item*

Removes the specified *item* from the game, irrespective of whether
it was previously carried, in the current location, elsewhere or
already out of the game (in which case it's a no-op).

=item `destroy2` *item*

Exactly the same as `destroy`, but implemented using a different
op-code in the compiled game file.

=item `inventory`

Lists the items that the player carrying.

=item `score`

Prints the current score, expressed as a mark out of 100, based on how
many treasures have been stored in the treasury location.  This
causes a division-by-zero error if there are no treasures in the game -
i.e. items whose descriptions begin with an asterisk (`*`).  So games
without treasures, such as Scott Adams's *Impossible Mission*, should
not provide an action with this result.

=item `die`

Implements death by printing an "I am dead" message, clearing the
darkness flag and moving to the last defined room, which is
conventionally a "limbo" room, as in *Adventureland*'s
"Find right exit and live again!"  This is not a proper, permanent
death: for that, you need the `game_over` action.

=item `game_over`

Prints "The game is now over", waits five seconds and exits.

=item `print_noun`

Prints the noun that the user just typed.

=item `print_noun_nl`

Prints the noun that the user just typed, followed by a newline.

=item `nl`

Emits a newline (i.e. moves to the beginning of the next line).

=item `clear_screen`

Clears the screen.  Who could have guessed?

=item `pause`

Waits for two seconds.  Useful before clearing the screen.

=item `refill_lamp`

Refills the lightsource object so that it is reset to give light for
the initial number of turns, as specified by `%lighttime`.

=item `save_game`

Initiates the save-game diaglogue, allowing the player to save the
state of the game to a file.  Unfortunately, there is no corresponding
load_game action, so the only way to use a saved game is to restart
the interpreter, providing the name of the saved-game file on the
command-line.

=item `set_flag` *number*

Sets flag *number*.  In general, this is useful only so that
subsequent actions and occurrences can check the value of the flag, so
there are no pre-defined meanings to the flags.  The only flag with a
"built-in" meaning is number 15 (darkness).

=item `clear_flag` *number*

Clears flag *number*.

=item `set_dark`

Sets flag 15, which indicates darkness.  Exactly equivalent to
`set_flag 15`.

=item `clear_dark`

Clears flag 15, which indicates darkness.  Exactly equivalent to
`clear_flag 15`.

=item `set_0`

Sets flag 0.  Exactly equivalent to
`set_flag 0`.

=item `clear_0`

Clears flag 0.  Exactly equivalent to
`clear_flag 0`.

=item `set_counter` *number*

Sets the value of the currently selected counter to the specified
*value*.  Negative values will not be honoured.  B<Do not confuse
this with the similarly named `select_counter` action!>

=item `print_counter`

Prints the value of the currently selected counter.  Apparently some
drivers can't print values greater than 99, so if you're designing
your games for maximum portability, you should avoid using numbers
higher than this.

=item `decrease_counter`

Decreases the value of the currently selected counter by one.  The
value cannot be decreased below zero.  Surprisingly, there is no
corresponding `increase_counter` action.

=item `add_counter` *number*

Increases the value of the currently selected counter by the specified
*number*.

=item `subtract_counter` *number*

Decreases the value of the currently selected counter by the specified
*number*.

=item `select_counter` *number*

Chooses which of the sixteen counters is the current one.  Subsequent
`decrease_counter`, `print_counter`, etc., actions will operate on
the nominated counter.

(Actually, it's not quite that simple, but it's very hard to figure
out, either from the ScottFree source or from the reverse-compiled
*Sorcerer of Claymorgue Castle*, precisely what this does.)

=item `swap_loc_default`

Swaps the player between the current location and a backup location.
The backup location is initially undefined, so the first use of this
should be immediately followed by a `moveto` to a known room; the
next use will bring the player back where it was first used.

=item `swap_loc` *number*

Like `swap_loc_default` but works with one of a sixteen numbered
backup locations, nominated by *number*.  Swaps the current location
with backup location *number*, so that subsequently doing `swap_loc`
again with the same argument will result in returning to the original
place.  This can be used to implement vehicles.

=item `special` *number*

Performs a "special action" that is dependent on the driver.  For
ScottFree, this does nothing.

=item `continue`

Never use this action.  It is used internally to allow a sequence of
actions that is too long to fit into a single action slot, but there
is no reason at all why you would ever explicitly use it: in fact,
this kind of low-level detail is precisely what the Scott Adams
compiler is supposed to protect you from.  I don't know why I'm even
mentioning it.

=back

### %comment

	%comment need key in order to open door

This directive allows a comment to be associated with an action in the
Scott Adams format data file written by `scottkit`.  The comment is
attached to the most recently declared action.  Note that this is very
different from the usual kind of comment introduced by the hash
character (`#`) which is simply discarded by the compiler.

Why would you ever want to use `%comment`?  Beats me.

### %occur

	%occur 10

Like `%action`, the `%occur` directive introduces a sequence of zero
or more conditions which, if fulfilled, will allow some consequences
to result.  The difference is that `%occur` actions occur
irrespective of what command the player supplies - indeed, they happen
before anything is typed.  They can be used to implement circumstances
such as falling off a ledge if in an appropriately dangerous room
while carrying a particularly heavy item.

If an optional argument is supplied then that argument is the
percentage chance of the occurrence happening when its conditions are
all satisfied; otherwise the chance is 100%.

There is one more very important difference between actions and
occurrences: before each turn, every occurrence whose conditions are
all satisfied is executed.  Then at most one action will happen: the
first action matching the players command and whose conditions are all
satisfied.


## Global parameters

Finally, we come to the global parameters, a rag-bag of bits and
pieces which affect the game as a whole.  In general, each of the
following directives should appear exactly once: it's an error for any
one of them not to appear at all, and a warning is generated if any is
used more than once.

### %ident

	%ident 1

This simply specifies a number which uniquely identifies the
adventure.  I have read in the `Definition` file that comes with the
ScottFree distribution that this number (and all others in the
Scott Adams file format) is "apparently 16 bit".  I don't know how
this is apparent, but it's possible that some interpreters will choke
on numbers larger than 65536 (2^16-1), or maybe even 32767 (2^15-1)
if they interpret the value as signed.  So you should probably pick a
number smaller than this.

Somewhere out there, there should be a register of all Scott Adams
format games, each with a unique identifier number.  Unfortunately, I
don't know if there is one or where it is - please contact me if you
can point me at it (or if you want to start maintaining one!)

Also unfortunately, the uniqueness of the register is already well and
truly broken (although that doesn't mean we should break it more, of
course!)

Adams' original series of twelve adventures uses numbers 1-12
(*Adventureland* has the coveted number 1, of course!), and the later
*Sorceror of Claymorgue Castle* is number thirteen.  Unfortunately,
*Return to Pirate's Island* and *The Adventures of Buckaroo_Banzai*
are both given number fourteen; and the two Questprobe adventures,
*The Incredible Hulk* and *Spiderman* are both number two again (the
same as the original *Pirate Adventure*.  What a crock.  At least the
*Adventureland* "sampler" that used to be given away for free has
its own number, 65.

To make matters worse, Brian Haworth's series of eleven *Mysterious
Adventures* re-use the numbers 1-11.  So there are no fewer than four
adventure number two's.  Ho hum.

### %version

	%version 416

Specifies the version of this adventure.  Looks like Adams went
through 416 design iterations before he got *Adventureland* into a
state he was happy to release.

### %wordlen

	%wordlen 3

Specifies the number of significant letters in each word known to the
game.  Because this is three for *Adventureland*, all longer words
can be abbreviated to three letters - so the player can type `CLI
TRE` (or indeed `CLIMAX TREMENDOUSLY`) instead of `CLIMB TREE`.

### %maxload

	%maxload 6

Specifies the maximum number of items that the player can carry at
once - if he tries to pick up something else, the interpreter issues a
suitable message.

### %lighttime

	%lighttime 125

Specifies how many turns the light source is good for.  Light is only
used up when the light source is in the game, so, for example if
there's an unlit lamp in the game and a lit lamp initially not in the
game, the light time doesn't start to tick down until the lamp is lit
(i.e. the lit lamp object is brought into the game.)

### %start

	%start forest

Specifies which room the player starts in.

### %treasury

	%treasury stump

Specifies the room in which the player must store treasure for it to
count towards his score.  Remember that treasures are, by definition,
objects whose name begins with an asterisk (`*`).  The player's score
at any time is defined as the number of treasures that have been
stored in the treasury, divided by the total number of treasures,
multiplied by 100, and rounded to the nearest integer (so that it's
always in the range 0-100.)

The special room-name `-` may be used to indicate that treasures must
be carried in order to contribute to the score, rather than deposited
in a particular place.

### %lightsource

	%lightsource lamp

Nominates a particular item as the light-source for the game.  When
flag 15 (darkness) is set, the player can only see if either carrying
or in the presence of the lightsource object.  There can be only one
lightsource in the game - if a second is nominated, it replaces the
first.

### %nalias

	%nalias lamp lantern
	%nalias lamp torch

Creates an alias for a noun.  Multiple uses that share one of the same
words (as in the example above) create an equivalence class of words
that are all mutually synonymous.

### %valias

	%valias take get
	%valias drop leave

Creates an alias for a verb.

### %include

	%include foo/bar/baz.sck

Includes the contents of the specified file, exactly as though they
were included inline in the ScottKit file being processed.  Non-absolute
paths are interpreted relative to the file being parsed at that time,
*not* relative to the working directory.  So, for example, if the
file `subdir/thrick.sck` is being parsed, and has a line `%include
frog.sck`, then the file of that name *in the `subdir` directory* is
used.


## See also

* The top-level [README](file.README.html)
* [The ScottKit tutorial](file.tutorial.html) (XXX not yet written)

