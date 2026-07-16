$ErrorActionPreference = "Stop"

if (Get-Process -Name "Fritzing" -ErrorAction SilentlyContinue) {
    Write-Host "Close Fritzing before uninstalling the PDK library." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$manifest = Get-Content -LiteralPath (Join-Path $scriptRoot "payload\manifest.json") -Raw | ConvertFrom-Json
$documents = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$fritzingRoot = Join-Path $documents "Fritzing"
$binsRoot = Join-Path $fritzingRoot "bins"
$partsRoot = Join-Path $fritzingRoot "parts"
$userPartsRoot = Join-Path $partsRoot "user\pdk"
$userSvgRoot = Join-Path $partsRoot "svg\user"

foreach ($part in $manifest.parts) {
    Remove-Item -LiteralPath (Join-Path $userPartsRoot $part.fzpFilename) -Force -ErrorAction SilentlyContinue
}

foreach ($view in @("breadboard", "icon", "schematic", "pcb")) {
    $payloadView = Join-Path $scriptRoot "payload\parts\svg\user\$view"
    Get-ChildItem -LiteralPath $payloadView -File | ForEach-Object {
        Remove-Item -LiteralPath (Join-Path (Join-Path $userSvgRoot $view) $_.Name) -Force -ErrorAction SilentlyContinue
    }
}

Remove-Item -LiteralPath (Join-Path $binsRoot "PDK Access Control.fzb") -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $binsRoot "PDK.png") -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $binsRoot "PDK-mono.png") -Force -ErrorAction SilentlyContinue

Write-Host "PDK Fritzing Library removed." -ForegroundColor Green
Read-Host "Press Enter to close"
