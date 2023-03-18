function test-tcp{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$srv,
        [Parameter(Mandatory = $true)] [int]$port
    )

    try{
        $null = New-Object System.Net.Sockets.TCPClient -ArgumentList $srv, $port
        return $true
    }catch{
        return $false
    }
}

function sshk{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )  
    $name = find-alias $name
    ssh $user@$name -i $ssh_key
}

function ssha{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )  
      
    $name = find-alias $name
    ssh $user@$name
}

function sshr{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )  
      
    $name = find-alias $name
    Write-Host $name
    ssh "root@$name"
}

function rdp{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )  
    mstsc /v:$name
}

function sh{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )  
   
    $name = find-alias $name

    $ip = ([System.Net.Dns]::GetHostAddresses($name)).IPAddressToString
    $version = $null
    if($ip.StartsWith($dmz_network)){
        #root DMZ Server
        Write-Host "Connexion DMZ"
        if((test-tcp $name 22) -eq $True){
            sshk $name
        }else{
            mstsc /v:$name
        }
    }else{
        $result = Get-ADComputer -Filter "(Name -like '*$name*')" -properties OperatingSystem
        $version = $result.OperatingSystem
        if($version -like '*Windows*'){
            mstsc /v:$name
        }else{
            if((test-tcp $name 22) -eq $True){
                Write-Host "Connexion avec $user"
                ssh $user@$name
            }else{
                mstsc /v:$name
            }
        }
    }
}


function invoke{   
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name,
        [Parameter(Mandatory = $true)] [string]$command
    )
    $name = find-alias $name
    
    $cred = get-credential -credential "$user"
    Invoke-Command -ComputerName "$name" -ScriptBlock { "$command" } -credential $cred
}