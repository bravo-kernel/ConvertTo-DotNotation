[![Build Status](https://ci.appveyor.com/api/projects/status/nhonfjdp03hbfif8/branch/master?svg=true)](https://ci.appveyor.com/project/alt3/convertto-dotnotation)
[![Coverage Status](https://coveralls.io/repos/github/alt3/ConvertTo-DotNotation/badge.svg)](https://coveralls.io/github/alt3/ConvertTo-DotNotation)

# ConvertTo-DotNotation

Powershell module for converting (deeply nested) hashes to dot-notation.

```posh
ConvertTo-DotNotation -Hash $someHash
```

## Example

Given the following nested hash as input:

```posh
[hashtable]$myHash = @{
    "key1" = "key1value"
    "subhash1" = @{
        "subhash1key1" = "subhash1key1value"
        "subhash2" = @{
            "subhash2key1" = "subhash2key1value"
        }
    }
}
```

You can create the dotted hash by running:

```posh
ConvertTo-DotNotation -Hash $myHash
```

Which would result in the following single-dimensional hash using dot-notation as key names.:

```posh

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

or in more readable JSON format:

```json
{
    "key1":  "key1value",
    "subhash1.subhash1key1":  "subhash1key1value",
    "subhash1.subhash2.subhash2key1":  "subhash2key1value"
}
```