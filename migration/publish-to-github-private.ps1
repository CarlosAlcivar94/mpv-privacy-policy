param(
  [string]$Owner = 'CarlosAlcivar94',
  [switch]$Execute,
  [switch]$IncludePublicSite,
  [switch]$AllowSensitiveFiles,
  [switch]$MakeExistingReposPrivate
)

. "$PSScriptRoot\projects.ps1"

$ErrorActionPreference = 'Stop'

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
  '*.rar'
)

$ExcludedDirs = @(
  '.git',
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
  '__pycache__',
  '.venv'
)

function Get-ProjectFiles {
  param([string]$Root)

  $allFiles = Get-ChildItem -LiteralPath $Root -File -Recurse -Force -ErrorAction SilentlyContinue
  foreach ($file in $allFiles) {
    $relative = $file.FullName.Substring($Root.Length).TrimStart('\')
    $parts = $relative -split '[\\/]'
    if ($parts | Where-Object { $ExcludedDirs -contains $_ }) {
      continue
    }
    $file
  }
}

function Invoke-GitHubJson {
  param(
    [string]$Method,
    [string]$Uri,
    [object]$Body = $null
  )

  if (-not $env:GITHUB_TOKEN) {
    throw 'Set GITHUB_TOKEN before running with -Execute. Use a GitHub token with repo permission.'
  }

  $headers = @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
    Accept = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
  }

  if ($null -eq $Body) {
    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
  }

  $json = $Body | ConvertTo-Json -Depth 10
  return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -ContentType 'application/json' -Body $json
}

function Test-GitHubRepoExists {
  param([string]$Owner, [string]$Repo)
  try {
    Invoke-GitHubJson -Method Get -Uri "https://api.github.com/repos/$Owner/$Repo" | Out-Null
    return $true
  } catch {
    if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 404) {
      return $false
    }
    throw
  }
}

function Ensure-PrivateRepo {
  param([string]$Owner, [string]$Repo)

  if (Test-GitHubRepoExists -Owner $Owner -Repo $Repo) {
    Write-Host "GitHub repo exists: $Owner/$Repo"
    if ($MakeExistingReposPrivate) {
      Invoke-GitHubJson -Method Patch -Uri "https://api.github.com/repos/$Owner/$Repo" -Body @{ private = $true } | Out-Null
      Write-Host "Set private: $Owner/$Repo"
    }
    return
  }

  Invoke-GitHubJson -Method Post -Uri 'https://api.github.com/user/repos' -Body @{
    name = $Repo
    private = $true
    auto_init = $false
  } | Out-Null

  Write-Host "Created private repo: $Owner/$Repo"
}

function Ensure-GenericGitignore {
  param([string]$Path)

  $gitignorePath = Join-Path $Path '.gitignore'
  if (Test-Path -LiteralPath $gitignorePath) {
    return
  }

  $content = @'
# OS/editor
.DS_Store
Thumbs.db
.vscode/
.idea/

# Node/Angular
node_modules/
dist/
.angular/
.firebase/

# Flutter/Android
build/
.dart_tool/
.gradle/
android/key.properties
*.jks
*.keystore

# Env/secrets
.env
*.env
*service-account*.json
*firebase-adminsdk*.json
*secret*.json
*secrets*.json
*credential*.json
*credentials*.json

# Data/backups
*.db
*.sqlite
*.bak
*.zip
*.7z
*.rar
'@

  Set-Content -LiteralPath $gitignorePath -Value $content -Encoding UTF8
}

foreach ($project in $MigrationProjects) {
  if ($project.PublicSite -and -not $IncludePublicSite) {
    Write-Host "Skipping public site repo: $($project.Name)"
    continue
  }

  Write-Host ''
  Write-Host "=== $($project.Name) -> $Owner/$($project.GitHubRepo) ===" -ForegroundColor Cyan

  if (-not (Test-Path -LiteralPath $project.LocalPath)) {
    Write-Warning "Missing folder: $($project.LocalPath)"
    continue
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
  $sensitiveHits = $sensitiveHits | Select-Object -Unique

  if ($sensitiveHits -and -not $AllowSensitiveFiles) {
    Write-Warning 'Blocked by sensitive-file scan. Review these files or rerun with -AllowSensitiveFiles only after confirming .gitignore is correct:'
    $sensitiveHits | Select-Object -First 40 | ForEach-Object { Write-Host "  $_" }
    continue
  }

  if (-not $Execute) {
    Write-Host 'Dry run only. Add -Execute to create repos, commit and push.'
    Write-Host "Would create private repo: $Owner/$($project.GitHubRepo)"
    Write-Host "Would push from: $($project.LocalPath)"
    continue
  }

  Ensure-PrivateRepo -Owner $Owner -Repo $project.GitHubRepo

  if (-not (Test-Path -LiteralPath (Join-Path $project.LocalPath '.git'))) {
    git -C $project.LocalPath init -b main
    Ensure-GenericGitignore -Path $project.LocalPath
  }

  Ensure-GenericGitignore -Path $project.LocalPath

  git -C $project.LocalPath branch -M main
  git -C $project.LocalPath add -A
  git -C $project.LocalPath diff --cached --quiet
  if ($LASTEXITCODE -ne 0) {
    git -C $project.LocalPath commit -m 'Sync project for private GitHub backup'
  } else {
    Write-Host 'No staged changes to commit.'
  }

  $remoteUrl = "https://github.com/$Owner/$($project.GitHubRepo).git"
  $existingRemote = git -C $project.LocalPath remote
  if ($existingRemote -contains 'github-private') {
    git -C $project.LocalPath remote set-url github-private $remoteUrl
  } else {
    git -C $project.LocalPath remote add github-private $remoteUrl
  }

  git -C $project.LocalPath push -u github-private main
}
