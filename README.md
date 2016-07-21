# AsteroidsLua
An Asteroids clone made in [Polycode](http://www.polycode.org) using Lua scripting

### Why another clone?
The game shares a lot of common gamedev programming problems, and as an nostalgia and arcade entusiast (although still haven't played this on a real cab >-<) I thought it would be fun to make, as a challenge.
It's also a learning experience to get to know Polycode better (the engine which i'm using) and keeping up with my programming interest.
My goal for this clone was also to try to simulate some of that gorgeous vector lighting you get from the real arcade cab, as it truly makes the game look and feel more interesting.

![game](https://thumbs.gfycat.com/PotableJadedCaterpillar-size_restricted.gif)

### Features
* Vector glow
* Spawn protection
* Recognizable asteroid shapes
* Hyperspace
* Increasingly difficult saucers (as in the original)
* Insert coin
* bullet trail simulating the monitor burn.

### How to play
Destroy as many rocks as possible. 
When all rocks have been destroyed, a new wave will be initiated.

Hyperspace can be used in emergencies, teleporting the player to a random destination on the screen. The risk however is that the ship might explode on reentry.

An extra life will be gained at every 10.000 points. 

Use Arrow keys to stear.  
shoot using "x" and press space to start.  
To insert a coin, press F3. The text will stop blinking afterwards.  

#### Points
* Large rocks = 20 Point
* Medium rocks = 50 Point
* Small rocks = 100 Point
* Large Saucer = 200 Point
* Small Saucer = 1000 Point

### What's missing
* Top 10 highscore board.

To be able to compile the game yourself, you'll need the latest [Source](https://github.com/ivansafrin/Polycode/tree/goodbye_cmake) of Polycode.
