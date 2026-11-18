$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

Write-Host 'Subindo Quarkus 2 (usuarios 8081 / notificacoes 8082)...' -ForegroundColor Cyan
Write-Host 'Execute em terminais separados:' -ForegroundColor Yellow
Write-Host "  mvn -f '$root\quarkus2\usuarios-service\pom.xml' quarkus:dev"
Write-Host "  mvn -f '$root\quarkus2\notificacoes-service\pom.xml' quarkus:dev"

$mws = Join-Path $root 'quarkus2\usuarios-service'
$mwn = Join-Path $root 'quarkus2\notificacoes-service'

Start-Process -FilePath 'powershell' -ArgumentList "-NoExit","-Command","cd '$mws'; mvn quarkus:dev" -WindowStyle Normal
Start-Process -FilePath 'powershell' -ArgumentList "-NoExit","-Command","cd '$mwn'; mvn quarkus:dev" -WindowStyle Normal
