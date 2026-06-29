$MigrationProjects = @(
  [pscustomobject]@{
    Name = 'MPV'
    LocalPath = 'C:\mpv'
    GitHubRepo = 'MVP'
    CloneFolder = 'MVP'
    InstallProfile = 'flutter-firebase'
    Notes = 'App Android My Vehicle Planner. Ya tiene remoto GitHub.'
    PublicSite = $false
  },
  [pscustomobject]@{
    Name = 'FutureBalance'
    LocalPath = 'C:\FutureBalance'
    GitHubRepo = 'FutureBalance'
    CloneFolder = 'FutureBalance'
    InstallProfile = 'flutter-firebase'
    Notes = 'App Android FutureBalance. Ya tiene remoto GitHub.'
    PublicSite = $false
  },
  [pscustomobject]@{
    Name = 'SATURNO Turnero'
    LocalPath = 'C:\turnero'
    GitHubRepo = 'SATurno'
    CloneFolder = 'saturno-turnero'
    InstallProfile = 'turnero-node'
    Notes = 'Sistema de turnos. Actualmente no es repo Git.'
    PublicSite = $false
  },
  [pscustomobject]@{
    Name = 'GeCTExcel'
    LocalPath = 'C:\GeCTExcel'
    GitHubRepo = 'GeCTExcel'
    CloneFolder = 'gectexcel'
    InstallProfile = 'python'
    Notes = 'Servicio interno para Excel/API. Remoto actual apunta a servidor local.'
    PublicSite = $false
  },
  [pscustomobject]@{
    Name = 'ACKA94 Admin Center'
    LocalPath = 'C:\AdminCenterKA94'
    GitHubRepo = 'AdminCenterKA94'
    CloneFolder = 'acka94-admin-center'
    InstallProfile = 'flutter-node-firebase'
    Notes = 'Panel privado multiapp. Actualmente no es repo Git.'
    PublicSite = $false
  },
  [pscustomobject]@{
    Name = 'GLOBALVIEW'
    LocalPath = 'C:\globalview'
    GitHubRepo = 'GlobalView'
    CloneFolder = 'globalview'
    InstallProfile = 'php-node'
    Notes = 'Portal Power BI. Remoto actual apunta a servidor local.'
    PublicSite = $false
  },
  [pscustomobject]@{
    Name = 'CEVIFLASH'
    LocalPath = 'C:\Users\Administrador1\Documents\New project 2'
    GitHubRepo = 'CeviFlash'
    CloneFolder = 'ceviflash'
    InstallProfile = 'node-firebase'
    Notes = 'PWA Angular/Firebase. Repo Git sin commits.'
    PublicSite = $false
  },
  [pscustomobject]@{
    Name = 'Formularios Excel VBA'
    LocalPath = 'C:\FORMULARIOS'
    GitHubRepo = 'formularios-vba'
    CloneFolder = 'formularios-vba'
    InstallProfile = 'excel-vba'
    Notes = 'Automatizaciones Excel/VBA. Revisar archivos .xlsm y datos reales antes de subir.'
    PublicSite = $false
  },
  [pscustomobject]@{
    Name = 'KA94 Studio Site'
    LocalPath = 'C:\mpv-privacy-policy'
    GitHubRepo = 'mpv-privacy-policy'
    CloneFolder = 'mpv-privacy-policy'
    InstallProfile = 'static-site'
    Notes = 'Sitio publico ka94studio.com. Mantener publico si GitHub Pages depende de este repo.'
    PublicSite = $true
  }
)
