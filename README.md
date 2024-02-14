# HexPiler
Hexpiler is a compiler for a modified .hexpattern format for Hex Casting that runs in ComputerCraft, allowing you to automatically download and write iotas to a Focus.

## Installation
Download and run the installer on a ComputerCraft computer:
```
wget https://raw.githubusercontent.com/Shirtsy/HexPiler/main/install_hexget.lua
```

## Usage
Compile a .hexpattern into a Focus:
```
hexget <url>
```

## Syntax

Symbols are written in the hexpattern format

```
Mind's Reflection
Compass Purification
```

The following frequently used symbols have aliases you can use instead if you so choose.
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
```

Numerical Reflection and Bookkeepers are NOT currently available but will be added soon. Embed them in the meantime.
