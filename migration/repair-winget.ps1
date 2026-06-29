param(
  [switch]$CurrentUser
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Test-Command {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

if (Test-Command winget) {
  winget --version
  Write-Host 'winget is already available.' -ForegroundColor Green
  exit 0
}

Write-Host 'Trying to register App Installer for this user...'
try {
  Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
} catch {
  Write-Warning "App Installer registration failed: $($_.Exception.Message)"
}

if (Test-Command winget) {
  winget --version
  Write-Host 'winget is now available.' -ForegroundColor Green
  exit 0
}

Write-Host 'Bootstrapping winget with Microsoft.WinGet.Client from PowerShell Gallery...'
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null

if ($CurrentUser) {
  Repair-WinGetPackageManager
} else {
  Repair-WinGetPackageManager -AllUsers
}

if (-not (Test-Command winget)) {
  throw 'winget still is not available. Reopen PowerShell, or install/update App Installer from Microsoft Store manually.'
}

winget --version
Write-Host 'winget repair finished. Close and reopen PowerShell before rerunning setup-new-pc.ps1.' -ForegroundColor Green
