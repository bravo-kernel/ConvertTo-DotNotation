<#
    .SYNOPSIS
    Converts a hash into an array with key/value pairs using dot-notation as the key.
    .PARAMETER Hash
    Hash to be converted (any depth)
    .LINK
    http://github.com/alt3/ConvertTo-DotNotation
#>
Set-StrictMode -Version Latest

function ConvertTo-DotNotation() {
    [cmdletbinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Hash = $(throw "Function argument -Hash is mandatory, please provide a value.")
    )

    $dotted = dotRecurse -Hash $Hash

    # remove the enclosing array produced by the recursive function so we can return a hash
    $result = @{}
    foreach ($hash in $dotted) {
        $hash.GetEnumerator() | ForEach-Object {
            $result.Add($_.Name, $_.Value)
        }
    }

    Return $result
}


function dotRecurse() {
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Hash = $(throw "Function argument -Hash is mandatory, please provide a value."),
        [string]$DotPath = ""
    )

    # use DotPath to extract temporary hash to work on
    if ($DotPath -eq "") {
        $tempHash = $Hash.Clone()
    } else {
        Invoke-Expression "`$tempHash = `$Hash.$DotPath"
    }

    if ($tempHash -eq $null) {
        throw "Passed -DotPath argument '$DotPath' did not result in an extracted hash."
    }

    write-verbose "------------------------------"
    Write-Verbose "Begin function"
    write-verbose "Hash keys in DotPath '$DotPath':"

    $hashKeys = $tempHash.keys

    foreach ($hashKey in $tempHash.keys) {
        Write-Verbose "=> $hashKey"
    }

    ## Recurse if we encounter a subhash
    Write-Verbose "Detecting sub-hashes:"
    foreach ($hashKey in $tempHash.keys) {

        if ($TempHash[$hashKey] -is [hashtable]) {

            if ([string]::IsNullOrEmpty($DotPath)) {
                $DotPath = $hashKey
            } else {
                $DotPath = "$DotPath.$hashKey"
            }

            # call self recursively with dotpath, the return is crucial or the loop will continue
            write-verbose "=> recursing into '$hashKey'"
            dotRecurse -Hash $Hash -DotPath $DotPath
            return
        }
    }
    write-verbose "=> none"

    # we are here so there are no subhashes anymore which means we must
    # eiter be inside a branch OR inside the root
    Write-Verbose "Adding key/value pairs to result:"
    $deleteList = @()

    foreach ($hashKey in $tempHash.keys) {

        # determine DotPath:
        # - use nothing if we are in the root of the hash
        # - only use the key if we are in a ending-branch
        if ($dotPath -eq "") {
            $key = $hashKey
        } else {
            $key = "$DotPath.$hashKey"
        }

        $value = $TempHash.$hashKey

        # ============================================================
        # Important: here we output/return the key/value pair so it is
        # added to the resultant array (created automatically for this
        # recursive function by POSH automatically).
        # ============================================================
        Write-Verbose "=> $key = $value"
        @{$key = $value}

        $deleteList += $hashKey # keep a list, we cannot remove form
    }

    # remove items, this also prevents last (non-nested) keys from triggering an endless loop
    Write-Verbose "Removing processed keys from passed hash"
    $deleteList | ForEach-Object {
        if ($DotPath -ne "") {
            Invoke-Expression "`$removeKey = `$Hash.$DotPath"
            $removeKey.Remove($_)
        } else {
            $Hash.remove($_)
        }
    }

    # if `DotPath` is no empty there are still subhashes to process,
    # strip the currently process branch from the hash before
    # passing the hash back recursively
    if ($dotPath -ne "") {

        # still subhashes to process, strip the hash before passing it recursively
        Write-Verbose "Removing processed sub-hash from passed hash"

        $hashPath = ([regex]::Match($DotPath,'(.+)\.(.+)')).Groups[1].value
        $hashKey  = ([regex]::Match($DotPath,'(.+)\.(.+)')).Groups[2].value

        if ($hashPath -ne "") {
            # use invoke so we can use dot-notation to extract the hash key
            # (because remove only works if the sub-hash is passed as an argument)
            Invoke-Expression "`$key = `$Hash.$hashPath"
            $key.Remove($hashKey)
        } else {
            # if hashpath is empty it means the sub-branch could not be extracted
            # so we use DotPath instead (because either in a outermost-branch)
            $Hash.Remove($DotPath)
        }

        # Call our self recursively but reset the dotpath so we start all over again
        # unless... the hash is empty, in that case simply continue/exit.
        if ($Hash.Count -eq 0) {
            Write-Verbose "Stop recursing, hash is empty"
        } else {
            Write-Verbose "Recursing with empty DotPath to process remaining hash"
            dotRecurse -Hash $Hash -DotPath ""
        }
    }
}

Export-ModuleMember -Function "ConvertTo-DotNotation"
