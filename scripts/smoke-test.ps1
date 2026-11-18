param(
  [Parameter(Mandatory = $false)]
  [ValidateSet(8081, 8083, 8085)]
  [int]$Port = 8081
)

$ErrorActionPreference = 'Stop'
$map = @{
  8081 = @{ Worker = 8082; Nome = 'Quarkus 2' }
  8085 = @{ Worker = 8086; Nome = 'Quarkus 3' }
  8083 = @{ Worker = 8084; Nome = 'Quarkus 4' }
}
$notifyPort = $map[$Port].Worker
$versao = $map[$Port].Nome

Write-Host "=== Smoke test $versao (core :$Port / worker :$notifyPort) ===" -ForegroundColor Cyan

$payload = @{
  nome  = 'Ana'
  email = "ana.$([DateTime]::UtcNow.Ticks)@email.com"
} | ConvertTo-Json

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$criado = Invoke-RestMethod -Uri "http://localhost:$Port/usuarios" -Method Post -Body $payload -ContentType 'application/json'
$sw.Stop()

Write-Host ("POST /usuarios -> 201 em {0} ms" -f $sw.ElapsedMilliseconds) -ForegroundColor Green
$criado | ConvertTo-Json -Depth 4

Write-Host "`nAguardando o worker (delay simulado de SMTP)..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

$historico = Invoke-RestMethod -Uri "http://localhost:$notifyPort/historico/usuario/$($criado.id)"
Write-Host "`nHistorico de envios do usuario $($criado.id):" -ForegroundColor Green
$historico | ConvertTo-Json -Depth 5

$resumo = Invoke-RestMethod -Uri "http://localhost:$notifyPort/historico/resumo"
Write-Host "`nResumo: $(($resumo | ConvertTo-Json -Compress))" -ForegroundColor Green
