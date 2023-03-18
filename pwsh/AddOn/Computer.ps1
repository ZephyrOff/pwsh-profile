function Info{
    $info = Get-ComputerInfo
    $info | Get-Member
}


function watch{
    Param
    (
        [Parameter(Mandatory = $true)] [int]$refresh,
        [Parameter(Mandatory = $true)] [string]$command
    )

    $i=0
    While(1){
        clear
        $i+=1
        Write-Host "Repeat-Interval: $refresh   -   Count: $i`n"
        Invoke-Expression $command
        Start-Sleep -Seconds $refresh
    }
}