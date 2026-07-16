param(
    [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"

function Write-Heading([string]$Text) {
    Write-Host ""
    Write-Host $Text -ForegroundColor Cyan
    Write-Host ("=" * $Text.Length) -ForegroundColor DarkCyan
}

function Escape-Xml([string]$Value) {
    return [System.Security.SecurityElement]::Escape($Value)
}

Write-Heading "PDK Fritzing Library Installer"

if (Get-Process -Name "Fritzing" -ErrorAction SilentlyContinue) {
    Write-Host "Fritzing is currently running. Close Fritzing and run the installer again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$payloadRoot = Join-Path $scriptRoot "payload"
$manifestPath = Join-Path $payloadRoot "manifest.json"

if (-not (Test-Path $manifestPath)) {
    throw "Installer payload is incomplete: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$documents = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$fritzingRoot = Join-Path $documents "Fritzing"
$binsRoot = Join-Path $fritzingRoot "bins"
$partsRoot = Join-Path $fritzingRoot "parts"
$userPartsRoot = Join-Path $partsRoot "user\pdk"
$userSvgRoot = Join-Path $partsRoot "svg\user"

$requiredFolders = @(
    $binsRoot,
    $userPartsRoot,
    (Join-Path $userSvgRoot "breadboard"),
    (Join-Path $userSvgRoot "icon"),
    (Join-Path $userSvgRoot "schematic"),
    (Join-Path $userSvgRoot "pcb")
)
foreach ($folder in $requiredFolders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $fritzingRoot "backup\pdk-library-$timestamp"
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

Write-Heading "Backing up existing PDK library files"

$filesToBackup = @(
    (Join-Path $binsRoot "PDK Access Control.fzb"),
    (Join-Path $binsRoot "PDK.png"),
    (Join-Path $binsRoot "PDK-mono.png")
)
foreach ($part in $manifest.parts) {
    $filesToBackup += Join-Path $userPartsRoot $part.fzpFilename
}
foreach ($sourceFolder in @("breadboard", "icon", "schematic", "pcb")) {
    $sourcePath = Join-Path $payloadRoot "parts\svg\user\$sourceFolder"
    Get-ChildItem -LiteralPath $sourcePath -File | ForEach-Object {
        $filesToBackup += Join-Path (Join-Path $userSvgRoot $sourceFolder) $_.Name
    }
}

foreach ($file in $filesToBackup | Select-Object -Unique) {
    if (Test-Path -LiteralPath $file) {
        $relative = $file.Substring($fritzingRoot.Length).TrimStart("\")
        $destination = Join-Path $backupRoot $relative
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        Copy-Item -LiteralPath $file -Destination $destination -Force
    }
}

Write-Heading "Removing superseded NexGen PDK parts"

$oldModuleIds = @(
    "PDK_Red_Max_Enclosure_Exact1to1_v2",
    "PDK_Red_Max_Enclosure_Fritzing72_v3",
    "Altronix_eFlow102NB_RedMaxExact_v3",
    "Altronix_eFlow102NB_RedMax_Fritzing72_v4",
    "PDK_R1E_v1",
    "PDK_R1E_RedMaxExact_v3",
    "PDK_R1E_RedMax_Fritzing72_v4",
    "PDK_R1E_ActualBoard_Fritzing72_v5",
    "PDK_R2E_v1",
    "PDK_R2E_RedMaxExact_v3",
    "PDK_R2E_RedMax_Fritzing72_v4",
    "PDK_R2E_ActualBoard_Fritzing72_v5",
    "PDK_R4E_v2",
    "PDK_R4E_RedMaxExact_v4",
    "PDK_R4E_RedMax_Fritzing72_v5",
    "PDK_Red_Aux8_v1",
    "PDK_Red_Aux8_RedMaxExact_v3",
    "PDK_Red_Aux8_RedMax_Fritzing72_v4",
    "PDK_WiMAC_Module_v1",
    "PDK_WiMAC_Module_Fritzing72_v2",
    "PDK_Red_Series_PoE_Module_v1",
    "PDK_Red_Series_PoE_Module_Fritzing72_v2"
)
foreach ($moduleId in $oldModuleIds) {
    $patterns = @(
        (Join-Path $partsRoot "user\part.$moduleId.fzp"),
        (Join-Path $partsRoot "user\$moduleId.fzp"),
        (Join-Path $partsRoot "user\pdk\*$moduleId*"),
        (Join-Path $partsRoot "svg\user\breadboard\*$moduleId*"),
        (Join-Path $partsRoot "svg\user\icon\*$moduleId*"),
        (Join-Path $partsRoot "svg\user\schematic\*$moduleId*"),
        (Join-Path $partsRoot "svg\user\pcb\*$moduleId*")
    )
    foreach ($pattern in $patterns) {
        Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Remove-Item -Force
    }
}

Write-Heading "Installing parts and SVG artwork"

Copy-Item -Path (Join-Path $payloadRoot "parts\user\pdk\*") -Destination $userPartsRoot -Force
foreach ($view in @("breadboard", "icon", "schematic", "pcb")) {
    $source = Join-Path $payloadRoot "parts\svg\user\$view\*"
    $destination = Join-Path $userSvgRoot $view
    Copy-Item -Path $source -Destination $destination -Force
}

Copy-Item -LiteralPath (Join-Path $payloadRoot "bins\PDK.png") -Destination (Join-Path $binsRoot "PDK.png") -Force
Copy-Item -LiteralPath (Join-Path $payloadRoot "bins\PDK-mono.png") -Destination (Join-Path $binsRoot "PDK-mono.png") -Force

Write-Heading "Creating the PDK parts bin"

$instanceXml = New-Object System.Collections.Generic.List[string]
$modelIndex = 1
foreach ($part in ($manifest.parts | Sort-Object order)) {
    $partPath = Join-Path $userPartsRoot $part.fzpFilename
    $escapedPath = Escape-Xml $partPath
    $escapedModule = Escape-Xml $part.moduleId
    $instanceXml.Add(@"
    <instance moduleIdRef="$escapedModule" modelIndex="$modelIndex" path="$escapedPath">
      <views>
        <iconView layer="icon">
          <geometry z="-1" x="-1" y="-1"/>
        </iconView>
      </views>
    </instance>
"@)
    $modelIndex++
}

$binXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<module fritzingVersion="1.0.7" icon="PDK.png">
  <title>PDK Access Control</title>
  <instances>
$($instanceXml -join "`n")
  </instances>
</module>
"@

$binPath = Join-Path $binsRoot "PDK Access Control.fzb"
[System.IO.File]::WriteAllText($binPath, $binXml, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Installed $($manifest.parts.Count) parts." -ForegroundColor Green
Write-Host "Bin: $binPath"
Write-Host "Backup: $backupRoot"

if (-not $NoLaunch) {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Fritzing\Fritzing.exe"),
        (Join-Path $env:ProgramFiles "Fritzing\Fritzing.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "Fritzing\Fritzing.exe")
    )

    $fritzingExe = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
    if (-not $fritzingExe) {
        $command = Get-Command "Fritzing.exe" -ErrorAction SilentlyContinue
        if ($command) { $fritzingExe = $command.Source }
    }

    if ($fritzingExe) {
        Write-Host "Starting Fritzing..." -ForegroundColor Cyan
        Start-Process -FilePath $fritzingExe
    } else {
        Write-Host "Fritzing was not found automatically. Start it normally; the PDK bin will load at startup." -ForegroundColor Yellow
    }
}

Write-Host ""
Read-Host "Press Enter to close"
