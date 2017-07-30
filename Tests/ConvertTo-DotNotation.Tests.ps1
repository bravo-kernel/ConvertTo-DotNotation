#
# https://github.com/pester/Pester/wiki/Should
#
# @todo fix hash-keys with - in it

# emulate PSScriptRoot not available on Posh2
if(-not $PSScriptRoot)
{
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}
$PSVersion = $PSVersionTable.PSVersion.Major

# import the module
Import-Module $PSScriptRoot\..\ConvertTo-DotNotation.psm1 -Force

# define our test hash
$hash = @{
    "mainkey1" = "mainkey1value"
    "hash1" = @{
        "hash1key1" = "hash1key1value"
        "subhash2" = @{
            "subhash2key1" = "subhash2key1value"
            "subhash2key2" = "subhash2key2value"
            "subhash3" = @{
                "subhash3key1" = "subhash3key1value"
                "subhash4" = @{
                    "subhash4key1" = "subhash4key1value"
                    "subhash4key2" = "subhash4key2value"
                }
            }
        }
    }
    "hash2" = @{
        "hash2key1" = "hash2key1value"
        "hash2key2" = "hash2key2value"
    }
    "mainkey2" = "mainkey2value"
    "hash3" = @{}
    "types" = @{
        "string" = "some-string"
        "null" = $null
        "true" = $true
        "false" = $false
        "quotes-only" = ""
        "integer" = 123
        "array" = @(1, 2, 3)
    }
}

# test using strict mode
Describe "ConvertTo-DotNotation PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        $dotted = ConvertTo-DotNotation -Hash $hash

        $dotted

        # make sure the expected object is returned by the function
        It $dotted {
            $dotted | Should BeOfType HashTable
            $dotted.count | Should BeExactly 17
        }

        # make sure returned hash contains dot-notated key names
        It $dotted {
            $dotted."mainkey1" | Should BeExactly mainkey1value
            $dotted."mainkey2" | Should BeExactly mainkey2value

            $dotted."hash1.hash1key1" | Should BeExactly hash1key1value
            $dotted."hash1.subhash2.subhash2key1" | Should BeExactly subhash2key1value
            $dotted."hash1.subhash2.subhash2key2" | Should BeExactly subhash2key2value
            $dotted."hash1.subhash2.subhash3.subhash3key1" | Should BeExactly subhash3key1value
            $dotted."hash1.subhash2.subhash3.subhash4.subhash4key1" | Should BeExactly subhash4key1value
            $dotted."hash1.subhash2.subhash3.subhash4.subhash4key2" | Should BeExactly subhash4key2value

            $dotted."hash2.hash2key1" | Should BeExactly hash2key1value
            $dotted."hash2.hash2key2" | Should BeExactly hash2key2value
        }

        # make sure the key with empty subhash has not been added to the result
        It $dotted {
            {$dotted."hash3"} | Should Throw "The property 'hash3' cannot be found on this object. Verify that the property exists."
        }

        # verify result respects type constraints for the values
        It  $dotted {
            $dotted."types.string" | Should BeOfType String
            $dotted."types.null" | Should BeNullOrEmpty
            $dotted."types.true" | Should BeOfType Boolean
            $dotted."types.false" | Should BeOfType Boolean
            $dotted."types.quotes-only" | Should BeOfType String
            $dotted."types.integer" | Should BeOfType Int
            $dotted."types.array".count | Should BeExactly 3
        }
    }
}
