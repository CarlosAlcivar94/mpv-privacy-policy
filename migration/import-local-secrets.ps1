param(
  [Parameter(Mandatory = $true)]
  [string]$BundlePath,
  [string]$Destination = 'C:\Dev',
  [switch]$DryRun,
  [switch]$Overwrite
)

. "$PSScriptRoot\projects.ps1"

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

function Get-AesKey {
  param(
    [string]$Passphrase,
    [byte[]]$Salt,
    [int]$Iterations
  )

  $derive = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Passphrase, $Salt, $Iterations)
  try {
    $derive.GetBytes(32)
  } finally {
    $derive.Dispose()
  }
}

function Unprotect-Json {
  param(
    [object]$Bundle,
    [string]$Passphrase
  )

  $salt = [Convert]::FromBase64String($Bundle.salt)
  $iv = [Convert]::FromBase64String($Bundle.iv)
  $cipherBytes = [Convert]::FromBase64String($Bundle.ciphertext)
  $iterations = [int]$Bundle.iterations
  $key = Get-AesKey -Passphrase $Passphrase -Salt $salt -Iterations $iterations

  $aes = [System.Security.Cryptography.Aes]::Create()
  try {
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.Key = $key
    $aes.IV = $iv
    $decryptor = $aes.CreateDecryptor()
    $plainBytes = $decryptor.TransformFinalBlock($cipherBytes, 0, $cipherBytes.Length)
    [Text.Encoding]::UTF8.GetString($plainBytes)
  } finally {
    $aes.Dispose()
  }
}

if (-not (Test-Path -LiteralPath $BundlePath -PathType Leaf)) {
  throw "Bundle not found: $BundlePath"
}

$bundle = Get-Content -Raw -LiteralPath $BundlePath | ConvertFrom-Json
$secure = Read-Host 'Passphrase del bundle' -AsSecureString
$passphrase = ConvertFrom-SecureStringToPlainText $secure
$json = Unprotect-Json -Bundle $bundle -Passphrase $passphrase
$payload = $json | ConvertFrom-Json

Write-Host "Bundle created: $($payload.createdAt)"
Write-Host "Files in bundle: $($payload.files.Count)"

foreach ($file in $payload.files) {
  $targetRoot = Join-Path $Destination $file.cloneFolder
  $targetPath = Join-Path $targetRoot $file.relativePath
  $targetDir = Split-Path -Parent $targetPath

  if (-not (Test-Path -LiteralPath $targetRoot)) {
    Write-Warning "Project folder not found, skipping [$($file.project)]: $targetRoot"
    continue
  }

  if ((Test-Path -LiteralPath $targetPath) -and -not $Overwrite) {
    Write-Warning "Exists, skipping without -Overwrite: $targetPath"
    continue
  }

  Write-Host "Restore [$($file.project)] $($file.relativePath)"
  if ($DryRun) {
    continue
  }

  if (-not (Test-Path -LiteralPath $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
  }

  $bytes = [Convert]::FromBase64String($file.contentBase64)
  [IO.File]::WriteAllBytes($targetPath, $bytes)
}

if ($DryRun) {
  Write-Host 'Dry run completed. No files were written.' -ForegroundColor Yellow
} else {
  Write-Host 'Secrets import completed.' -ForegroundColor Green
}

