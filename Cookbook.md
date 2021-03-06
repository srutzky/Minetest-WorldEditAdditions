# WorldEditAdditions Cookbook
This file contains a number of useful commands that WorldEditAdditions users have discovered and found useful. They do not necessarily have to contain _WorldEditAdditions_ commands - pure _WorldEdit_ commands are fine too.

See also:

- [Quick Command Reference](https://github.com/sbrl/Minetest-WorldEditAdditions/tree/master#quick-command-reference)
- [WorldEditAdditions Detailed Chat Command Explanations](https://github.com/sbrl/Minetest-WorldEditAdditions/blob/master/Chat-Command-Reference.md)
- [WorldEdit Chat Command Reference](https://github.com/Uberi/Minetest-WorldEdit/blob/master/ChatCommands.md)


## Fix lighting
```
//multi //1 //2 //outset 50 //fixlight //y
```

As a brush:

```
//brush cubeapply 50 fixlight
```

## Terrain editing
The following brushes together can make large-scale terrain sculpting easy:

```
//brush cubeapply 25 set stone
//brush ellipsoid 11 9 11 stone
//brush sphere 5 stone
//brush cubeapply 50 fillcaves stone
//brush cubeapply 30 50 30 conv
//brush cubeapply 50 conv
//brush sphere 5 air
//brush cubeapply 50 fixlight
//brush cubeapply 50 layers dirt_with_grass dirt 3 stone 10
```

## En-mass Foliage clearing
Clearing large amounts of foliage is easy!

```
//many 25 //multi //clearcut //y //shift x 10
```

Adjust the numbers (and direction in the `//shift` command) to match your scenario.
