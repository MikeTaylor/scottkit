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

* **-s** _number_, **--random-seed** _number_  
  Set the random seed to specified _number_, allowing a game to be played repeatably even if it contains random elements. Two runs of the same game using the same random seem will result in the same random events, whereas if no seed is specific then each run will generate different random numbers.

* **-l** _file_, **--load-game** _file_  
  Load a previously saved game from the named _file_, allowing the player to continue from where the previous session was saved. (It is also possible to load a saved game from within ScottKit, using the special command **#LOAD** _filename_.)

* **-f** _file_, **--read-file** _file_  
  Read the initial set of player commands from the named _file_, with control reverting to the player once the contents of the file have been exhausted. This is useful when creating walkthroughs, as they can be incrementally extended with the results of the user's experiments. Note that the effects of a given set of commands are only predictable when run using the same random seed on each run (see **-s** above).

* **-e**, **--echo**  
  Echo input commands to output. This is useful when feeding input to a game and capturing the output as a transcript.

* **-W**, **--no-wait**  
  Do not wait on pause actions or death. This is generally not a good idea when playing a game interactively, but allows automated run-throughs (with **-f**, see above) to proceed very quickly.

* **-z**, **--sleep-at-end**  
  Sleep for a long time after program ends. This is useful when running in a DOS Shell under Windows, so that error messages can be seen before the window closes after the program exits.

* **-b**, **--bug-tolerant**  
  Tolerate out-of-range room-numbers as the locations of items, and also compile such room-names using special names of the form `_ROOM`_number_.  (This is not necessary when dealing with well-formed games, but _Buckaroo Banzai_ is not well-formed.)

* **-w**, **--wizard**  
  Wizard mode: enables debugging verbs. These can be typed during game-play to manipulate the world in ways not allowed for by the code of the game.

  * **#GO** -- "teleport": the noun is a room number, and the player immediately moves to the specified room..

  * **#SG** -- "superget". the noun is an item number, and the specified item is added to the player's inventory irrespective of whether it is present or any other condition.

  * **#WHERE** -- locates an item. The noun is an item number, and the number of the room that contains that item is printed. Can be used with #GO to move to the room containing a specified item.

  * **#SET** -- sets a debugging flag. Acceptable nouns are:

    * **p** -- shows the result of parsing commands, as though **--show-tokens** had been specified.
    * **r** -- shows the result of random rolls, as though **--show-random** had been specified.
    * **c** -- shows the conditions of actions and occurrences as they are evaluated, as though **--show-conditions** had been specified.
    * **i** -- shows the instructions that are executed, as though **--show-instructions** had been specified.

  * **#CLEAR** -- clears a debugging flag. The same nouns are supported as for #SET.

  The #GO, #SG and #WHERE commands work only in terms of room and item _numbers_, not names, because they take effect only at run-time when they are working with a compiled game. Only the source file knows the names of room and items. That is why the **--teleport** and **--superget** compilation options are provided: because they take effect at compile-time, they support use of room and item names.

### Debugging options

* **-T**, **--show-tokens**  
  Show lexical tokens as they are read. This is the only debugging option that affects compile-time behaviour, and so has no corresponding run-time #SET wizard-mode command.

* **-P**, **--show-parse**  
  Show the results of parsing the verb and noun out of user input. The index numbers of the verb and noun within the compiled game is emitted.

* **-R**, **--show-random**  
  Show rolls of the random dice. This happens whenever an occurrence with less than a 100% chance of happening occurs.

* **-C**, **--show-conditions**  
  Show the conditions of actions and occurrences as they are evaluated, together with the result of their evaluation.

* **-I**, **--show-instructions**  
  Show instructions before they are executed.

## Examples

In the follow short but complete transcript, we:
* Create the source file, **trivial.sck**, for a game.
* Compile it into a game file, **trivial.sao**.
* Look at the compiled form of the game.
* Play the game
* Decompile the game file back to source.

```
$ cat > trivial.sck
room chamber "beautifully decorated chamber"
  exit north cave
room cave "dingy cave"
  exit south chamber 
$ scottkit -c trivial.sck > trivial.sao
$ cat trivial.sao | fmt | grep .
0 -1 -1 18 2 -1 1 0 3 -1 0 1
"AUT" "ANY" "GO" "NOR" "" "SOU" "" "EAS" "" "WES" "" "UP" "" "DOW"
"" "" "" "" "" "" "GET" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
"" "DRO" ""
0 0 0 0 0 0 "" 2 0 0 0 0 0 "beautifully decorated chamber" 0 1 0 0
0 0 "dingy cave"
""
0 0 0
$ 
$ scottkit trivial.sao 
ScottKit, a Scott Adams game toolkit in Ruby.
(C) 2010-2017 Mike Taylor <mike@miketaylor.org.uk>
Distributed under the GNU GPL version 2 license,

I'm in a beautifully decorated chamber
Obvious exits: North.

Tell me what to do ? n

I'm in a dingy cave
Obvious exits: South.

Tell me what to do ? ^D
$ scottkit -d trivial.sao 
# 3 rooms, 0 items, 0 actions
# 1 messages, 0 treasures, 19 verbs/nouns
ident 0
version 0
wordlen 3
maxload -1
lighttime -1
unknown1 0
unknown2 0
start chamber
treasury chamber

room chamber "beautifully decorated chamber"
	exit north cave

room cave "dingy cave"
	exit south chamber

$ 
```

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

