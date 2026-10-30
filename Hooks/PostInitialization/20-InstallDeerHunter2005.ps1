#Requires -Modules Logging
#Requires -Modules Hooks

# Deer Hunter 2005 is retail software with no public download. Use an existing install in
# /config/Server, or set DH2005_ARCHIVE_URL to a zip of the game folder (DH2005.exe at the zip root,
# or in a single top-level folder), e.g. a LANCommander archive.

Invoke-Hook "PreInstallDeerHunter2005"

$exe = Join-Path $Env:SERVER_DIR 'DH2005.exe'

if (Test-Path -Path $exe) {
    Write-Log "Deer Hunter 2005 found in $Env:SERVER_DIR"
} elseif ($Env:DH2005_ARCHIVE_URL) {
    Write-Log "Downloading Deer Hunter 2005 from $Env:DH2005_ARCHIVE_URL"

    $zip     = '/tmp/dh2005.zip'
    $extract = '/tmp/dh2005'

    curl -fL --retry 3 --output $zip "$Env:DH2005_ARCHIVE_URL"
    if ($LASTEXITCODE -ne 0) { throw "Download failed: $Env:DH2005_ARCHIVE_URL" }

    Remove-Item -Recurse -Force -Path $extract -ErrorAction SilentlyContinue
    unzip -q -o $zip -d $extract
    if ($LASTEXITCODE -ne 0) { throw "Could not extract $zip" }

    # Accept the game at the zip root or inside one top-level folder
    $root = Get-ChildItem -Path $extract -Filter 'DH2005.exe' -Recurse -File -Depth 1 |
        Select-Object -First 1 -ExpandProperty DirectoryName
    if (-not $root) { throw "DH2005.exe not found in $Env:DH2005_ARCHIVE_URL" }

    New-Item -ItemType Directory -Path $Env:SERVER_DIR -Force | Out-Null
    Move-Item -Force -Path (Join-Path $root '*') -Destination $Env:SERVER_DIR
    chown -R "$($Env:UID):$($Env:GID)" $Env:SERVER_DIR

    Remove-Item -Recurse -Force -Path $zip, $extract

    Write-Log "Deer Hunter 2005 installed"
} else {
    Write-Log -Level Error "DH2005.exe not found in $Env:SERVER_DIR. Copy a Deer Hunter 2005 v1.2 install there or set DH2005_ARCHIVE_URL."
}

Invoke-Hook "PostInstallDeerHunter2005"

Set-Location $Env:SERVER_ROOT
