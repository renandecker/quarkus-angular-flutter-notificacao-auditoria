$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

Write-Host 'Subindo Quarkus 3 (usuarios 8085 / notificacoes 8086)...' -ForegroundColor Cyan
Write-Host 'Execute em terminais separados:' -ForegroundColor Yellow
Write-Host "  mvn -f '$root\quarkus3\usuarios-service\pom.xml' quarkus:dev"
Write-Host "  mvn -f '$root\quarkus3\notificacoes-service\pom.xml' quarkus:dev"

$mws = Join-Path $root 'quarkus3\usuarios-service'
$mwn = Join-Path $root 'quarkus3\notificacoes-service'

Start-Process -FilePath 'powershell' -ArgumentList "-NoExit","-Command","cd '$mws'; mvn quarkus:dev" -WindowStyle Normal
Start-Process -FilePath 'powershell' -ArgumentList "-NoExit","-Command","cd '$mwn'; mvn quarkus:dev" -WindowStyle Normal
