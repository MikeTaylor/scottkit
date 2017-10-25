# The `scottkit` program

The document describes the program `scottkit` that invokes the Ruby Gem of the same name to compile, decompile and play adventure games. It is in the form of a Unix manual page. See [below](#see-also) for documentation of the various file formats.

<!-- md2toc -l 2 scottkit.md -->
* [Name](#name)
* [Synopsis](#synopsis)
* [Description](#description)
    * [Mode options](#mode-options)
    * [Compilation options](#compilation-options)
    * [Play options](#play-options)
    * [Debugging options](#debugging-options)
* [Examples](#examples)
* [Diagnostics](#diagnostics)
* [Author](#author)
* [Licence](#licence)
* [See also](#see-also)
* [Bugs](#bugs)

## Name

**scottkit** -- compile, decompile and play Scott Adams-format adventure games

## Synopsis

**scottkit**
[**-cdptgwebzWTRPCI**]
[**-l** _savefile_]
[**-r** _transcript_]
[**-s** _seed_]
[**-L** _lintopts_]
_gamefile_

## Description

ScottKit compiles, decompiles and runs adventure games. It works with files in two formats:

* Scott Adams TRS-80 format, which has become the canonical format for distributing games built for the Scott Adams engine. You can, for example, download all Adams’s own games, and play them using either ScottKit or the ScottFree interpreter.
* A source format of my own devising, which makes it easy to create such games.

ScottKit runs in three basic modes: it can play a Scott Adams TRS-80 format game, which is the default; it can decompile such a game into ScottKit-format source code; and it can compile source code into a playable game. As a convenient shortcut, there’s also a mode that can compile from source in-memory, and execute the game directly, so you needn’t bother with compiled files at all if you don’t want to.

I conventionally use the suffix **.sck** (ScottKit) for the source files and **.sao** (Scott Adams Object-code) for the compiled games. So the four modes listed above are are used as follows:

	scottkit game.sao
	scottkit -d game.sao > game.sck
	scottkit -c game.sck > game.sao
	scottkit -p game.sck


The following options are supported, The mode options control which of the four different fundamental modes *scottkit* runs in; the compilation options affect how source-code compiles, and are ignored in play and decompile modes; the play options affect how games are played, and are ignored in compile and decompile modes.

### Mode options

* (no option) [default]  
  Treat _gamefile_ as compiled code, and play the game, accepting commands on standard input and emitting text on standard output.

* **-c**, **--compile**  
  Treat _gamefile_ as source code and compile it, emitting a compiled file on standard output. Any errors or warnings are printed on standard error.

* **-d**, **--decompile**  
  Treat _gamefile_ as compiled code and decompile it, emitting a source file on standard output. This is useful for inspecting games supplied in compiled form -- for example, to figure out how to safely wake the dragon in _Adventureland_. The output is suitable for feeding to **scottkit -c**.

* **-p**, **--play-from-source**  
  Treat _gamefile_ as source code, compile it to memory, and play the game immediately. Both compilation and play options are respected.

### Compilation options

* **-t**, **--teleport**  
  In addition to the actions specified in the source file, generates teleporting actions which can be used during development to allow easy access to difficult-to-reach parts of the map. An action TELEPORT _ROOM_ is generated for each room in the game. _ROOM_ is the name that the room is assigned in the source file, which may not be the same as its user-visible description. Note that if multiple rooms have names that are identical in the first few letters (e.g. MEADOW1, MEADOW2), then teleport actions for the rooms will be indistinguishable, and teleporting to the first of these locations only will be supported.

* **-g**, **--superget**  
  In addition to the actions specified in the source file, generates superget actions which can be used during development to allow easy access to difficult-to-reach items. An action SG _ITEM_ is generated for each item in the game. _ITEM_ is the name that the item is assigned in the source file, which may not be the same as its user-visible description. Note that if multiple items have names that are identical in the first few letters (e.g. LAMPLIT, LAMPEMPTY), then superget actions for the items will be indistinguishable, and supergetting the first of these items only will be supported.

* **-L** _string_, **--lint** _string_  
  Lint: warn about questionable constructions in the source file. The _string_ consists of a sequence of lint options. At present, the following lint options are supported:
  * **e**  
    Report rooms that do not have at least one way out (i.e. rooms that are traps).
  * **E**  
    Report rooms that do not have at least two ways out (i.e. rooms that are dead ends).

### Play options

XXX to be written

* **-s** _number_, **--random-seed** _number_  
  Set random seed for repeatability

* **-l** _file_, **--load-game** _file_  
  Load a previously saved game

* **-f** _file_, **--read-file** _file_  
  Read initial commands from file

* **-e**, **--echo**  
  Echo input commands to output

* **-W**, **--no-wait**  
  Do not wait on pause actions or death

* **-z**, **--sleep-at-end**  
  Sleep for a long time after program ends

* **-b**, **--bug-tolerant**  
  Cope with out-of-range locations, etc.

* **-w**, **--wizard**  
  Wizard mode (enable debugging commands)

### Debugging options

XXX to be written

* **-T**, **--show-tokens**  
  Show lexical tokens as they are read

* **-R**, **--show-random**  
  Show rolls of the random dice

* **-P**, **--show-parse**  
  Show results of parsing verb/noun

* **-C**, **--show-conditions**  
  Show conditions being evaluated

* **-I**, **--show-instructions**  
  Show instructions being executed

## Examples

XXX to be written

## Diagnostics

Exits with status:

* 0 if all is well
* 1 if compilation fails
* 2 if the command-line is invalid

## Author

Mike Taylor `<mike@miketaylor.org.uk>`

## Licence

All code and documentation is furnished under the
[GNU General Public License, version 2](../GPL-2.txt).

Note that the Scott Adams and Brian Haworth adventure games are _not_ incuded under this licence. Although they are freely available for download, all rights are reserved to their respective copyright holders.

## See also

* [The source code](https://github.com/MikeTaylor/scottkit)
* [The reference guide for the ScottKit source language](reference.md)
* [The ScottKit tutorial](tutorial.md)
* [Description of the compiled format](notes/Definition.txt)
* [Description of saved-game format](notes/Definition-saved-game.txt)
* [ScottFree](https://packages.debian.org/stable/scottfree), another interpreter for adventure games in Scott Adams compiled format
  
## Bugs

See
[the issue tracker](https://github.com/MikeTaylor/scottkit/issues)
and the TODOs list at the end of 
[the change-log](https://github.com/MikeTaylor/scottkit/blob/master/ChangeLog.md).

