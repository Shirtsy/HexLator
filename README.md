# HexPiler
Hexpiler is a compiler for a modified .hexpattern format for Hex Casting that runs in ComputerCraft, allowing you to automatically download and write iotas to a Focus.

## Requirements
The Focal Port from https://github.com/SamsTheNerd/ducky-periphs is required to write to Foci.

## Installation
Download and run the installer on a ComputerCraft computer (this will replace the existing startup.lua file at root):
```
wget https://raw.githubusercontent.com/Shirtsy/HexPiler/main/install_hexpiler.lua
```

## Usage example
Compile a .hexpattern into a Focus:
```
hexget https://raw.githubusercontent.com/Shirtsy/HexPiler/main/example.hexpattern
```

## Syntax

Symbols are written in the hexpattern format:

```
Mind's Reflection
Compass Purification
```

The following frequently used symbols have aliases you can use instead if you so choose:
```
{  = Introspection
}  = Retrospection
>> = Flock's Disintegration
```

Thus, a common pattern for embedding iotas looks like: ```{@vec(1, 2, 3)} >>```

### Iota Syntax
Iotas are written in the following format:
```
@num(1)                        //Number
@vec(1,2,3)                    //Vector
[1, @vec(1, 2, 3)]             //List
@entity("uuid")                //Entity 
@null                          //Null
@garbage                       //Garbage
@true                          //Bool
@pattern(NORTHEAST,qaq)        //Symbol via pattern
Numerical Reflection           //Pattern via name
@str(hello world)              //String
@gate("id")                    //Gate via string
@entity_type("type")           //Entity type via string
@iota_type("type")             //Iota type via string
@mote("moteUuid", "itemID")    //Mote via strings
@matrix(col, row, [matrix])    //Matrix
```

### Macros
```#file(<filename>)``` will look for ```<filename>``` in the program's running directory and replace itself with its contents. This allows for functionality akin to macros or limited functions. The following is an example, assuming that ```example.hexpattern``` is to be compiled.

example.hexpattern:
```
{@num(10)} >>
#file(counter.hexpattern)
```
counter.hexpattern:
```
{
    Jester's Gambit
    Gemini Gambit
}
{
    Gemini Decomposition
    Abacus Purification
    Integration Distillation
}
Single's Purification
Thoth's Gambit
@pattern(WEST,ae)
{
    >>
}
Jester's Gambit
Thoth's Gambit
Vacant Reflection
Jester's Gambit
Hermes' Gambit
```
Output:
```
[0,1,2,3,4,5,6,7,8,9]
```

### Notes
Numerical Reflection and Bookkeepers are NOT currently available but will be added soon. Embed them in the meantime.
