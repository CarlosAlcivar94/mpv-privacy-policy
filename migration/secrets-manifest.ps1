$SecretFileManifest = @(
  [pscustomobject]@{
    Project = 'MPV'
    Paths = @(
      'google-services.json',
      'android/app/google-services.json',
      'android/key.properties',
      'upload-keystore.jks'
    )
  },
  [pscustomobject]@{
    Project = 'FutureBalance'
    Paths = @(
      'android/app/google-services.json',
      'android/key.properties',
      'android/app/upload-keystore.jks'
    )
  },
  [pscustomobject]@{
    Project = 'SATURNO Turnero'
    Paths = @(
      'apps/backend/.env'
    )
  },
  [pscustomobject]@{
    Project = 'GeCTExcel'
    Paths = @(
      '.env',
      'services.json'
    )
  },
  [pscustomobject]@{
    Project = 'ACKA94 Admin Center'
    Paths = @(
      'functions/.env',
      'android/app/google-services.json',
      'android/key.properties',
      'android/app/upload-keystore.jks'
    )
  },
  [pscustomobject]@{
    Project = 'GLOBALVIEW'
    Paths = @(
      '.env',
      'config.php'
    )
  },
  [pscustomobject]@{
    Project = 'CEVIFLASH'
    Paths = @(
      '.env',
      'src/environments/environment.ts',
      'src/environments/environment.prod.ts'
    )
  }
)

