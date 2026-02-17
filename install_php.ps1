# Script to install PHP 8.2 manually
$ErrorActionPreference = "Stop"

$phpVersion = "8.2.14"
$zipName = "php-$phpVersion-Win32-vs16-x64.zip"
$url = "https://windows.php.net/downloads/releases/archives/$zipName"
$installDir = "C:\tools\php"

Write-Host "Creating installation directory..."
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Force -Path $installDir
}

Write-Host "Downloading PHP from $url..."
$zipPath = "$env:TEMP\$zipName"
Invoke-WebRequest -Uri $url -OutFile $zipPath

Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force

Write-Host "Configuring php.ini..."
$iniPath = "$installDir\php.ini"
Copy-Item "$installDir\php.ini-production" $iniPath

# Enable required extensions for Laravel
$content = Get-Content $iniPath
$content = $content -replace ';extension=curl', 'extension=curl'
$content = $content -replace ';extension=fileinfo', 'extension=fileinfo'
$content = $content -replace ';extension=mbstring', 'extension=mbstring'
$content = $content -replace ';extension=openssl', 'extension=openssl'
$content = $content -replace ';extension=pdo_mysql', 'extension=pdo_mysql'
$content = $content -replace ';extension_dir = "ext"', 'extension_dir = "ext"'
Set-Content -Path $iniPath -Value $content

Write-Host "Adding to PATH..."
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", "User")
    Write-Host "Added $installDir to User Path."
} else {
    Write-Host "$installDir already in Path."
}

Write-Host "PHP Setup Complete. Please restart your terminal."
php -v
