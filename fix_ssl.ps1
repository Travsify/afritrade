# Script to fix PHP SSL issues
$ErrorActionPreference = "Stop"
$phpDir = "C:\tools\php"
$sslDir = "$phpDir\extras\ssl"
$cacertPath = "$sslDir\cacert.pem"
$iniPath = "$phpDir\php.ini"

# 1. Create directory
if (!(Test-Path $sslDir)) {
    New-Item -ItemType Directory -Force -Path $sslDir | Out-Null
    Write-Host "Created directory: $sslDir"
}

# 2. Download cacert.pem
Write-Host "Downloading cacert.pem..."
Invoke-WebRequest -Uri "https://curl.se/ca/cacert.pem" -OutFile $cacertPath
Write-Host "Downloaded to: $cacertPath"

# 3. Update php.ini
Write-Host "Updating php.ini..."
$content = Get-Content $iniPath

# Uncomment and set curl.cainfo
if ($content -match ";curl.cainfo =") {
    $content = $content -replace ";curl.cainfo =", "curl.cainfo = `"$cacertPath`""
}
elseif ($content -notmatch "curl.cainfo =") {
    $content += "`ncurl.cainfo = `"$cacertPath`""
}

# Uncomment and set openssl.cafile
if ($content -match ";openssl.cafile=") {
    $content = $content -replace ";openssl.cafile=", "openssl.cafile=`"$cacertPath`""
}
elseif ($content -notmatch "openssl.cafile=") {
    $content += "`nopenssl.cafile=`"$cacertPath`""
}

Set-Content -Path $iniPath -Value $content
Write-Host "Updated php.ini with SSL paths."

# 4. Verify
Write-Host "Verifying configuration..."
C:\tools\php\php.exe -r "print_r(openssl_get_cert_locations());"
