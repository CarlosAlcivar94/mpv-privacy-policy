param(
  [string]$Owner = 'CarlosAlcivar94',
  [string]$Destination = 'C:\Dev',
  [string]$FlutterSdkPath = 'C:\development\flutter',
  [string]$GitHubToken = $env:GITHUB_TOKEN,
  [switch]$IncludePublicSite,
  [switch]$SkipToolInstall,
  [switch]$SkipClone,
  [switch]$SkipDependencies,
  [switch]$AcceptAndroidLicenses
)

. "$PSScriptRoot\projects.ps1"

$ErrorActionPreference = 'Stop'

function Test-Command {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-PythonRunner {
  $candidates = @(
    [pscustomobject]@{ Command = 'py'; Args = @('-3') },
    [pscustomobject]@{ Command = 'python'; Args = @() },
    [pscustomobject]@{ Command = 'python3'; Args = @() }
  )

  foreach ($candidate in $candidates) {
    if (-not (Test-Command $candidate.Command)) {
      continue
    }

    try {
      $version = & $candidate.Command @($candidate.Args) --version 2>&1
      if ($LASTEXITCODE -eq 0 -and ($version -join ' ') -match 'Python 3') {
        return $candidate
      }
    } catch {
      continue
    }
  }

  return $null
}

function Assert-WingetAvailable {
  if (Test-Command winget) {
    return
  }

  Write-Warning 'winget is not available in this terminal. Trying to register App Installer for this user...'
  try {
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
  } catch {
    Write-Warning "Could not register App Installer automatically: $($_.Exception.Message)"
  }

  if (Test-Command winget) {
    Write-Host 'winget is now available after App Installer registration.'
    return
  }

  $message = @'
winget is not available.

Fix it with one of these options, then close and reopen PowerShell:

1. Open Microsoft Store, search "App Installer", then install or update it.
2. If Microsoft Store is not usable, run this from an elevated PowerShell:
   powershell -ExecutionPolicy Bypass -File C:\Dev\mpv-privacy-policy\migration\repair-winget.ps1
3. If you install all tools manually, rerun setup with -SkipToolInstall.

Manual tools expected by this project set:
Git, GitHub CLI, Node.js LTS, Python 3.12, JDK 17, PHP 8.3, Composer, Android Studio, VS Code, Flutter.
'@

  throw $message
}

function Install-WingetPackage {
  param(
    [string]$Id,
    [string]$Name
  )

  Assert-WingetAvailable

  Write-Host "Installing/checking $Name ($Id)"
  winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    Write-Warning "winget could not install $Id. It may already be installed or may require manual installation."
  }
}

function Add-UserPath {
  param([string]$PathToAdd)

  if (-not (Test-Path -LiteralPath $PathToAdd)) {
    return
  }

  $current = [Environment]::GetEnvironmentVariable('Path', 'User')
  $parts = $current -split ';' | Where-Object { $_ }
  if ($parts -notcontains $PathToAdd) {
    $newPath = ($parts + $PathToAdd) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    $env:Path = "$env:Path;$PathToAdd"
    Write-Host "Added to user PATH: $PathToAdd"
  }
}

function Ensure-BaseTools {
  if ($SkipToolInstall) {
    Write-Host 'Skipping tool installation.'
    return
  }

  Install-WingetPackage -Id 'Git.Git' -Name 'Git'
  Install-WingetPackage -Id 'GitHub.cli' -Name 'GitHub CLI'
  Install-WingetPackage -Id 'OpenJS.NodeJS.LTS' -Name 'Node.js LTS'
  Install-WingetPackage -Id 'Python.Python.3.12' -Name 'Python 3.12'
  Install-WingetPackage -Id 'EclipseAdoptium.Temurin.17.JDK' -Name 'Temurin JDK 17'
  Install-WingetPackage -Id 'Composer.Composer' -Name 'Composer'
  Install-WingetPackage -Id 'PHP.PHP.8.3' -Name 'PHP'
  Install-WingetPackage -Id 'Google.AndroidStudio' -Name 'Android Studio'
  Install-WingetPackage -Id 'Microsoft.VisualStudioCode' -Name 'Visual Studio Code'
}

