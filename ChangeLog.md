# Revision history for Ruby gem ScottKit

## 1.5.0 (IN PROGRESS)

* Improvements to _Nosferatu_. This game is now as close as I can make it to the 1982 original, including bug-compatibility for mis-spellings and the behaviour of water.
* Minor improvements to tutorial map 4 and subsequent.

## 1.4.0 (Tue Oct 17 00:52:09 BST 2017)

* Fix v1.3.0 bug: hasty implementation of lint meant compilation would fail if no lint option was provided. Now works correctly again.
* Play mode no longer crashes on an empty line of input
* Add support for opcode 84 `print_noun` (without newline).
* Remove ScottKit version number from startup message in play mode, as it messes up regression tests. It's in the usage message now.
* New file, `bin/md5ruby`: needed for regenerating regresssion expectations, since the `md5` program on MacOS produces different results from Ruby's MD5 digest when given non-ASCII input. Use this for regenerating `data/test/adams/*.md5`
* The reimplementation of _Nosferatu_ is now complete in that it is possible to play the game through to a successful completion. However, it's not ready for release, as many incorrect actions still need to be handled gracefully.

## 1.3.0 (Mon Oct 16 20:27:43 BST 2017)

* Support `--lint` (`-L`) command-line option. Fixes issue 1.
  Argument is a string of characters:
  * `e` -- check for rooms with no exits (traps)
  * `E` -- check for rooms with only one exit (dead ends)

## 1.2.0 (Mon Oct 16 15:11:44 BST 2017)

* Create initial tutorial, exactly equivalent to that of Games::ScottAdams.
* Use the special name `_` for the unused variable representing the redundant dark-flag part of save-files. This avoids an unused-variable warning when running under certain older versions of Ruby.
* Top-level README links to the tutorial, reference manual and sequence of blog-posts.
* Add new game, [`data/nosferatu`](data/nosferatu), ported from the Games::ScottAdams reimplementation of the 1982 VIC-20 BASIC game. This is incomplete.
* Escape sequences for newline (`\n`) and tab (`\t`) are interpreted in printed strings.
* Add discussion of the `print` action to the reference guide.

## 1.1.0 (Thu Oct 12 21:59:28 BST 2017)

* Documentation fix: correctly name the `present` condition (was `accessible`).
* Documentation fix: correctly name _twelve_ actions. (Thanks to Brian Jones for spotting the first of these.)
    * `moveto` -> `goto`
    * `print_noun_nl` -> `println_noun`
    * `nl` -> `println`
    * `clear_screen` -> `clear`
    * `set_0` -> `set_flag0`
    * `clear_0` -> `clear_flag0`
    * `decrease_counter` -> `dec_counter`
    * `add_counter` _nu`mber_ -> add_to_counter _number_`
    * `subtract_counter` -> subtract_from_counter`
    * `swap_loc_default` -> `swap_room`
    * `swap_loc` -> swap_specific_room`
    * `special` -> draw`

## 1.0.0 (Wed Oct 11 21:45:27 BST 2017)

* Finish translating reference guide from POD to MarkDown.
* Update reference guide to describe ScottKit format rather then Games::ScottAdams format.
* Fix handling of darkness when playing games.
* Support unquoted "carried" and "at" in conditions

## 0.4.0 (Mon Mar  1 22:20:09 GMT 2010)

* Move towards using YARD for documentation instead of Rdoc.  This
  includes changes to things like the format of the Changes file.  Far
  from perfect so far: for example, plain-text documentation like
  `doc/Definition` gets mangled.

## 0.3.0 (February 28, 2010)

* Move ScottKit out of its sub-siubdirectory in the 9Gb `mike`
  git module into its own git module.
* Move repository hosting to github.
* Arrange for formatted documentation to appear at
  [http://rdoc.info/projects/MikeTaylor/scottkit](http://rdoc.info/projects/MikeTaylor/scottkit)

## 0.2.0 (February 28, 2010)

* Add `-z` option to sleep after finishing - useful when running in a
  DOS Shell under Windows, so that error messages can be seen.
* Add facility to load a game while playing, using `#load`

## 0.1.0 (February 28, 2010)

* Add `-p` option to compile and play a game from source.

## 0.0.0 (February 28, 2010)

* Initial release.


## Still to do

* The `goto` action result should automatically describe the new room.
* Tweak compiler to break actions when they need too many arguments as well as when they need too many instructions.
* Ensure that the right files are built by `YARD`
* Maybe modify to run against GLK using the Glkx driver
* File inclusion
