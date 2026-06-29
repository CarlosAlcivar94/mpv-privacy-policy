param(
  [string]$Owner = 'CarlosAlcivar94',
  [switch]$Execute,
  [switch]$IncludePublicSite,
  [switch]$AllowSensitiveFiles,
  [switch]$AutoExcludeSensitiveFiles,
  [switch]$MakeExistingReposPrivate,
  [switch]$ContinueOnError
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

  $pending = [System.Collections.Generic.Stack[string]]::new()
  $pending.Push($Root)

  while ($pending.Count -gt 0) {
    $current = $pending.Pop()
    foreach ($item in Get-ChildItem -LiteralPath $current -Force -ErrorAction SilentlyContinue) {
      if ($item.PSIsContainer) {
        if ($ExcludedDirs -notcontains $item.Name) {
          $pending.Push($item.FullName)
        }
        continue
      }

      $item
    }
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

function Get-RelativeGitPath {
  param(
    [string]$Root,
    [string]$FullName
  )

  return $FullName.Substring($Root.Length).TrimStart('\') -replace '\\', '/'
}

function Ensure-GitRepository {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath (Join-Path $Path '.git'))) {
    git -C $Path init -b main
  }

  Ensure-GenericGitignore -Path $Path
  git -C $Path branch -M main
}

function Add-InfoExclude {
  param(
    [string]$Path,
    [string[]]$RelativePaths
  )

  $excludePath = Join-Path $Path '.git\info\exclude'
  $existing = @()
  if (Test-Path -LiteralPath $excludePath) {
    $existing = Get-Content -LiteralPath $excludePath
  }

  $newEntries = foreach ($relativePath in $RelativePaths) {
    "/$relativePath"
  }

  $toAdd = $newEntries | Where-Object { $existing -notcontains $_ }
  if ($toAdd) {
    Add-Content -LiteralPath $excludePath -Value $toAdd
    Write-Host "Added $($toAdd.Count) sensitive path(s) to .git/info/exclude"
  }
}

function Get-TrackedSensitiveFiles {
  param(
    [string]$Path,
    [string[]]$RelativePaths
  )

  foreach ($relativePath in $RelativePaths) {
    git -C $Path ls-files --error-unmatch $relativePath *> $null
    if ($LASTEXITCODE -eq 0) {
      $relativePath
    }
  }
}

function Publish-Project {
  param([object]$Project)

  Write-Host ''
  Write-Host "=== $($Project.Name) -> $Owner/$($Project.GitHubRepo) ===" -ForegroundColor Cyan

  if (-not (Test-Path -LiteralPath $Project.LocalPath)) {
    Write-Warning "Missing folder: $($Project.LocalPath)"
    return
  }

  if ($Execute -or $AutoExcludeSensitiveFiles) {
    Ensure-GitRepository -Path $Project.LocalPath
  }

  $projectFiles = Get-ProjectFiles -Root $Project.LocalPath
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
    $relativeSensitiveHits = $sensitiveHits | ForEach-Object { Get-RelativeGitPath -Root $Project.LocalPath -FullName $_ }

    if ($AutoExcludeSensitiveFiles) {
      Add-InfoExclude -Path $Project.LocalPath -RelativePaths $relativeSensitiveHits
      $trackedSensitive = @(Get-TrackedSensitiveFiles -Path $Project.LocalPath -RelativePaths $relativeSensitiveHits)
      if ($trackedSensitive) {
        Write-Warning 'Blocked: these sensitive files are already tracked by Git and must be removed from history/index manually before migration:'
        $trackedSensitive | Select-Object -First 40 | ForEach-Object { Write-Host "  $_" }
        return
      }
      Write-Host 'Sensitive files are excluded locally and are not tracked. Continuing.'
    } else {
      Write-Warning 'Blocked by sensitive-file scan. Rerun with -AutoExcludeSensitiveFiles to ignore untracked secrets, or clean them manually:'
      $sensitiveHits | Select-Object -First 40 | ForEach-Object { Write-Host "  $_" }
      return
    }
  }

  if (-not $Execute) {
    Write-Host 'Dry run only. Add -Execute to create repos, commit and push.'
    Write-Host "Would create private repo: $Owner/$($Project.GitHubRepo)"
    Write-Host "Would push from: $($Project.LocalPath)"
    return
  }

  Ensure-PrivateRepo -Owner $Owner -Repo $Project.GitHubRepo

  Ensure-GitRepository -Path $Project.LocalPath
  git -C $Project.LocalPath add -A
  git -C $Project.LocalPath diff --cached --quiet
  if ($LASTEXITCODE -ne 0) {
    git -C $Project.LocalPath commit -m 'Sync project for private GitHub backup'
  } else {
    Write-Host 'No staged changes to commit.'
  }

  $remoteUrl = "https://github.com/$Owner/$($Project.GitHubRepo).git"
  $existingRemote = git -C $Project.LocalPath remote
  if ($existingRemote -contains 'github-private') {
    git -C $Project.LocalPath remote set-url github-private $remoteUrl
  } else {
    git -C $Project.LocalPath remote add github-private $remoteUrl
  }

  git -C $Project.LocalPath push -u github-private main
}

foreach ($project in $MigrationProjects) {
  if ($project.PublicSite -and -not $IncludePublicSite) {
    Write-Host "Skipping public site repo: $($project.Name)"
    continue
  }

  try {
    Publish-Project -Project $project
  } catch {
    Write-Error "Failed publishing $($project.Name): $($_.Exception.Message)"
    if (-not $ContinueOnError) {
      throw
    }
  }
}
