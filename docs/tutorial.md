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
* [Stage 6](#stage-6)
    * [Stage 6 map](#stage-6-map)
    * [Stage 6 source](#stage-6-source)
* [Stage 7](#stage-7)
    * [Stage 7 map](#stage-7-map)
    * [Stage 7 source](#stage-7-source)
* [Caveats](#caveats)


## Introduction

This document walks you through the process of creating a small but complete and playable game with six rooms, seven items including a single treasure, and a couple of puzzles. It makes no attempt to be complete: you need the reference manual for that. But by the time you've worked your way through this tutorial you should be familiar with rooms, items, actions and occurrences, and you'll be ready to start writing your own games.


## Stage 1

This is the minimal playable game, consisting of rooms only - and only two of them.

This stage is built entirely using the `%room` and `%exit` directives.

### Stage 1 map

```

Chamber---------Dungeon

```

### Stage 1 source

```
room chamber "square chamber"
	exit east dungeon

room dungeon "gloomy dungeon"
	exit west chamber
```


## Stage 2

This stage introduces the first items: one portable (the coin) and one not (the sign).

This stage uses the directives from the previous stage, plus `item` and `called`.

### Stage 2 map

```

Chamber---------Dungeon
[sign]		|
		|
		|
		Cell
		[*coin*]

```

### Stage 2 source

```
room chamber "square chamber"
	exit east dungeon

item sign "Sign says: leave treasure here, then say SCORE"

room dungeon "gloomy dungeon"
	exit west chamber
	exit south cell

room cell "dungeon cell"
	exit north dungeon

item coin "*Gold coin*"
	called "coin"
```


## Stage 3

Here we introduce the first explicitly-coded actions - the previous stages' movement between locations and ability to pick up and drop items are "intrinsics" provided by the interpreter.

The new action provides the first puzzle: the player needs to unlock the cell door before entering the cell to obtain the coin. The key is necessary in order to open the door.

This stage uses the directives from the previous stage, plus `nowhere`, `at`, `action` and `result`.

### Stage 3 map

```

Chamber---------Dungeon
[sign, key]	[door]
		=
		|
		Cell
		[*coin*]

```

### Stage 3 source

```
action score: score
action inventory: inventory
action look: look

room chamber "square chamber"
	exit east dungeon

item sign "Sign says: leave treasure here, then say SCORE"

room dungeon "gloomy dungeon"
	exit west chamber

item door "Locked door"

room cell "dungeon cell"
	exit north dungeon

item coin "*Gold coin*"
	called "coin"

item key "Brass key"
	called "key"
	at chamber

item door2 "Open door leads south"
	nowhere

action open door when here door and !present key
	print "It's locked."

action open door when here door
	swap door door2
	print OK
	look

action go door when here door2
	goto cell
	look
```


## Stage 4

This stage introduces automatic actions, or "occurrences", which occur without the player needing to do anything. In effect, they happen _to_ him rather than being done _by_ him.

It also uses inline documentation in the form of an action comment (though why you'd want to do this is beyond me) and specifies the start and treasury rooms explicitly.

This stage uses the directives from the previous stage, plus `occur`, `comment`, `start` and `treasury`.

### Stage 4 map

```

Throne Room	Crypt
[sign]		[vampire, key]
|		|
|		|
Chamber---------Dungeon
[cross]		[door]
		=
		|
		Cell
		[*coin*]

```

### Stage 4 source

```
start dungeon
treasury throne

action score: score
action inventory: inventory
action look: look

room throne "gorgeously decorated throne room"
	exit south chamber

item sign "Sign says: leave treasure here, then say SCORE"

room chamber "square chamber"
	exit east dungeon
	exit north throne

item cross "Wooden cross"
	called "cross"

room dungeon "gloomy dungeon"
	exit west chamber
	exit north crypt

occur 25% when at dungeon
	print "I smell something rotting to the north."

item door "Locked door"

item key "Brass key"
	called "key"
	at crypt

item door2 "Open door leads south"
	nowhere

action open door when here door and !present key
	print "It's locked."

action open door when here door
	swap door door2
	print OK
	look

action go door when here door2
	goto cell
	look

room cell "dungeon cell"
	exit north dungeon

item coin "*Gold coin*"
	called "coin"

room crypt "damp, dismal crypt"
	exit south dungeon

item vampire "Vampire"

occur when here vampire and carried cross
	print "Vampire cowers away from the cross!"

occur when here vampire and !carried cross
	print "Vampire looks hungrily at me."

occur 25% when here vampire and !carried cross
	print "Vampire bites me!  I'm dead!"
	game_over
	comment "vampire can attack unless cross is carried"

action get key when here vampire and !carried cross
	print "I'm not going anywhere near that vampire!"
```


## Stage 5

This stage adds a light source (and darkness), a random occurrence and aliases for both verbs and nouns.

This stage uses the directives from the previous stage, plus `lightsource`, `occur` with an argument, `verbgroup` and `noungroup`.

### Stage 5 map

```

		Throne Room	Crypt
		[sign, lamp]	[vampire, key]
		|		|
		|		|
Cave Mouth------Chamber---------Dungeon
[station]	[cross]		[door]
				=
				|
				Cell
				[*coin*]

```

### Stage 5 source

```
start cave
treasury throne

action score: score
action inventory: inventory
action look: look

occur when !flag 1
	print "Welcome to the Tutorial adventure."
	print "You must find a gold coin and store it."
	set_flag 1

room cave "cave mouth"
	exit east chamber

room throne "gorgeously decorated throne room"
	exit south chamber

item sign "Sign says: leave treasure here, then say SCORE"

item lamp "old-fashioned brass lamp"
	called "lamp"

item lit_lamp "lit lamp"
	called "lamp" nowhere

item empty_lamp "empty lamp"
	called "lamp" nowhere

lightsource lit_lamp
lighttime 10

action light lamp when present lamp
	swap lamp lit_lamp
	print "OK, lamp is now lit and will burn for 10 turns."
	look

occur when flag 16
	clear_flag 16
	swap lit_lamp empty_lamp
	look
	comment "The engine sets flag 16 when the lamp runs out"

item station "lamp-refilling station" at cave

action refill lamp when here station and present empty_lamp
	destroy empty_lamp
	refill_lamp
	print "The lamp is now full and lit."

room chamber "square chamber"
	exit east dungeon
	exit north throne
	exit west cave

# Flag 15 is on when and only when it is dark
occur when at chamber and flag 15
	clear_dark
	look

item cross "Wooden cross"
	called "cross"

room dungeon "gloomy dungeon"
	exit west chamber
	exit north crypt

occur when at dungeon and !flag 15
	set_dark
	look

occur 25% when at dungeon
	print "I smell something rotting to the north."

item door "Locked door"

item key "Brass key"
	called "key"
	at crypt

item door2 "Open door leads south"
	nowhere

action open door when here door and !present key
	print "It's locked."

action open door when here door
	swap door door2
	print OK
	look

action go door when here door2
	goto cell
	look

room cell "dungeon cell"
	exit north dungeon

item coin "*Gold coin*"
	called "coin"

room crypt "damp, dismal crypt"
	exit south dungeon

item vampire "Vampire"

occur when here vampire and carried cross
	print "Vampire cowers away from the cross!"

occur when here vampire and !carried cross
	print "Vampire looks hungrily at me."

occur 25% when here vampire and !carried cross
	print "Vampire bites me!  I'm dead!"
	game_over
	comment "vampire can attack unless cross is carried"

action get key when here vampire and !carried cross
	print "I'm not going anywhere near that vampire!"

verbgroup get take g
verbgroup drop leave
noungroup lamp lantern
```


## Stage 6

This stage adds standard boilerplate actions for `save game`, `quit game` and `examine`; is uses `examine` for several objects (and so makes the sign description less verbose), and shows how to override the standard behaviour of a verb (`inventory`) under unusual circumstances.

This stage uses the same directives as the previous stage (and has the same map as that stage).

### Stage 6 map

```

		Throne Room	Crypt
		[sign, lamp]	[vampire, key]
		|		|
		|		|
Cave Mouth------Chamber---------Dungeon
[station]	[cross]		[door]
				=
				|
				Cell
				[*coin*]

```

### Stage 6 source

```
start cave
treasury throne

occur when !flag 1
	print "Welcome to the Tutorial adventure."
	print "You must find a gold coin and store it."
	set_flag 1

room cave "cave mouth"
	exit east chamber

room throne "gorgeously decorated throne room"
	exit south chamber

item sign "sign"

action examine sign when present sign
	print "It says: leave treasure here, then say SCORE"

item lamp "old-fashioned brass lamp"
	called "lamp"

action examine lamp when present lamp
	print "It is not lit."

item lit_lamp "lit lamp"
	called "lamp" nowhere

item empty_lamp "empty lamp"
	called "lamp" nowhere

lightsource lit_lamp
lighttime 10

action light lamp when present lamp
	swap lamp lit_lamp
	print "OK, lamp is now lit and will burn for 10 turns."
	look

occur when flag 16
	clear_flag 16
	swap lit_lamp empty_lamp
	look
	comment "The engine sets flag 16 when the lamp runs out"

item station "lamp-refilling station" at cave

action refill lamp when here station and present empty_lamp
	destroy empty_lamp
	refill_lamp
	print "The lamp is now full and lit."

room chamber "square chamber"
	exit east dungeon
	exit north throne
	exit west cave

# Flag 15 is on when and only when it is dark
occur when at chamber and flag 15
	clear_dark
	look

item cross "Wooden cross"
	called "cross"

room dungeon "gloomy dungeon"
	exit west chamber
	exit north crypt

occur when at dungeon and !flag 15
	set_dark
	look

occur 25% when at dungeon
	print "I smell something rotting to the north."

item door "Locked door"

item key "Brass key"
	called "key"
	at crypt

item door2 "Open door leads south"
	nowhere

action open door when here door and !present key
	print "It's locked."

action open door when here door
	swap door door2
	print OK
	look

action go door when here door2
	goto cell
	look

room cell "dungeon cell"
	exit north dungeon

item coin "*Gold coin*"
	called "coin"

room crypt "damp, dismal crypt"
	exit south dungeon

item vampire "Vampire"

occur when here vampire and carried cross
	print "Vampire cowers away from the cross!"

occur when here vampire and !carried cross
	print "Vampire looks hungrily at me."

occur 25% when here vampire and !carried cross
	print "Vampire bites me!  I'm dead!"
	game_over
	comment "vampire can attack unless cross is carried"

action get key when here vampire and !carried cross
	print "I'm not going anywhere near that vampire!"

item rum "bottle of rum" called rum at cell

action drink rum when carried rum
	destroy rum
	print "OK. I feel funny."

action inventory when !exists rum
	print "I'm carrying ... uh ... you're my best mate, you are."

action score: score
action inventory: inventory
action look: look
action save game: save_game

action quit game
	print "OK, goodbye."
	game_over
action quit:
	print "Did you mean to quit? If so, type QUIT GAME."

action examine:
	print "I see nothing special."

verbgroup get take g
verbgroup drop leave
verbgroup examine x
noungroup lamp lantern
```


## Stage 7

This stage uses a counter to implement a timed event: there is initially no way into the main complex, but ringing the doorbell in the first location starts a timer that results in a cave-in, and an entrance becoming available.

This stage uses the same directives as the previous stage (and has the same map as that stage).

### Stage 7 map

```

		Throne Room	Crypt
		[sign, lamp]	[vampire, key]
		|		|
		|		|
Cave Mouth--||--Chamber---------Dungeon
[doorbell,	[cross]		[door]
 (entrance),			=
 station]			|
				Cell
				[*coin*]

```

### Stage 7 source

```
start cave
treasury throne

occur when !flag 1
	print "Welcome to the Tutorial adventure."
	print "You must find a gold coin and store it."
	set_flag 1

room cave "cave mouth"

item doorbell "doorbell"

item entrance "entrance to cave"
	nowhere

action go entrance when here entrance
	goto chamber
	look

action ring doorbell when here doorbell and !here entrance
	set_counter 4
	print "Ding dong!"

occur
	dec_counter

occur when counter_eq 2
	print "I hear an ominous rumble."

occur when counter_eq 1
	put entrance cave
	print "The rocks collapse leaving a way in."
	look

action wait:
	print "Time passes ..."

room throne "gorgeously decorated throne room"
	exit south chamber

item sign "sign"

action examine sign when present sign
	print "It says: leave treasure here, then say SCORE"

item lamp "old-fashioned brass lamp"
	called "lamp"

action examine lamp when present lamp
	print "It is not lit."

item lit_lamp "lit lamp"
	called "lamp" nowhere

item empty_lamp "empty lamp"
	called "lamp" nowhere

lightsource lit_lamp
lighttime 10

action light lamp when present lamp
	swap lamp lit_lamp
	print "OK, lamp is now lit and will burn for 10 turns."
	look

occur when flag 16
	clear_flag 16
	swap lit_lamp empty_lamp
	look
	comment "The engine sets flag 16 when the lamp runs out"

item station "lamp-refilling station" at cave

action refill lamp when here station and present empty_lamp
	destroy empty_lamp
	refill_lamp
	print "The lamp is now full and lit."

room chamber "square chamber"
	exit east dungeon
	exit north throne
	exit west cave

# Flag 15 is on when and only when it is dark
occur when at chamber and flag 15
	clear_dark
	look

item cross "Wooden cross"
	called "cross"

room dungeon "gloomy dungeon"
	exit west chamber
	exit north crypt

occur when at dungeon and !flag 15
	set_dark
	look

occur 25% when at dungeon
	print "I smell something rotting to the north."

item door "Locked door"

item key "Brass key"
	called "key"
	at crypt

item door2 "Open door leads south"
	nowhere

action open door when here door and !present key
	print "It's locked."

action open door when here door
	swap door door2
	print OK
	look

action go door when here door2
	goto cell
	look

room cell "dungeon cell"
	exit north dungeon

item coin "*Gold coin*"
	called "coin"

room crypt "damp, dismal crypt"
	exit south dungeon

item vampire "Vampire"

occur when here vampire and carried cross
	print "Vampire cowers away from the cross!"

occur when here vampire and !carried cross
	print "Vampire looks hungrily at me."

occur 25% when here vampire and !carried cross
	print "Vampire bites me!  I'm dead!"
	game_over
	comment "vampire can attack unless cross is carried"

action get key when here vampire and !carried cross
	print "I'm not going anywhere near that vampire!"

item rum "bottle of rum" called rum at cell

action drink rum when carried rum
	destroy rum
	print "OK. I feel funny."

action inventory when !exists rum
	print "I'm carrying ... uh ... you're my best mate, you are."

action score: score
action inventory: inventory
action look: look
action save game: save_game

action quit game
	print "OK, goodbye."
	game_over
action quit:
	print "Did you mean to quit? If so, type QUIT GAME."

action examine:
	print "I see nothing special."

verbgroup get take g
verbgroup drop leave
verbgroup examine x
noungroup lamp lantern
noungroup doorbell bell
```


## Caveats

This tutorial skips a lot of details. [The reference manual](../../docs/reference.md) is indispensible for filling in the gaps.

The following directives are not yet discussed: `ident`, `version`, `wordlen`, `maxload`, `lighttime`.

There is not yet any discussion of flags, counters and location stores.

Some discussion of what makes a good game design may be appropriate.

