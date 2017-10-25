# The `scottkit` program

The document describes the program `scottkit` that invokes the Ruby Gem of the same name to compile, decompile and play adventure games. It is in the form of a Unix manual page. See [below](#see-also) for documentation of the various file formats.

<!-- md2toc -l 2 program.md -->
* [Name](#name)
* [Synopsis](#synopsis)
* [Description](#description)
* [Examples](#examples)
* [Diagnostics](#diagnostics)
* [Environment](#environment)
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

The following options are supported:

* **-c**, **--compile**  
  Compile <data-file> instead of loading.

* **-d**, **--decompile**  
  Decompile instead of playing

* **-p**, **--play-from-source**  
  Compile and play from source

* **-t**, **--teleport**  
  Generate teleporting actions (for debugging)

* **-g**, **--superget**  
  Generate superget actions (for debugging)

* **-w**, **--wizard**  
  Wizard mode (enable debugging commands)

* **-l** _file_, **--load-game** _file_  
  Load a previously saved game

* **-f** _file_, **--read-file** _file_  
  Read initial commands from file

* **-e**, **--echo**  
  Echo input commands to output

* **-s** _number_, **--random-seed** _number_  
  Set random seed for repeatability

* **-L** _string_, **--lint** _string_  
  Lint options: a string of the following:
  * **e**  
    Ensure rooms all have at least one way out (no traps)
  * **E**  
    Ensure rooms all have at least two ways in/out (no dead ends)

* **-b**, **--bug-tolerant**  
  Copy with out-of-range locations, etc.

* **-z**, **--sleep-at-end**  
  Sleep for a long time after program ends

* **-W**, **--no-wait**  
  Do not wait on pause actions or death

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

## Diagnostics

## Environment

## See also

* Source
* Reference
* Tutorial
* ScottFree
* Description
* Description.saved-game

## Bugs

