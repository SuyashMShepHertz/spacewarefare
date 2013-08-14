Space Warfare
=============

Space Warfare is a **MMO demo** build using flixel game engine and Shephertz's **AppWarp** Multiplayer game engine.

Currently, there is only one room availabe, all users connect with a randomly generated name and join this room. Player can move using  arrow keys (Up, Down, Left, Right) and shoots with mouse click.

There are different objects like bullets, health and diamonds that users can pick.

To optimize network load, the player moves in a **grid of 25x25 pixels**, hence I only send message for movement when player moves from one block to another.

Whenever player clicks, bullet is shot and a blast animation is played. This information is **not exhcanged** until the player shoots the other player. On getting a hit from other player health is reduced. Bullets are limited, hence to shoot them you have to collect bullets.

The objects available are placed usign **AppWarp Room Properties**. Whenever a player picks an object he/she places it somewhere else and **updates the properties** with new position of that object.
