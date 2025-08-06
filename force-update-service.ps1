# Force update service script - futtatás rendszergazdaként

Write-Host "Force Service Update Script" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

# Ellenőrizzük, hogy rendszergazdaként futunk-e
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Ez a script rendszergazdai jogosultságokat igényel!"
    Write-Host "Kattints jobb egérgombbal a PowerShell-re és válaszd a 'Futtatás rendszergazdaként' opciót."
    Write-Host ""
    Write-Host "Vagy futtasd ezt a parancsot rendszergazdai PowerShell-ben:"
    Write-Host "cd '$PWD'; .\force-update-service.ps1" -ForegroundColor Yellow
    pause
    exit 1
}

try {
    Write-Host "1. Service leállítása..." -ForegroundColor Yellow
    
    # Próbáljuk meg normálisan leállítani
    $existingService = Get-Service -Name "RemoteShutdownService" -ErrorAction SilentlyContinue
    if ($existingService -and $existingService.Status -eq "Running") {
        try {
            Stop-Service -Name "RemoteShutdownService" -Force -ErrorAction Stop
            Write-Host "Service leállítva Stop-Service paranccsal" -ForegroundColor Green
        }
        catch {
            Write-Host "Stop-Service nem működött, próbáljuk az sc parancsot..." -ForegroundColor Yellow
            & sc.exe stop RemoteShutdownService
            Start-Sleep -Seconds 3
        }
        
        # Ha még mindig fut, kényszerített leállítás
        $stillRunning = Get-Service -Name "RemoteShutdownService" -ErrorAction SilentlyContinue
        if ($stillRunning -and $stillRunning.Status -eq "Running") {
            Write-Host "Kényszerített folyamat leállítás..." -ForegroundColor Yellow
            Get-Process -Name "RemoteShutdownService" -ErrorAction SilentlyContinue | Stop-Process -Force
            Start-Sleep -Seconds 2
        }
    }
    
    Write-Host "2. Service törlése..." -ForegroundColor Yellow
    & sc.exe delete RemoteShutdownService
    Start-Sleep -Seconds 2
    
    Write-Host "3. Új verzió buildelse..." -ForegroundColor Yellow
    Set-Location "WindowsService"
    & dotnet build -c Release
    if ($LASTEXITCODE -ne 0) {
        throw "Build hiba"
    }
    
    Write-Host "4. Service újratelepítése..." -ForegroundColor Yellow
    Set-Location ".."
    $servicePath = "$PWD\WindowsService\bin\Release\net8.0-windows\RemoteShutdownService.exe"
    
    # Service létrehozása
    & sc.exe create RemoteShutdownService binPath= $servicePath start= auto
    if ($LASTEXITCODE -ne 0) {
        throw "Service létrehozási hiba"
    }
    
    # Service indítása
    & sc.exe start RemoteShutdownService
    if ($LASTEXITCODE -ne 0) {
        throw "Service indítási hiba"
    }
    
    Write-Host ""
    Write-Host "✅ Service sikeresen frissítve!" -ForegroundColor Green
    Write-Host ""
    
    # Service állapot ellenőrzése
    Get-Service -Name "RemoteShutdownService"
}
catch {
    Write-Error "Hiba: $($_.Exception.Message)"
    Write-Host "Probléma esetén futtasd ezt manuálisan rendszergazdai PowerShell-ben!" -ForegroundColor Red
}

Write-Host "Nyomj meg egy billentyűt a kilépéshez..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
