Revision history for Ruby gem ScottKit
======================================

1.0.0 (IN PROGRESS)
-------------------
* Finish translating reference guide from POD to MarkDown.
* Update reference guide to describe ScottKit format rather then Games::ScottAdams format.
* Fix handling of darkness when playing games.

0.4.0 (Mon Mar  1 22:20:09 GMT 2010)
------------------------------------
* Move towards using YARD for documentation instead of Rdoc.  This
  includes changes to things like the format of the Changes file.  Far
  from perfect so far: for example, plain-text documentation like
  `doc/Definition` gets mangled.

0.3.0 (February 28, 2010)
-------------------------
* Move ScottKit out of its sub-siubdirectory in the 9Gb `mike`
  git module into its own git module.
* Move repository hosting to github.
* Arrange for formatted documentation to appear at
  [http://rdoc.info/projects/MikeTaylor/scottkit](http://rdoc.info/projects/MikeTaylor/scottkit)

0.2.0 (February 28, 2010)
-------------------------
* Add `-z` option to sleep after finishing - useful when running in a
  DOS Shell under Windows, so that error messages can be seen.
* Add facility to load a game while playing, using `#load`

0.1.0 (February 28, 2010)
-------------------------
* Add `-p` option to compile and play a game from source.

0.0.0 (February 28, 2010)
-------------------------
* Initial release.


Still to do
===========

* Rename the `carried` and `at` keywords to avoid conflicting with condition.
* Update test-suite to work correctly with renamed `carried` and `at`.
* Tweak compiler to break actions when they need too many arguments as
  well as when they need too many instructions.
* Write tutorial scaffolding.
* Ensure that the right files are built by `YARD`
* Write blog entry about ScottKit
* Maybe modify to run against GLK using the Glkx driver
* File inclusion
