changequote(`[[[', `]]]')dnl
# ScottKit Tutorial

<!-- md2toc -l 2 tutorial.source.md -->
* [Introduction](#introduction)
* [Stage 1](#stage-1)
    * [Stage 1 map](#stage-1-map)
    * [Stage 1 source](#stage-1-source)
* [Stage 2](#stage-2)
    * [Stage 2 map](#stage-2-map)
    * [Stage 2 source](#stage-2-source)
* [Stage 3](#stage-3)
    * [Stage 3 map](#stage-3-map)
    * [Stage 3 source](#stage-3-source)
* [Stage 4](#stage-4)
    * [Stage 4 map](#stage-4-map)
    * [Stage 4 source](#stage-4-source)
* [Stage 5](#stage-5)
    * [Stage 5 map](#stage-5-map)
    * [Stage 5 source](#stage-5-source)

## Introduction

This document walks you through the process of creating a small but complete and playable game with six rooms, seven items including a single treasure, and a couple of puzzles. It makes no attempt to be complete: you need the reference manual for that. But by the time you've worked your way through this tutorial you should be familiar with rooms, items, actions and occurrences, and you'll be ready to start writing your own games.


## Stage 1

This is the minimal playable game, consisting of rooms only - and only two of them.

This stage is built entirely using the %room and %exit directives.

### Stage 1 map

```

include(t1.map)dnl

```

### Stage 1 source

```
include(t1.sck)dnl
```


## Stage 2

This stage introduces the first items: one portable (the coin) and one not (the sign).

This stage uses the directives from the previous stage, plus `item` and `called`.

### Stage 2 map

```

include(t2.map)dnl

```

### Stage 2 source

```
include(t2.sck)dnl
```


## Stage 3

Here we introduce the first explicitly-coded actions - the previous stages' movement between locations and ability to pick up and drop items are "intrinsics" provided by the interpreter.

The new action provides the first puzzle: the player needs to unlock the cell door before entering the cell to obtain the coin. The key is necessary in order to open the door.

This stage uses the directives from the previous stage, plus `nowhere`, `at`, `action` and `result`.

### Stage 3 map

```

include(t3.map)dnl

```

### Stage 3 source

```
include(t3.sck)dnl
```


## Stage 4

This stage introduces automatic actions, or "occurrences", which occur without the player needing to do anything. In effect, they happen _to_ him rather than being done _by_ him.

It also uses inline documentation in the form of an action comment (though why you'd want to do this is beyond me) and specifies the start and treasury rooms explicitly.

This stage uses the directives from the previous stage, plus `occur`, `comment`, `start` and `treasury`.

### Stage 4 map

```

include(t4.map)dnl

```

### Stage 4 source

```
include(t4.sck)dnl
```


## Stage 5

This stage adds a light source (and darkness), a random occurrence and aliases for both verbs and nouns.

This stage uses the directives from the previous stage, plus `lightsource`, `occur` with an argument, `verbgroup` and `noungroup`.

### Stage 5 map

```

include(t5.map)dnl

```

### Stage 5 source

```
include(t5.sck)dnl
```


## Caveats

This tutorial skips a lot of details. [The reference manual](../../docs/reference.md) is indispensible for filling in the gaps.

The following directives are not yet discussed: `ident`, `version`, `wordlen`, `maxload`, `lighttime`.

There is not yet any discussion of flags, counters and location stores.

Some discussion of what makes a good game design may be appropriate.

