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



### Iota Syntax
Iotas are written in the following format:
```
@num(1)                        //Number
@vec(1,2,3)                        //Vector
[1, @vec(1, 2, 3)]                 //List
@entity("uuid")                        //Entity 
@null                           //Null
@garbage                        //Garbage
@true                           //Bool
@pattern(NORTHEAST,qaq)                  //Symbol via pattern
Numerical Reflection        //Pattern via name
@str(hello world)                  //String
```

### Embedding Iotas
```
<Iota>: direct insertion, no escape
<{Iota}>: embed with intro/retro/flock
<\Iota>: embed with consideration(s)
<<Iota>>: embed with intro or considerations, whichever is shorter
```

Numerical Reflection and Bookkeepers are NOT currently available but will be added soon. Embed them as iotas instead, in the meantime.
