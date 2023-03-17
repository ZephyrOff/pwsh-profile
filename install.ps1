Write-Host "========== DEBUT DE L'INSTALLATION =========="
$profile_folder = Split-Path -parent $profile
Write-Host "Création du dossier apps"
$app_folder = $profile_folder+"\apps"
if (!(Test-Path -Path $app_folder)) {
	New-Item -ItemType Directory -Path $app_folder -Force
}

Write-Host "Création du dossier wallpapers"
$wallpaper_folder = $profile_folder+"\wallpapers"
if (!(Test-Path -Path $wallpaper_folder)) {
	New-Item -ItemType Directory -Path $wallpaper_folder -Force
}
Write-Host "Téléchargement du fond"
Invoke-WebRequest "https://raw.githubusercontent.com/ZephyrOff/pwsh-profile/main/terminal/background.jpg" -OutFile $wallpaper_folder+"\background.jpg" -UseBasicParsing

Write-Host "Téléchargement des fonts"
$url = "https://api.github.com/repos/ZephyrOff/pwsh-profile/contents/fonts"
$outputFolder = $env:USERPROFILE+"\AppData\Local\Microsoft\Windows\Fonts"
$response = Invoke-RestMethod -Uri $url

foreach ($file in $response) {
    $fileName = $file.name
    $downloadUrl = $file.download_url
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFolder+"/"+$fileName
}
#$pfc = New-Object -ComObject Shell.Application
#$pfc.ShellExecute("control.exe", "fonts", "", "open", 1)

Write-Host "Installation de oh-my-posh"
Install-Module oh-my-posh -Scope CurrentUser
Import-Module oh-my-posh
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
Import-Module -Name Terminal-Icons

Write-Host "Téléchargement de winfetch"
Invoke-WebRequest "https://raw.githubusercontent.com/lptstr/winfetch/master/winfetch.ps1" -OutFile $profile_folder+"\apps\winfetch.ps1" -UseBasicParsing
Write-Host "Configuration de winfetch"
Invoke-WebRequest "https://raw.githubusercontent.com/ZephyrOff/pwsh-profile/main/winfetch/config.ps1" -OutFile $profile_folder+"\apps\winfetch_conf.ps1" -UseBasicParsing

Write-Host "Téléchargement de la configuration du terminal"
$shell_json = $env:USERPROFILE+"\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Invoke-WebRequest "https://raw.githubusercontent.com/ZephyrOff/pwsh-profile/main/terminal/settings.json" -OutFile $shell_json -UseBasicParsing

Write-Host "========== FIN DE L'INSTALLATION =========="