ScottKit -- a Scott Adams adventure toolkit
===========================================

**Homepage**: http://rdoc.info/projects/MikeTaylor/scottkit
**Git**: [http://github.com/MikeTaylor/scottkit](http://github.com/MikeTaylor/scottkit)
**Author**: Mike Taylor <mike@miketaylor.org.uk>
**Copyright**: 2009-2010
**Licence**: GNU GPL, version 2 -- see file GPL-2


Synopsis
--------

This is a Ruby program to compile, decompile and run adventure games
in Scott Adams format, written as an exercise in Ruby rather than with
any great expectation that it will be useful.


Running ScottKit
----------------

The three modes of running are:

	$ scottkit -c game.sck > game.sao  # compile
	$ scottkit game.sao  # play the game; or use scottfree game.sao
	$ scottkit -d game.sao  # decompile -- useful for cheating

Other command-line arguments enable wizard commands, load saved games,
set random seeds and enable various kinds of debugging output: run
scottkit -h for details.


Testing
-------

Unit testing can be done as follows:

	$ ruby1.9 -I lib -rrake/rake_test_loader test/test_*
	Loaded suite test/test_canonicalise
	Started
	...........
	Finished in 0.769568 seconds.

	11 tests, 37 assertions, 0 failures, 0 errors, 0 skips

I have verified that ScottKit can be used to play and win Scott
Adams's games #1, 2, and 4: Adventureland, Pirate Adventure and Voodoo
Castle.  I welcome reports of its being used to play and win other
games, or failing that, reports of how it fails.


Game format
-----------

The file notes/Definition.scottfree-1.14 is taken from the ScottFree
package, which contains another interpreter for Scott Adams games.  I
got this file from release 1.14-9 of ScottFree.  notes/Definition is my
modified version of this file.  notes/Definition.saved-game is my own
analysis of the format of saved games from ScottFree.


Games
-----

The directory "data" contains game files:
  adams -- Scott Adams's classic games (see Makefile for details)
  howarth -- Brian Howarth's  games (see Makefile for details)
  test -- games files used by unit-test suite
  tutorial -- tiny game used in ScottKit tutorial
  crystal -- Crystal of Chaos, a game written to exercise ScottKit
  dan-and-matt.sck -- game written by my two eldest sons


Bug tolerance
-------------

-b (--bug-tolerant) option is needed for Adventure 14b (Buckaroo
Banzai), which places one item (the jug of jet fuel) in room 50 of 36.
This is mapped to 0 (not in play), which is presumably what was
intended.  None of Scott's own games is so sloppy.


