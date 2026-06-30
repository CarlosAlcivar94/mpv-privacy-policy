param(
  [string]$Owner = 'CarlosAlcivar94',
  [string]$Destination = 'C:\Dev',
  [switch]$IncludePublicSite
)

. "$PSScriptRoot\projects.ps1"

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Destination)) {
  New-Item -ItemType Directory -Path $Destination | Out-Null
}

foreach ($project in $MigrationProjects) {
  if ($project.PublicSite -and -not $IncludePublicSite) {
    continue
  }

  $folderName = if ($project.CloneFolder) { $project.CloneFolder } else { $project.GitHubRepo }
  $targetPath = Join-Path $Destination $folderName
  $repoUrl = "https://github.com/$Owner/$($project.GitHubRepo).git"

  if (Test-Path -LiteralPath $targetPath) {
    Write-Host "Exists, skipping: $targetPath"
    continue
  }

  Write-Host "Cloning $repoUrl -> $targetPath"
  git clone $repoUrl $targetPath
}
