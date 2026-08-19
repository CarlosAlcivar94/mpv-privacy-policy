param(
  [string]$Owner = 'CarlosAlcivar94',
  [switch]$Online
)

. "$PSScriptRoot\projects.ps1"

$ErrorActionPreference = 'Continue'

function ConvertTo-GitSafePath {
  param([string]$Path)
  return ($Path -replace '\\', '/')
}

function Invoke-SafeGit {
  param(
    [string]$RepositoryPath,
    [string[]]$Arguments
  )

  $safePath = ConvertTo-GitSafePath -Path $RepositoryPath
  & git -c "safe.directory=$safePath" -C $RepositoryPath @Arguments
}

Write-Host 'KA94 pre-reset audit'
Write-Host "Online remote check: $Online"
Write-Host ''

foreach ($project in $MigrationProjects) {
  Write-Host "=== $($project.Name) ==="
  Write-Host "Local path: $($project.LocalPath)"
  Write-Host "Expected GitHub: https://github.com/$Owner/$($project.GitHubRepo).git"

  if (-not (Test-Path -LiteralPath $project.LocalPath)) {
    Write-Warning 'Local path does not exist.'
    Write-Host ''
    continue
  }

  if (-not (Test-Path -LiteralPath (Join-Path $project.LocalPath '.git'))) {
    Write-Warning 'Local path is not a Git repository.'
    Write-Host ''
    continue
  }

  $branch = (Invoke-SafeGit -RepositoryPath $project.LocalPath -Arguments @('branch', '--show-current') 2>$null)
  $head = (Invoke-SafeGit -RepositoryPath $project.LocalPath -Arguments @('rev-parse', 'HEAD') 2>$null)
  $statusLines = @(Invoke-SafeGit -RepositoryPath $project.LocalPath -Arguments @('status', '--short') 2>$null)
  $dirtyCount = $statusLines.Count
  $memoryCandidates = @(
    'CODEX.md',
    'CODEX.MD',
    'codex.md',
    'PLAN.md',
    'PLAN.MD',
    'plan.md',
    'README.md',
    'codes.md',
    'CLAUDE.md',
    'RECOVERY.md',
    'DEPENDENCIAS.md',
    'MANUAL_REINSTALACION_UBUNTU.md',
    'info/codex.md',
    'info/plan.md',
    'info/manual-instalacion.md',
    'docs/dependencias.md',
    'docs/restauracion-ubuntu.md',
    'docs/ubuntu_recovery_manual.md'
  )
  $seenMemoryPaths = @{}
  $memoryFiles = @()
  foreach ($candidate in $memoryCandidates) {
    $candidatePath = Join-Path $project.LocalPath $candidate
    $item = Get-Item -LiteralPath $candidatePath -ErrorAction SilentlyContinue
    if (-not $item) {
      continue
    }

    $key = $item.FullName.ToLowerInvariant()
    if ($seenMemoryPaths.ContainsKey($key)) {
      continue
    }

    $seenMemoryPaths[$key] = $true
    $memoryFiles += $candidate
  }

  Write-Host "Branch: $branch"
  Write-Host "Local HEAD: $head"
  Write-Host "Changed/untracked files: $dirtyCount"
  if ($dirtyCount -gt 0) {
    $statusLines | Select-Object -First 25 | ForEach-Object { Write-Host "  $_" }
    if ($dirtyCount -gt 25) {
      Write-Host "  ... plus $($dirtyCount - 25) more"
    }
  }

  Write-Host "Memory/docs: $($memoryFiles -join ', ')"
  Write-Host 'Remotes:'
  $remoteLines = @(Invoke-SafeGit -RepositoryPath $project.LocalPath -Arguments @('remote', '-v') 2>$null)
  $remoteLines | ForEach-Object { Write-Host $_ }

  if ($Online) {
    $remoteNames = @(Invoke-SafeGit -RepositoryPath $project.LocalPath -Arguments @('remote') 2>$null)
    $matchingRemoteNames = @()

    if ($remoteNames.Count -gt 0) {
      Write-Host 'Configured remote branch HEADs:'
    }

    foreach ($remoteName in $remoteNames) {
      $remoteUrl = (Invoke-SafeGit -RepositoryPath $project.LocalPath -Arguments @('remote', 'get-url', $remoteName) 2>$null)
      $remoteBranchHead = $null
      try {
        $remoteLine = git ls-remote --heads $remoteUrl $branch 2>$null | Select-Object -First 1
        if ($remoteLine) {
          $remoteBranchHead = ($remoteLine -split '\s+')[0]
        }
      } catch {
        Write-Warning "Could not query remote ${remoteName}: $remoteUrl"
      }

      Write-Host "  ${remoteName}/${branch}: $remoteBranchHead"
      if ($remoteBranchHead -and $head -and ($remoteBranchHead -eq $head)) {
        $matchingRemoteNames += $remoteName
      }
    }

    $githubUrl = "https://github.com/$Owner/$($project.GitHubRepo).git"
    $githubMain = $null
    try {
      $line = git ls-remote --heads $githubUrl main 2>$null | Select-Object -First 1
      if ($line) {
        $githubMain = ($line -split '\s+')[0]
      }
    } catch {
      Write-Warning "Could not query GitHub: $githubUrl"
    }

    Write-Host "GitHub main HEAD: $githubMain"

    if ($githubMain -and $head -and ($githubMain -ne $head)) {
      Write-Warning 'Local HEAD does not match GitHub main. Do not reset until this is reconciled.'
    }

    if ($matchingRemoteNames.Count -gt 0) {
      Write-Host "Local HEAD exists on configured remote(s): $($matchingRemoteNames -join ', ')"
    } elseif ($head) {
      Write-Warning 'Local HEAD was not found on any configured remote branch checked.'
    }
  }

  if ($dirtyCount -gt 0) {
    Write-Warning 'Local repository has uncommitted or untracked files. Do not reset until committed/pushed or intentionally discarded.'
  }

  Write-Host ''
}

Write-Host 'Audit complete.'
