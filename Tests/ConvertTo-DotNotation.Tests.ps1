#
# https://github.com/pester/Pester/wiki/Should
#

# emulate PSScriptRoot not available on Posh2
if(-not $PSScriptRoot)
{
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}
$PSVersion = $PSVersionTable.PSVersion.Major

# import the module
Import-Module $PSScriptRoot\..\ConvertTo-DotNotation.psm1 -Force

# test using strict mode
Describe "ConvertTo-DotNotation PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

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

        # create the dot-notated hash we will test against
        $dotted = ConvertTo-DotNotation -Hash $hash

        It "makes sure the resultant object looks like expected" {
            $dotted | Should BeOfType HashTable
            $dotted.count | Should BeExactly 17
        }

        It "makes sure the resultant hash contains the expected dot-notated key names" {
            $dotted."mainkey1" | Should BeExactly "mainkey1value"
            $dotted."mainkey2" | Should BeExactly "mainkey2value"

            $dotted."hash1.hash1key1" | Should BeExactly "hash1key1value"
            $dotted."hash1.subhash2.subhash2key1" | Should BeExactly "subhash2key1value"
            $dotted."hash1.subhash2.subhash2key2" | Should BeExactly "subhash2key2value"
            $dotted."hash1.subhash2.subhash3.subhash3key1" | Should BeExactly "subhash3key1value"
            $dotted."hash1.subhash2.subhash3.subhash4.subhash4key1" | Should BeExactly "subhash4key1value"
            $dotted."hash1.subhash2.subhash3.subhash4.subhash4key2" | Should BeExactly "subhash4key2value"

            $dotted."hash2.hash2key1" | Should BeExactly "hash2key1value"
            $dotted."hash2.hash2key2" | Should BeExactly "hash2key2value"
        }

        It "makes sure the key with the empty subhash is not added to the resultant hash" {
            {$dotted."hash3"} | Should Throw "The property 'hash3' cannot be found on this object. Verify that the property exists."
        }

        It "makes sure the resultant hash values preserved the type constraints" {
            $dotted."types.string" | Should BeOfType String
            $dotted."types.null" | Should BeNullOrEmpty
            $dotted."types.true" | Should BeOfType Boolean
            $dotted."types.false" | Should BeOfType Boolean
            $dotted."types.quotes-only" | Should BeOfType String
            $dotted."types.integer" | Should BeOfType Int
            $dotted."types.array".count | Should BeExactly 3
        }

        # ======================================================
        # make sure this hash structure doesn't break the module
        # ======================================================
        $hash = @{
            "x" = "y"
        }

        $dotted = ConvertTo-DotNotation -Hash $hash

        It "makes sure passing a single-dimensional hash does not break the module" {
            $dotted.count | Should BeExactly 1
            $dotted."x" | Should BeExactly "y"
        }

        # ======================================================
        # make sure this hash structure doesn't break the module
        # ======================================================
        $hash = @{
            "subhash1" = @{
                "subhash1key1" = "subhash1key1value"
            }
        }

        $dotted = ConvertTo-DotNotation -Hash $hash

        It "makes sure passing a multi-dimensional hash without root keys does not break the module" {
            $dotted.count | Should BeExactly 1
            $dotted."subhash1.subhash1key1" | Should BeExactly "subhash1key1value"
        }
    }
}
