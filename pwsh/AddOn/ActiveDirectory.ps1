function Get-User{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )

    if($LocalGC -eq $null){
        $LocalSite = (Get-ADDomainController -Discover).Site
        $NewTargetGC = Get-ADDomainController -Discover -Service 6 -SiteName $LocalSite
        if(!$NewTargetGC){
            $NewTargetGC = Get-ADDomainController -Discover -Service 6 -NextClosestSite
        }
        $NewTargetGCHostName = $NewTargetGC.HostName
        $LocalGC = "$NewTargetGCHostName" + ":3268"
    }
    $info = Get-ADUser -Filter "(Name -like '*$name*')" -Server "$LocalGC" -properties CN, Created, DistinguishedName, Enabled, LastLogonDate, MemberOf, Modified, UserPrincipalName, SamAccountName
    foreach($user in $info){    
        Write-Host "`n`nCN                :"$user.CN
        Write-Host "Created           :"$user.Created
        Write-Host "DistinguishedName :"$user.DistinguishedName
        Write-Host "Enabled           :"$user.Enabled
        Write-Host "LastLogonDate     :"$user.LastLogonDate
        if($user.MemberOf.Length -gt 1){
            Write-Host "MemberOf          :"
            foreach($group in $user.MemberOf){
                Write-Host "                   "$group
            }

        }else{
            Write-Host "MemberOf          :"$user.MemberOf
        }
        Write-Host "Modified          :"$user.Modified
        Write-Host "UserPrincipalName :"$user.UserPrincipalName
        Write-Host "SamAccountName    :"$user.SamAccountName
    }
}

function Get-Computer{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )

    if($LocalGC -eq $null){
        $LocalSite = (Get-ADDomainController -Discover).Site
        $NewTargetGC = Get-ADDomainController -Discover -Service 6 -SiteName $LocalSite
        if(!$NewTargetGC){
            $NewTargetGC = Get-ADDomainController -Discover -Service 6 -NextClosestSite
        }
        $NewTargetGCHostName = $NewTargetGC.HostName
        $LocalGC = "$NewTargetGCHostName" + ":3268"
    }
    Get-ADComputer -Filter "(Name -like '*$name*')" -Server "$LocalGC" -properties DNSHostName, Description, CanonicalName, CN, Enabled, IPv4Address, MemberOf, ObjectClass, OperatingSystem, OperatingSystemVersion
}

function Get-Group{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )

    Get-ADGroup -Filter "(Name -like '*$name*')"
}

function Get-GroupMember{
    Param
    (
        [Parameter(Mandatory = $true)] [string]$name
    )

    Get-ADGroupMember -Identity "$name"
}


function Test-Auth{
    $cred = Get-Credential
    $username = $cred.username
    $password = $cred.GetNetworkCredential().password

    ((New-Object DirectoryServices.DirectoryEntry -ArgumentList "",$UserName, $Password).psbase.name) -ne $null
}