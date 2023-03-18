function clone{   
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name,
        [Parameter] [string]$dest
    )
    #$token = Read-Host "Token: " -AsSecureString
    $token = Read-Host "Token: "

    if($dest -ne $null){
        $destgit = $dest
    }else{
        $destgit = find-alias "$name-dest"
        if($destgit -eq "$name-dest"){
            $destgit = $null
        }
    }

    $regex = "(http[s]?|[s]?ftp[s]?)(:\/\/)([^\s,]+)"
    if($name -match $regex){
        if($destgit -ne $null){
            git clone $name $destgit
        }else{
            git clone $name
        }
    }else{
        $url = find-alias "$name-url"
        $url = $url.replace("https://","https://$token@")
        if($url -ne "$name-url"){
            if($destgit -ne $null){
                git clone $url $destgit
            }else{
                git clone $url
            }
        }
    }
}

function commit{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )

    $Afolder = find-alias "$name-dest"

    if($Afolder -ne "$name-dest"){
        Push-Location "$Afolder"
    }

    Write-Host "`r`nBranch" -ForegroundColor Gray
    $branch = Read-Host

    if($branch.Length -ne 0){
        git checkout -b $branch
        git diff origin

        $confirm = Read-Host "Continue ? (y/n)"
        if($confirm -eq 'y'){
            git add -A
            git commit -m $branch
            git push --set-upstream origin $branch
        }
    }

    if($Afolder -ne "$name-dest"){
        Pop-Location
    }
}

function purge{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )

    $confirm = Read-Host "Continue ? (y/n)"
    if($confirm -eq 'y'){
        $Afolder = find-alias "$name-dest"
        if($Afolder -ne "$name-dest"){
            Push-Location "$Afolder"

            Remove-Item $Afolder\* -Recurse -Force

            Pop-Location
        }else{
            Remove-Item $name\* -Recurse -Force
        }
    }
}

function pull{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )

    $Afolder = find-alias "$name-dest"
    if($Afolder -ne "$name-dest"){
        Push-Location "$Afolder"
        git pull
        Pop-Location
    }else{
        git pull
    }
}