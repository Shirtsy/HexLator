# HexLator
HexLator is a compiler for Hex Casting hexes that runs in ComputerCraft. It comes packaged with HexGet, a utility to download and compile a hex to a focus, as well as HexxyEdit, an in-game hex editor. Both will compile a tweaked .hexpattern format that includes additional syntax for embedded iotas and macros.

## Requirements
The Focal Port from https://github.com/SamsTheNerd/ducky-periphs is required to write to Foci.

## Installation
Download and run the installer on a ComputerCraft computer (this will replace the existing startup.lua file at root):
```
wget https://raw.githubusercontent.com/Shirtsy/HexLator/main/install_hexlator.lua
```

## Usage example
Compile a .hexpattern from the internet into a Focus:
```
hexget https://raw.githubusercontent.com/Shirtsy/HexLator/main/example.hexpattern
```

## Syntax

Symbols are written in the hexpattern format:

```
Mind's Reflection
Compass Purification
```

Bookkeeper's Gambit and Numerical Reflection are used as such. The latter supports positive and negative integers:
```
Bookkeeper's Gambit(-vv---)
Numerical Reflection(-367)
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

### Macros/Functions
```#def(<name>)(<body>)``` will result in all instances of ```$<name>``` being replaced with ```<body>```. This can be paired with ```#file``` to load a 'library' of functions from another file to be made available in your current file.

```#file(<filename1>, <filename2>, ...)``` will look for ```<filename>```(s) and replace itself with their contents in order. This can be used to directly insert data at a given position, but is more commonly used to include 'libraries'. The following is an example, assuming that ```example.hexpattern``` is to be compiled.

```#wget(<filepath>)(<url>)``` will attempt to use the wget utility packaged with the default ComputerCraft ROM to download a given file at time of compilation (overwriting any existing ones). ```#file``` is still necessary to load the file afterwards, however.

example.hexpattern:
```
#file(counter.hexpattern)

{@num(10)} >>
$return_list
```
counter.hexpattern:
```
#def(return_list)(
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
)
```
Output:
```
[0,1,2,3,4,5,6,7,8,9]
```