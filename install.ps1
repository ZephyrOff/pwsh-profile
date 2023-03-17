
 function Add-Font {
  [CmdletBinding(DefaultParameterSetName='Directory')]
  Param(
    [Parameter(Mandatory=$false,
      ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [Parameter(ParameterSetName='File')]
    [ValidateScript({Test-Path $_ -PathType Leaf })]
    [System.String]
    $FontFile
  )

  begin {
    Set-Variable Fonts -Value 0x14 -Option ReadOnly
    #$fontRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.NameSpace($Fonts)
    $objfontFolder = $folder.self.Path
    $copyFlag = [string]::Format("{0:x}",4+16)


  }

  process {
    $fontFiles = Get-ChildItem -Path $FontFile -Include @("*.fon", "*.fnt", "*.ttf","*.ttc", "*.otf", "*.mmm", "*.pbf", "*.pfm")
    if ($fontFiles) {
      foreach ($item in $fontFiles) {
        Add-Type -AssemblyName System.Drawing
        $fontCollection = New-Object System.Drawing.Text.PrivateFontCollection
        $fontCollection.AddFontFile($item)
        $fontFamily = $fontCollection.Families[0]
        $fontName = $fontFamily.Name

        if ($installedFontFamilies -contains $fontName) {
            Write-Host "La font {$($item.Name)} est déjà installé"
        } else {
          Add-Type -AssemblyName System.Drawing
          $objFontCollection = New-Object System.Drawing.Text.PrivateFontCollection
          $objFontCollection.AddFontFile($item.FullName)
          $FontName = $objFontCollection.Families.Name
          $folder.CopyHere($item.FullName, $copyFlag)
        }


        
      }
    }
  }
  end {
  }
 }

Write-Host "========== DEBUT DE L'INSTALLATION =========="
$profile_folder = Split-Path -parent $profile
$app_folder = $profile_folder+"\apps"
if (!(Test-Path -Path $app_folder)) {
    Write-Host "Création du dossier apps"
	New-Item -ItemType Directory -Path $app_folder -Force -OutVariable outputDirectory > $null
}

$wallpaper_folder = $profile_folder+"\wallpapers"
if (!(Test-Path -Path $wallpaper_folder)) {
    Write-Host "Création du dossier wallpapers"
	New-Item -ItemType Directory -Path $wallpaper_folder -Force -OutVariable outputDirectory > $null
}
Write-Host "Téléchargement du fond"
Invoke-WebRequest "https://raw.githubusercontent.com/ZephyrOff/pwsh-profile/main/terminal/background.jpg" -OutFile $wallpaper_folder"\background.jpg" -UseBasicParsing

$outputFolder = $env:USERPROFILE+"\AppData\Local\Microsoft\Windows\Fonts\"
if (!(Test-Path -Path $outputFolder)) {
    Write-Host "Création du dossier des fonts"
    New-Item -ItemType Directory -Path $outputFolder -Force -OutVariable outputDirectory > $null
}
Write-Host "Téléchargement des fonts"
$url = "https://api.github.com/repos/ZephyrOff/pwsh-profile/contents/fonts"

$response = Invoke-RestMethod -Uri $url
foreach ($file in $response) {
    Write-Host "Téléchargement de "$file.name
    $fileName = $outputFolder+$file.name
    $downloadUrl = $file.download_url
    Invoke-WebRequest -Uri $downloadUrl -OutFile $filename
}

Write-Host "Installation des fonts"
$fonts = New-Object System.Drawing.Text.InstalledFontCollection
$installedFontFamilies = $fonts.Families | Select-Object -ExpandProperty Name
  
$currentDirectory = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
foreach ($FontItem in (Get-ChildItem -Path $currentDirectory | 
Where-Object {($_.Name -like '*.ttf') -or ($_.Name -like '*.otf') })) {  
    Add-Font -FontFile $FontItem.FullName  
}

Write-Host "Installation de oh-my-posh"
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
#Install-Module oh-my-posh -Scope CurrentUser
#Import-Module oh-my-posh
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
Import-Module -Name Terminal-Icons

Write-Host "Téléchargement de winfetch"
Invoke-WebRequest "https://raw.githubusercontent.com/lptstr/winfetch/master/winfetch.ps1" -OutFile $profile_folder"\apps\winfetch.ps1" -UseBasicParsing
Write-Host "Configuration de winfetch"
Invoke-WebRequest "https://raw.githubusercontent.com/ZephyrOff/pwsh-profile/main/winfetch/config.ps1" -OutFile $profile_folder"\apps\winfetch_conf.ps1" -UseBasicParsing

Write-Host "Téléchargement de la configuration du terminal"
$shell_json = $env:USERPROFILE+"\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Invoke-WebRequest "https://raw.githubusercontent.com/ZephyrOff/pwsh-profile/main/terminal/settings.json" -OutFile $shell_json -UseBasicParsing

Write-Host "========== FIN DE L'INSTALLATION =========="