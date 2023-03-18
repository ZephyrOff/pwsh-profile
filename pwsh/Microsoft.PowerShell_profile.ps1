function find-alias([string]$name) {
    if ($alias -ne $null){
        foreach($srv in $alias.GetEnumerator()){
            if ($srv.Key -eq $name){
                $name = $srv.Value
                break
            }
        }
    }
    return $name
}

function load-alias {
    if (Test-Path -Path $profile_path/.alias){
        try {
            $global:alias = @{}
            foreach($line in (Get-Content -Path $profile_path/.alias)) {
                $line = $line -split "#"
                if ($line.Length -ge 2){
                    $global:alias.Add($line[0], $line[1])
                }
            }   
        }
        catch {
            Write-Host "Failed to load alias"
        }
    }
}


#$Shell = $Host.UI.RawUI
$LocalGC = $null
$user = "alex"
$dmz_network = "N.A"
$ssh_key = ""

#Set Profile Path
$array = $profile -split "\\"
$profile_path = ($array[0..($array.Count-2)]) -join "\"

#Import AddOn
if (Test-Path -Path $profile_path/AddOn){
    $AddOn = @(Get-ChildItem -Path $profile_path/AddOn  -Recurse -Include *.ps1 -ErrorAction Stop)
    foreach ($file in $AddOn) 
    {
        try {
            . $file
        }
        catch {
            Write-Host "Failed with import of $file"
        }
    }
}

load-alias

oh-my-posh init pwsh --config "$profile_path\apps\perso.omp.json" | Invoke-Expression
& $profile_path\apps\winfetch.ps1