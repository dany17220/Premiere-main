# URL du fichier JSON de configuration
$ConfigUrl = "https://ressourcepack.software-koleka.fr/apps.json"

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Charger config depuis le web
$appsConfig = (Invoke-WebRequest -Uri $ConfigUrl -UseBasicParsing).Content | ConvertFrom-Json

function Show-Menu {
    param([string]$title, [array]$options)
    clear-host
    Write-Host "=== $title ==="
    for ($i = 0; $i -lt $options.Count; $i++) {
        Write-Host "[$i] $($options[$i])"
    }
    Write-Host "[Q] Quitter"
    return Read-Host "Choix"
}
# Charger config depuis le web
$appsConfig = (Invoke-WebRequest -Uri $ConfigUrl -UseBasicParsing).Content | ConvertFrom-Json
function Install-App {
    param([string]$name, [string]$url, [string]$silent)

    $tempPath = "$env:TEMP\$name.exe"
    Write-Host "⬇️ Téléchargement de $name..."
    Invoke-WebRequest -Uri $url -OutFile $tempPath

    Write-Host "⚙️ Installation silencieuse de $name..."
    Start-Process -FilePath $tempPath -ArgumentList $silent -Wait

    Write-Host "🧹 Suppression de l’installateur..."
    Remove-Item $tempPath -Force

    Write-Host "✅ $name installé avec succès !"
    time-sleep 5
}

# Menu principal
while ($true) {
    $categories = $appsConfig.PSObject.Properties.Name
    $catChoice = Show-Menu "Choisir une catégorie" $categories
    if ($catChoice -eq "Q") { break }
    if ($catChoice -match '^\d+$' -and $catChoice -lt $categories.Count) {
        $category = $categories[$catChoice]
        $apps = $appsConfig.$category
        $appNames = $apps | ForEach-Object { $_.name }

        $appChoice = Show-Menu "Choisir un logiciel dans $category" $appNames
        if ($appChoice -eq "Q") { continue }
        if ($appChoice -match '^\d+$' -and $appChoice -lt $apps.Count) {
            $app = $apps[$appChoice]
            Install-App -name $app.name -url $app.url -silent $app.silent
        }
    }
}
