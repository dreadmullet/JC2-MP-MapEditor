### What is this?

It was born out of a need to create race courses easily, but the goal became a feature-rich, generic map editor that scripters can easily extend to use in their own gamemodes.

![Image 1](http://i.imgur.com/hNzQsUy.jpg)

![Image 2](http://i.imgur.com/Cbjycb0.jpg)

![Image 3](http://i.imgur.com/sWnlyRO.jpg)

![Image 4](http://i.imgur.com/ndyEzs1.jpg)

### "I just want to use the editor to make maps; how do I start?"

* [Install the JC2-MP server](http://wiki.jc-mp.com/Server/Getting_started/Windows_Server).
* [Install this script](https://github.com/dreadmullet/JC2-MP-MapEditor/archive/master.zip) into the server's *scripts* directory.
* [Install the latest racing script](https://github.com/dreadmullet/JC2-MP-Racing/archive/master.zip). It shouldn't require any settings tweaks.

Every control is listed on screen, you should have no problems. Look at the existing racing courses if you need help or inspiration. Have fun creating!

### "I'm a scripter, how do I integrate the editor into my script?"

Documentation will be added eventually, but feel free to use the Racing script as an example. See:

* MapEditor/client/MapTypes/cMapTypeRacing.lua
* MapEditor/client/Objects/
* Racing/server/sCourse.lua
* Racing/server/sRacerBase.lua

Note, however, that the map editor API is currently rough and will certainly go through at least a small rewrite in the future.

### Future goals

* Inputs and outputs on objects. Connect the OnActivate checkpoint output to an explosion effect's Play input to make fireworks when people enter checkpoints.
* Moving objects. Create elevators, ceiling crushers, or a submarine that moves in a path around the map.

### Known issues

* Selecting objects is finicky.
* Lack of buttons for many functions, only keys.
* Modelviewer's selection of tagged and named models is limited.
* There is no fancy multi-player editor support and likely never will be.
* It's meant to run on a local server, not on a public server. If anyone asks for a /mapeditor command they will be tased.

### Importing old courses

You can import maps from the old Racing version using the client console command *loadoldcourse*.
