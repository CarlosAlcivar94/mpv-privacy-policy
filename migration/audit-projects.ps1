param(
  [switch]$IncludePublicSite
)

. "$PSScriptRoot\projects.ps1"

$SensitivePatterns = @(
  '.env',
  '*.env',
  'google-services.json',
  'GoogleService-Info.plist',
  'key.properties',
  '*.jks',
  '*.keystore',
  '*.p12',
  '*.pem',
  '*service-account*.json',
  '*firebase-adminsdk*.json',
  '*credential*.json',
  '*credentials*.json',
  '*secret*.json',
  '*secrets*.json',
  '*.sqlite',
  '*.db',
  '*.bak',
  '*.zip',
  '*.7z',
  '*.rar',
  '*.xlsm',
  '*.xlsx'
)

$LargeOrGeneratedDirs = @(
  'node_modules',
  'build',
  'dist',
  '.dart_tool',
  '.gradle',
  '.angular',
  '.firebase',
  'coverage',
  '.next',
  '.nuxt',
  'vendor',
  '__pycache__'
)

function Get-ProjectFiles {
  param([string]$Root)

  $allFiles = Get-ChildItem -LiteralPath $Root -File -Recurse -Force -ErrorAction SilentlyContinue
  foreach ($file in $allFiles) {
    $relative = $file.FullName.Substring($Root.Length).TrimStart('\')
    $parts = $relative -split '[\\/]'
    if ($parts | Where-Object { $LargeOrGeneratedDirs -contains $_ }) {
      continue
    }
    $file
  }
}

foreach ($project in $MigrationProjects) {
  if ($project.PublicSite -and -not $IncludePublicSite) {
    continue
  }

  Write-Host ''
  Write-Host "=== $($project.Name) ===" -ForegroundColor Cyan
  Write-Host "Path: $($project.LocalPath)"
  Write-Host "Target repo: $($project.GitHubRepo)"
  Write-Host "Notes: $($project.Notes)"

  if (-not (Test-Path -LiteralPath $project.LocalPath)) {
    Write-Warning 'Missing folder.'
    continue
  }

  $gitDir = Join-Path $project.LocalPath '.git'
  if (Test-Path -LiteralPath $gitDir) {
    Write-Host 'Git: yes'
    try {
      git -C $project.LocalPath status --short --branch
      git -C $project.LocalPath remote -v
    } catch {
      Write-Warning "Git inspection failed: $($_.Exception.Message)"
    }
  } else {
    Write-Host 'Git: no'
  }

  $generatedDirs = foreach ($dirName in $LargeOrGeneratedDirs) {
    Get-ChildItem -LiteralPath $project.LocalPath -Directory -Recurse -Force -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -ieq $dirName } |
      Select-Object -ExpandProperty FullName
  }

  if ($generatedDirs) {
    Write-Host 'Generated/heavy folders to ignore:' -ForegroundColor Yellow
    $generatedDirs | Select-Object -First 30 | ForEach-Object { Write-Host "  $_" }
    if ($generatedDirs.Count -gt 30) {
      Write-Host "  ... and $($generatedDirs.Count - 30) more"
    }
  }

  $projectFiles = Get-ProjectFiles -Root $project.LocalPath
  $sensitiveHits = foreach ($file in $projectFiles) {
    foreach ($pattern in $SensitivePatterns) {
      if ($file.Name -like $pattern) {
        $file.FullName
        break
      }
    }
  }

  if ($sensitiveHits) {
    Write-Host 'Review before pushing:' -ForegroundColor Red
    $sensitiveHits | Select-Object -Unique | Select-Object -First 80 | ForEach-Object { Write-Host "  $_" }
    if (($sensitiveHits | Select-Object -Unique).Count -gt 80) {
      Write-Host '  ... more files omitted'
    }
  } else {
    Write-Host 'Sensitive-file scan: no obvious hits'
  }
}
