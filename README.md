# ComputerCraft_autominer

Some lua code to refuel from a lava lake and mine a certain area

## Usage

### mine.lua
This code expects enough fuel and chests in the correct slots. The amount necessary is calculcated by the input parameters. It will throw an assertion error otherwise. It takes two parameters, depth and width, for example 64 16.

### getLava.lua
This code expects some fuel to start with, and a bucket in slot 16. Place it 1 block above a lava lake. It will stop if the block in front is not lava.
