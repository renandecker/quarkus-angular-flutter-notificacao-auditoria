$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$projetos = @(
  'quarkus2\usuarios-service',
  'quarkus2\notificacoes-service',
  'quarkus3\usuarios-service',
  'quarkus3\notificacoes-service',
  'quarkus4\usuarios-service',
  'quarkus4\notificacoes-service'
)

foreach ($p in $projetos) {
  Write-Host "`n>>> Building $p" -ForegroundColor Cyan
  Push-Location (Join-Path $root $p)
  try {
    mvn -B -q package -DskipTests
    if ($LASTEXITCODE -ne 0) { throw "Falha no build de $p" }
    Write-Host "OK: $p" -ForegroundColor Green
  }
  finally { Pop-Location }
}
