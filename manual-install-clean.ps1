# Remote Shutdown Service Manual Install
Write-Host "=== REMOTE SHUTDOWN SERVICE TELEPITES ===" -ForegroundColor Green

# Admin check
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Ez a script Administrator jogokat igenyel!"
    Write-Host "Jobb klikk -> 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

$ServicePath = "C:\Users\User\Desktop\geplallito\WindowsService\bin\Release\net8.0-windows\RemoteShutdownService.exe"

Write-Host "Service exe path: $ServicePath" -ForegroundColor Cyan

# Check if exe exists
if (-not (Test-Path $ServicePath)) {
    Write-Error "Service executable nem talalhato: $ServicePath"
    Write-Host "Eloszor build-eld a projektet!" -ForegroundColor Yellow
    exit 1
}

# Stop and remove existing service
Write-Host "Meglevo service eltavolitasa..." -ForegroundColor Yellow
$service = Get-Service -Name "RemoteShutdownService" -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name "RemoteShutdownService" -Force -ErrorAction SilentlyContinue
    sc.exe delete RemoteShutdownService
    Start-Sleep 2
}

# Create new service
Write-Host "Uj service letrehozasa..." -ForegroundColor Yellow
sc.exe create RemoteShutdownService binPath= $ServicePath start= auto

if ($LASTEXITCODE -eq 0) {
    Write-Host "Service indítasa..." -ForegroundColor Yellow
    sc.exe start RemoteShutdownService
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "SUCCESS! Service telepitve es fut!" -ForegroundColor Green
        Write-Host "Most probald a mobil appot!" -ForegroundColor Cyan
        
        # Show service status
        Get-Service -Name "RemoteShutdownService"
    } else {
        Write-Error "Service inditasi hiba!"
    }
} else {
    Write-Error "Service telepitesi hiba!"
}

Write-Host ""
Write-Host "Mobil app URL: https://remote-shutdown-system.onrender.com/mobile.html" -ForegroundColor Magenta
