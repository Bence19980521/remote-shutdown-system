# RemoteShutdownService eltávolító script
# Futtasd Rendszergazdaként!

Write-Host "Remote Shutdown Service eltávolító" -ForegroundColor Red
Write-Host "===================================" -ForegroundColor Red

# Ellenőrizzük, hogy rendszergazdaként futunk-e
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Ez a script rendszergazdai jogosultságokat igényel!"
    Write-Host "Kattints jobb egérgombbal a PowerShell-re és válaszd a 'Futtatás rendszergazdaként' opciót."
    exit 1
}

try {
    # Ellenőrizzük hogy létezik-e a service
    $existingService = Get-Service -Name "RemoteShutdownService" -ErrorAction SilentlyContinue
    if (-not $existingService) {
        Write-Host "RemoteShutdownService nem található." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Service állapota: $($existingService.Status)" -ForegroundColor Yellow

    # Leállítjuk a service-t
    if ($existingService.Status -eq "Running") {
        Write-Host "Service leállítása..." -ForegroundColor Yellow
        Stop-Service -Name "RemoteShutdownService" -Force
        
        # Várunk hogy leálljon
        $timeout = 30
        while ((Get-Service -Name "RemoteShutdownService").Status -eq "Running" -and $timeout -gt 0) {
            Start-Sleep -Seconds 1
            $timeout--
        }
        
        if ((Get-Service -Name "RemoteShutdownService").Status -eq "Running") {
            Write-Warning "A service nem állt le időben. Kényszerített leállítás..."
        }
    }

    # Töröljük a service-t
    Write-Host "Service törlése..." -ForegroundColor Yellow
    & sc.exe delete RemoteShutdownService
    if ($LASTEXITCODE -ne 0) {
        throw "Hiba a service törlésekor"
    }

    Write-Host ""
    Write-Host "✅ RemoteShutdownService sikeresen eltávolítva!" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Error "Hiba történt az eltávolítás során: $($_.Exception.Message)"
    exit 1
}
