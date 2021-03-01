# Alien Invasion Gamemode for Onset

Alien Invasion is a gamemode for [Onset](https://playonset.com/) written in Lua and VueJS.

[![ALIEN INVASION](https://i.gyazo.com/81411c6f822a754156df834fba6cdd1d.png)](https://gyazo.com/81411c6f822a754156df834fba6cdd1d)

## The Game

### Synopsis

The world has been invaded by nearly indestructible killers from outer space.

Upon joining the server, you will be part of a group of desperate lone survivors of the invasion whose only mission is to stay alive long enough to defeat the mothership.

We do not know much about these alien lifeforms.  We do know that they are very difficult to kill. If one of these creatures spots you, they will begin chasing you and will kill you instantly.  The best advice is to run away to a safe distance unless you are prepared to fight.  Try to outsmart them if you can, they are rather dumb.

You will be backed by the reinforcements from the military.  They will drop supplies (health, armor, and weapons) occasionally.  If you hear aircraft overhead or see fireworks, head towards the drop zone - but be warned, these areas are NOT safezones.  You MAY encounter conflict from other players while obtaining the loot box.  

The satellite computer has enough power to communicate with the mothership. Search the island for resources that can be used to operate the satellite computer to reach the end game.  HINT: You'll want to make sure you're with a group and heavily armed before fighting the mothership.

### Features

* Persistent world, player data is saved every minute.
* Character selection at spawn, skydive with parachute into the island.
* The garage computer terminal will provide instructions/clues about the mission.
* Supply drops at random locations every few minutes provide health, armor, and a weapon. (uses waypoints)
* Computer parts hidden around the island that can be picked up and taken to the main satellite computer.
* Satellite will send a signal to the mothership to engage. (cue the boss fight)
* Mothership attacks players until everyone is dead or defeated.
* Scrap heaps provide resources such as metal shards, plastic tarps, and computer parts.
* Workbench system for building items with resources that you find at the scrap heaps.
* Inventory system with interactive objects and hotbar selection.
* Merchant system for purchasing items with cash.
* Interactive world props (tree, water, certain items)
* Storage containers that spawn random items.

### Direction

While Alien Invasion started life as a simple AI shooter gamemode for Onset, the original
purpose of this project was to learn Lua scripting for Onset.  This project has since
grown quite a bit with features not really applicable to a simple alien shooter, and that
is OK.  This code will continue to morph and shift into something more general and widely-usable for other Onset gamemodes in the future.

### Dependencies

This package has dependencies upon the following packages, which should be defined above this package in the server_config.json file:

* Onset_Weapon_Patch (https://github.com/Origin-OnSet/Onset_Weapon_Patch)
* Onset-BPEvents (https://github.com/vugi99/onset-BPEvents)
* onset-vnpcs (https://github.com/vugi99/onset-vnpcs)

### Thanks

* Voltaism for help with Onset pak integration, his awesome onset packages, and testing contributions.
* Talos and the Onset community for their wealth of knowledge of the Unreal Engine.
