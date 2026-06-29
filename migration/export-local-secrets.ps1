param(
  [string]$OutputPath = 'C:\DevTransfer\ka94-secrets.bundle.json',
  [switch]$IncludeMissing
)

. "$PSScriptRoot\projects.ps1"
. "$PSScriptRoot\secrets-manifest.ps1"

$ErrorActionPreference = 'Stop'

function ConvertFrom-SecureStringToPlainText {
  param([securestring]$SecureString)

  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
  try {
    [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  } finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}

function Read-PassphraseTwice {
  $first = Read-Host 'Passphrase para cifrar secretos' -AsSecureString
  $second = Read-Host 'Repite la passphrase' -AsSecureString
  $firstPlain = ConvertFrom-SecureStringToPlainText $first
  $secondPlain = ConvertFrom-SecureStringToPlainText $second

  if ($firstPlain -ne $secondPlain) {
    throw 'Las passphrases no coinciden.'
  }

  if ($firstPlain.Length -lt 12) {
    throw 'Usa una passphrase de al menos 12 caracteres.'
  }

  return $firstPlain
}

function Get-AesKey {
  param(
    [string]$Passphrase,
    [byte[]]$Salt
  )

  $derive = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Passphrase, $Salt, 200000)
  try {
    $derive.GetBytes(32)
  } finally {
    $derive.Dispose()
  }
}

function Protect-Json {
  param(
    [string]$Json,
    [string]$Passphrase
  )

  $salt = New-Object byte[] 16
  $iv = New-Object byte[] 16
  $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  try {
    $rng.GetBytes($salt)
    $rng.GetBytes($iv)
  } finally {
    $rng.Dispose()
  }

  $key = Get-AesKey -Passphrase $Passphrase -Salt $salt
  $aes = [System.Security.Cryptography.Aes]::Create()
  try {
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.Key = $key
    $aes.IV = $iv
    $encryptor = $aes.CreateEncryptor()
    $plainBytes = [Text.Encoding]::UTF8.GetBytes($Json)
    $cipherBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)

    [pscustomobject]@{
      version = 1
      kdf = 'PBKDF2'
      iterations = 200000
      cipher = 'AES-256-CBC'
      salt = [Convert]::ToBase64String($salt)
      iv = [Convert]::ToBase64String($iv)
      ciphertext = [Convert]::ToBase64String($cipherBytes)
    }
  } finally {
    $aes.Dispose()
  }
}

$projectByName = @{}
foreach ($project in $MigrationProjects) {
  $projectByName[$project.Name] = $project
}

$files = @()
$missing = @()

foreach ($entry in $SecretFileManifest) {
  if (-not $projectByName.ContainsKey($entry.Project)) {
    Write-Warning "Project not found in migration manifest: $($entry.Project)"
    continue
  }

  $project = $projectByName[$entry.Project]
  foreach ($relativePath in $entry.Paths) {
    $sourcePath = Join-Path $project.LocalPath $relativePath
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
      $missing += [pscustomobject]@{
        project = $entry.Project
        relativePath = $relativePath
        sourcePath = $sourcePath
      }
      continue
    }

    $bytes = [IO.File]::ReadAllBytes($sourcePath)
    $files += [pscustomobject]@{
      project = $entry.Project
      cloneFolder = $project.CloneFolder
      relativePath = $relativePath
      sourcePath = $sourcePath
      length = $bytes.Length
      contentBase64 = [Convert]::ToBase64String($bytes)
    }
  }
}

Write-Host "Secret files found: $($files.Count)"
foreach ($file in $files) {
  Write-Host "  [$($file.project)] $($file.relativePath) ($($file.length) bytes)"
}

if ($missing.Count -gt 0) {
  Write-Host ''
  Write-Host "Missing optional files: $($missing.Count)" -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host "  [$($_.project)] $($_.relativePath)" }
}

if ($files.Count -eq 0 -and -not $IncludeMissing) {
  throw 'No secret files found to export.'
}

$payload = [pscustomobject]@{
  createdAt = (Get-Date).ToString('o')
  machine = $env:COMPUTERNAME
  user = $env:USERNAME
  files = $files
  missing = if ($IncludeMissing) { $missing } else { @() }
}

$json = $payload | ConvertTo-Json -Depth 10
$passphrase = Read-PassphraseTwice
$protected = Protect-Json -Json $json -Passphrase $passphrase

$outputDir = Split-Path -Parent $OutputPath
if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$protected | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host ''
Write-Host "Encrypted bundle written to: $OutputPath" -ForegroundColor Green
Write-Host 'Move this file to the new PC by USB or a private channel. Do not commit it to Git.'

