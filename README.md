ScottKit - a toolkit for Scott Adams-style adventure games
==========================================================

**Homepage**:  [http://rdoc.info/projects/MikeTaylor/scottkit](http://rdoc.info/projects/MikeTaylor/scottkit)  
**Git**:       [http://github.com/MikeTaylor/scottkit](http://github.com/MikeTaylor/scottkit)  
**Author**:    Mike Taylor <mike@miketaylor.org.uk>  
**Copyright**: 2009-2010, 2017  
**License**:   GNU GPL, version 2 - see file GPL-2  


Synopsis
--------

This is a Ruby program to compile, decompile and run adventure games
in Scott Adams format, including those created by the great man
himself.  ScottKit's good for nostalgia freaks wanting to relive the
classic games of the 1980s, but also as a tool for creating small,
concise, new games.

It was intially written as an exercise in Ruby rather than with any
great expectation that it would be useful, but it turns out to work
pretty well as a tight, clean environment for games programming: if
Inform 7 is like the Ruby of adventure games, ScottKit is like C.  For
a big project, you definitely want Inform 7; but I've found that there
is a distinctive appeal to ScottKit.  Apart from anything else, it
makes a good domain-specific "little language" for teaching my sons
how to program.


Running ScottKit
----------------

The main three modes of running are:

	$ scottkit -c game.sck > game.sao  # compile
	$ scottkit game.sao  # play the game; or use scottfree game.sao
	$ scottkit -d game.sao  # decompile - useful for cheating

And there's a handy short-cut combining compilation and play:

	$ scottkit -p game.sck # compile to memory, and play immediately

Other command-line arguments enable wizard commands, load saved games,
set random seeds and enable various kinds of debugging output: run
`scottkit -h` for details.


Testing
-------

Unit testing can be done as follows:

	$ ruby -I lib -rrake/rake_test_loader test/test_*
	Loaded suite test/test_canonicalise
	Started
	...........
	Finished in 0.769568 seconds.

	11 tests, 37 assertions, 0 failures, 0 errors, 0 skips


Game format
-----------

The file [`docs/notes/Definition-scottfree-1.14.txt`](docs/notes/Definition-scottfree-1.14.txt) is copied from the
ScottFree package, which contains another interpreter for Scott Adams
games.  I got this file from release 1.14-9 of ScottFree.
[`docs/notes/Definition.txt`](docs/notes/Definition.txt) is my modified version of this file, since the
original had several mistakes.  [`docs/notes/Definition-saved-game.txt`](docs/notes/Definition-saved-game.txt) is
my own analysis of the format of saved games from ScottFree.  (Saved
games from ScottFree and ScottKit can be freely interchanged.)


Games
-----

The directory `data` contains game files:

* `adams` - Scott Adams's classic games (see Makefile for details)
* `howarth` - Brian Howarth's  games (see Makefile for details)
* `test` - games files used by unit-test suite
* `tutorial` - tiny game used in ScottKit tutorial
* `crystal` - Crystal of Chaos, a game written to exercise ScottKit
* `dan-and-matt` - game written by my two eldest sons
* `nosferatu` -- a partial reimplementation of my 1982 VIC-20 BASIC game

I have verified that ScottKit can be used to play and win Scott
Adams's games #1, 2, and 4: *Adventureland*, *Pirate Adventure* and
*Voodoo Castle*.  I welcome reports of its being used to play and win
other games, or failing that, reports of how it fails.



Bug tolerance
-------------

The `-b` (`--bug-tolerant`) option is needed for Scott Adams Adventure
14b (*Buckaroo Banzai*), which places one item (the jug of jet fuel)
in room 50 of 36.  None of Scott's own games is so sloppy.


Documentation
-------------

* [ScottKit Tutorial](docs/tutorial.md)
* [The ScottKit format reference manual](docs/reference.md)
* A series of blog-posts about ScottKit:
  * [Scottkit is born! Only seven and a half years late!](https://reprog.wordpress.com/2017/10/12/scottkit-is-born-only-seven-and-a-half-years-late/)
  * [Building adventure games with ScottKit](https://reprog.wordpress.com/2017/10/13/building-adventure-games-with-scottkit/)
  * [Rooms and items in ScottKit](https://reprog.wordpress.com/2017/10/14/rooms-and-items-in-scottkit/)
  * [Actions in ScottKit](https://reprog.wordpress.com/2017/10/16/actions-in-scottkit/)
  * [Occurrences (or daemons) in ScottKit](https://reprog.wordpress.com/2017/10/17/occurrences-or-daemons-in-scottkit/)
  * [Darkness and light in ScottKit](https://reprog.wordpress.com/2017/10/21/darkness-and-light-in-scottkit/)


