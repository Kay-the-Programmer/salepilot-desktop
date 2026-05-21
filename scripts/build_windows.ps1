# Build SalePilot POS for Windows.
#
# Usage (from the salepilot_desktop folder):
#   .\scripts\build_windows.ps1                  # build only
#   .\scripts\build_windows.ps1 -Msix            # build + package MSIX
#   .\scripts\build_windows.ps1 -Msix -SkipTests # skip analyze + tests
#
# Prerequisites:
#   - Flutter 3.44+ on PATH
#   - Visual Studio 2022 with the "Desktop development with C++" workload
#   - For -Msix on machines that haven't enabled sideloading: turn on
#     Settings → Privacy & Security → For developers → Developer Mode.

[CmdletBinding()]
param(
    [switch]$Msix,
    [switch]$SkipTests,
    [string]$ApiBaseUrl = ''
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
Set-Location $projectRoot

Write-Host "==> flutter pub get" -ForegroundColor Cyan
flutter pub get

if (-not $SkipTests) {
    Write-Host "==> flutter analyze" -ForegroundColor Cyan
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw "analyze failed" }

    Write-Host "==> flutter test" -ForegroundColor Cyan
    flutter test
    if ($LASTEXITCODE -ne 0) { throw "tests failed" }
}

$buildArgs = @('build', 'windows', '--release')
if ($ApiBaseUrl) {
    $buildArgs += "--dart-define=API_BASE_URL=$ApiBaseUrl"
}

Write-Host "==> flutter $($buildArgs -join ' ')" -ForegroundColor Cyan
& flutter @buildArgs
if ($LASTEXITCODE -ne 0) { throw "windows build failed" }

$exe = Join-Path $projectRoot 'build\windows\x64\runner\Release\salepilot_desktop.exe'
if (Test-Path $exe) {
    Write-Host ""
    Write-Host "✓ Built: $exe" -ForegroundColor Green
    $sizeMb = [math]::Round((Get-Item $exe).Length / 1MB, 1)
    Write-Host "  Size: $sizeMb MB" -ForegroundColor Green
}

if ($Msix) {
    Write-Host "==> dart run msix:create" -ForegroundColor Cyan
    dart run msix:create
    if ($LASTEXITCODE -ne 0) { throw "MSIX packaging failed" }

    $msix = Join-Path $projectRoot 'build\msix\SalePilotPOS.msix'
    if (Test-Path $msix) {
        Write-Host ""
        Write-Host "✓ MSIX: $msix" -ForegroundColor Green
        Write-Host "  Install: double-click the .msix, or:" -ForegroundColor Gray
        Write-Host "    Add-AppxPackage -Path '$msix'" -ForegroundColor Gray
    }
}