function Ensure-Flutter {
  $flutterBat = Join-Path $FlutterSdkPath 'bin\flutter.bat'

  if (-not (Test-Path -LiteralPath $flutterBat)) {
    if (-not (Test-Command git)) {
      throw 'Git is required to install Flutter. Run again after Git is available.'
    }

    $parent = Split-Path -Parent $FlutterSdkPath
    if (-not (Test-Path -LiteralPath $parent)) {
      New-Item -ItemType Directory -Path $parent | Out-Null
    }

    Write-Host "Cloning Flutter stable into $FlutterSdkPath"
    git clone https://github.com/flutter/flutter.git -b stable $FlutterSdkPath
  }

  Add-UserPath -PathToAdd (Join-Path $FlutterSdkPath 'bin')

  & $flutterBat --version
  & $flutterBat config --enable-android
  & $flutterBat precache --android

  if ($AcceptAndroidLicenses) {
    cmd /c "echo y| `"$flutterBat`" doctor --android-licenses"
  }

  & $flutterBat doctor
}

function Authenticate-GitHub {
  if (-not $GitHubToken) {
    Write-Warning 'No GitHub token provided. Private clone may prompt for credentials via Git Credential Manager.'
    return
  }

  $env:GITHUB_TOKEN = $GitHubToken

  if (Test-Command gh) {
    Write-Host 'Authenticating GitHub CLI with provided token.'
    $GitHubToken | gh auth login --with-token
    gh auth status
  }
}

function Clone-Project {
  param([object]$Project)

  $folderName = if ($Project.CloneFolder) { $Project.CloneFolder } else { $Project.GitHubRepo }
  $targetPath = Join-Path $Destination $folderName
  $repoUrl = "https://github.com/$Owner/$($Project.GitHubRepo).git"

  if (Test-Path -LiteralPath $targetPath) {
    Write-Host "Already cloned: $targetPath"
    return $targetPath
  }

  if (-not (Test-Path -LiteralPath $Destination)) {
    New-Item -ItemType Directory -Path $Destination | Out-Null
  }

  Write-Host "Cloning $repoUrl -> $targetPath"

  if ($GitHubToken) {
    git -c "http.extraheader=AUTHORIZATION: bearer $GitHubToken" clone $repoUrl $targetPath
  } else {
    git clone $repoUrl $targetPath
  }

  return $targetPath
}

function Invoke-InProject {
  param(
    [string]$Path,
    [scriptblock]$Script
  )

  Push-Location $Path
  try {
    & $Script
  } finally {
    Pop-Location
  }
}

function Install-NodeDeps {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath (Join-Path $Path 'package.json'))) {
    return
  }

  if (-not (Test-Command npm)) {
    Write-Warning "npm is not available. Skipping Node dependencies for $Path"
    return
  }

  Invoke-InProject -Path $Path -Script {
    if (Test-Path -LiteralPath 'package-lock.json') {
      npm ci --no-audit --no-fund
    } else {
      npm install --no-audit --no-fund
    }
  }
}

function Install-FlutterDeps {
  param([string]$Path)
  $flutterBat = Join-Path $FlutterSdkPath 'bin\flutter.bat'
  if ((Test-Path -LiteralPath (Join-Path $Path 'pubspec.yaml')) -and (Test-Path -LiteralPath $flutterBat)) {
    Invoke-InProject -Path $Path -Script {
      & $flutterBat pub get
    }
  }
}

function Install-PythonDeps {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath (Join-Path $Path 'requirements.txt'))) {
    return
  }

  $python = Get-PythonRunner
  if (-not $python) {
    Write-Warning "Python 3 is not available. Skipping Python dependencies for $Path"
    return
  }

  Push-Location $Path
  try {
    & $python.Command @($python.Args) -m venv .venv
    $venvPython = Join-Path $Path '.venv\Scripts\python.exe'
    if (-not (Test-Path -LiteralPath $venvPython)) {
      Write-Warning "Python virtual environment was not created correctly at $Path\.venv"
      return
    }

    & $venvPython -m pip install --upgrade pip
    & $venvPython -m pip install -r requirements.txt
  } finally {
    Pop-Location
  }
}

function Install-PhpDeps {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath (Join-Path $Path 'composer.json'))) {
    return
  }

  if (-not (Test-Command composer)) {
    Write-Warning "Composer is not available. Skipping PHP dependencies for $Path"
    return
  }

  Invoke-InProject -Path $Path -Script {
    composer install
  }
}

function Install-ProjectDeps {
  param(
    [object]$Project,
    [string]$Path
  )

  Write-Host "Installing dependencies for $($Project.Name) [$($Project.InstallProfile)]" -ForegroundColor Cyan

  switch ($Project.InstallProfile) {
    'flutter-firebase' {
      Install-FlutterDeps -Path $Path
      if (Test-Path -LiteralPath (Join-Path $Path 'package.json')) {
        Install-NodeDeps -Path $Path
      }
    }
    'flutter-node-firebase' {
      Install-FlutterDeps -Path $Path
      Install-NodeDeps -Path $Path
    }
    'turnero-node' {
      if (-not (Test-Command npm)) {
        Write-Warning "npm is not available. Skipping Turnero dependencies for $Path"
        return
      }

      Invoke-InProject -Path $Path -Script {
        npm run install:frontend
        npm run install:backend
      }
    }
    'node-firebase' {
      Install-NodeDeps -Path $Path
    }
    'python' {
      Install-PythonDeps -Path $Path
    }
    'php-node' {
      Install-PhpDeps -Path $Path
      Install-NodeDeps -Path $Path
    }
    'excel-vba' {
      Write-Warning 'Excel/VBA projects need Microsoft Office with VBA enabled. This script only clones the repo; Office installation/licensing is manual.'
    }
    'static-site' {
      Write-Host 'Static site: no dependency install required.'
    }
    default {
      Write-Warning "Unknown install profile: $($Project.InstallProfile)"
    }
  }
}

Ensure-BaseTools

if (-not $SkipToolInstall) {
  # New PATH from winget installers may require a fresh terminal. Try common paths immediately.
  $commonGit = 'C:\Program Files\Git\cmd'
  $commonNode = 'C:\Program Files\nodejs'
  Add-UserPath -PathToAdd $commonGit
  Add-UserPath -PathToAdd $commonNode
}

Ensure-Flutter
Authenticate-GitHub

$selectedProjects = foreach ($project in $MigrationProjects) {
  if ($project.PublicSite -and -not $IncludePublicSite) {
    continue
  }
  $project
}

$projectPaths = @{}

foreach ($project in $selectedProjects) {
  if ($SkipClone) {
    $folderName = if ($project.CloneFolder) { $project.CloneFolder } else { $project.GitHubRepo }
    $projectPaths[$project.Name] = Join-Path $Destination $folderName
  } else {
    $projectPaths[$project.Name] = Clone-Project -Project $project
  }
}

if (-not $SkipDependencies) {
  foreach ($project in $selectedProjects) {
    $path = $projectPaths[$project.Name]
    if (Test-Path -LiteralPath $path) {
      try {
        Install-ProjectDeps -Project $project -Path $path
      } catch {
        Write-Warning "Dependency installation failed for $($project.Name): $($_.Exception.Message)"
      }
    } else {
      Write-Warning "Cannot install dependencies. Missing clone path: $path"
    }
  }
}

Write-Host ''
Write-Host 'Setup finished. Review flutter doctor output, Android Studio SDK setup, secrets/env files, and project-specific README files.' -ForegroundColor Green
