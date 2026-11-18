$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

Write-Host 'Subindo Quarkus 4 (usuarios 8083 / notificacoes 8084)...' -ForegroundColor Cyan
Write-Host 'Execute em terminais separados:' -ForegroundColor Yellow
Write-Host "  mvn -f '$root\quarkus4\usuarios-service\pom.xml' quarkus:dev"
Write-Host "  mvn -f '$root\quarkus4\notificacoes-service\pom.xml' quarkus:dev"

$mws = Join-Path $root 'quarkus4\usuarios-service'
$mwn = Join-Path $root 'quarkus4\notificacoes-service'

Start-Process -FilePath 'powershell' -ArgumentList "-NoExit","-Command","cd '$mws'; mvn quarkus:dev" -WindowStyle Normal
Start-Process -FilePath 'powershell' -ArgumentList "-NoExit","-Command","cd '$mwn'; mvn quarkus:dev" -WindowStyle Normal
