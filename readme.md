[![Build Status](https://ci.appveyor.com/api/projects/status/nhonfjdp03hbfif8/branch/master?svg=true)](https://ci.appveyor.com/project/alt3/convertto-dotnotation)

# ConvertTo-DotNotation

Powershell module for converting (deeply nested) hashes to dot-notation

```posh
ConvertTo-DotNotation -Hash $someHash
```

## Usage

```posh
[hashtable]$hash = @{
    "key1" = "key1value"
    "subhash1" = @{
        "subhash1key1" = "subhash1key1value"
        "subhash2" = @{
            "subhash2key1" = "subhash2key1value"
        }
    }
}

ConvertTo-DotNotation -Hash $someHash

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Object[]                                 System.Array
---------------------------------

Key   : subhash1.subhash2.subhash2key1
Value : subhash2key1value
Name  : subhash1.subhash2.subhash2key1


Key   : subhash1.subhash1key1
Value : subhash1key1value
Name  : subhash1.subhash1key1


Key   : key1
Value : key1value
Name  : key1
```
