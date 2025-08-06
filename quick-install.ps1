# Windows Service Quick Install Script
# Run as Administrator!

Write-Host "Installing Remote Shutdown Service..." -ForegroundColor Green

# Check admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires Administrator privileges!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

try {
    # Stop and remove existing service if it exists
    $existingService = Get-Service -Name "RemoteShutdownService" -ErrorAction SilentlyContinue
    if ($existingService) {
        Write-Host "Removing existing service..." -ForegroundColor Yellow
        if ($existingService.Status -eq "Running") {
            Stop-Service -Name "RemoteShutdownService" -Force
        }
        & sc.exe delete RemoteShutdownService
        Start-Sleep -Seconds 2
    }

    # Build the service
    Write-Host "Building service..." -ForegroundColor Yellow
    Set-Location WindowsService
    & dotnet publish -c Release -r win-x64 --self-contained
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed"
    }
    Set-Location ..

    # Service executable path
    $servicePath = Join-Path $PSScriptRoot "WindowsService\bin\Release\net8.0-windows\win-x64\publish\RemoteShutdownService.exe"
    
    if (-not (Test-Path $servicePath)) {
        throw "Service executable not found: $servicePath"
    }

    Write-Host "Installing service..." -ForegroundColor Yellow
    # Create Windows Service
    & sc.exe create RemoteShutdownService binPath= $servicePath start= auto DisplayName= "Remote Shutdown Service"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create service"
    }

    # Set service description
    & sc.exe description RemoteShutdownService "Remote PC shutdown service via SignalR"

    # Start service
    Write-Host "Starting service..." -ForegroundColor Yellow
    & sc.exe start RemoteShutdownService
    
    Start-Sleep -Seconds 3
    $serviceStatus = Get-Service -Name "RemoteShutdownService"
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ INSTALLATION COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Service Name: RemoteShutdownService" -ForegroundColor Cyan
    Write-Host "Service Status: $($serviceStatus.Status)" -ForegroundColor Cyan
    Write-Host "Auto Start: Yes" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Update server URL in Worker.cs!" -ForegroundColor Red
    Write-Host "Current URL: https://your-signalr-hub.azurewebsites.net/shutdownhub" -ForegroundColor White
    Write-Host ""
    Write-Host "Service Management Commands:" -ForegroundColor Yellow
    Write-Host "  Start:   sc start RemoteShutdownService" -ForegroundColor White
    Write-Host "  Stop:    sc stop RemoteShutdownService" -ForegroundColor White
    Write-Host "  Status:  sc query RemoteShutdownService" -ForegroundColor White
    Write-Host "  Remove:  .\uninstall-service.ps1" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
}
