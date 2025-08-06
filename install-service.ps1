# Telepítési script Windows Service-hez
# Futtasd Rendszergazdaként!

param(
    [string]$ServerUrl = "http://localhost:5000/shutdownhub",
    [string]$ServicePath = ""
)

if ([string]::IsNullOrEmpty($ServicePath)) {
    $ServicePath = Join-Path $PSScriptRoot "WindowsService\bin\Release\net8.0\win-x64\publish\RemoteShutdownService.exe"
}

Write-Host "Remote Shutdown Service telepítő" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Ellenőrizzük, hogy rendszergazdaként futunk-e
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Ez a script rendszergazdai jogosultságokat igényel!"
    Write-Host "Kattints jobb egérgombbal a PowerShell-re és válaszd a 'Futtatás rendszergazdaként' opciót."
    exit 1
}

try {
    # Építjük a projektet
    Write-Host "Projekt építése..." -ForegroundColor Yellow
    Set-Location "WindowsService"
    & dotnet restore
    & dotnet build -c Release
    & dotnet publish -c Release -r win-x64 --self-contained
    Set-Location ".."

    # Ellenőrizzük hogy létezik-e a service exe
    if (-not (Test-Path $ServicePath)) {
        Write-Error "A service executable nem található: $ServicePath"
        exit 1
    }

    # Frissítjük a szerver URL-t a konfigurációban
    Write-Host "Szerver URL beállítása: $ServerUrl" -ForegroundColor Yellow
    $configFile = "WindowsService\Worker.cs"
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw
        $content = $content -replace 'https://your-signalr-hub\.azurewebsites\.net/shutdownhub', $ServerUrl
        Set-Content $configFile -Value $content
        
        # Újraépítjük a frissített konfigurációval
        Set-Location "WindowsService"
        & dotnet build -c Release
        & dotnet publish -c Release -r win-x64 --self-contained
        Set-Location ".."
    }

    # Leállítjuk a service-t ha már fut
    $existingService = Get-Service -Name "RemoteShutdownService" -ErrorAction SilentlyContinue
    if ($existingService) {
        Write-Host "Meglévő service leállítása..." -ForegroundColor Yellow
        Stop-Service -Name "RemoteShutdownService" -Force
        & sc.exe delete RemoteShutdownService
        Start-Sleep -Seconds 2
    }

    # Telepítjük a service-t
    Write-Host "Windows Service telepítése..." -ForegroundColor Yellow
    & sc.exe create RemoteShutdownService binPath= $ServicePath
    if ($LASTEXITCODE -ne 0) {
        throw "Hiba a service létrehozásakor"
    }

    # Beállítjuk automatikus indításra
    & sc.exe config RemoteShutdownService start= auto
    if ($LASTEXITCODE -ne 0) {
        throw "Hiba az automatikus indítás beállításakor"
    }

    # Elindítjuk a service-t
    Write-Host "Service indítása..." -ForegroundColor Yellow
    & sc.exe start RemoteShutdownService
    if ($LASTEXITCODE -ne 0) {
        throw "Hiba a service indításakor"
    }

    Write-Host ""
    Write-Host "✅ RemoteShutdownService sikeresen telepítve és elindítva!" -ForegroundColor Green
    Write-Host "📱 Most telepítsd a mobil alkalmazást és állítsd be a szerver URL-t." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Service állapot ellenőrzése:" -ForegroundColor Yellow
    & sc.exe query RemoteShutdownService

} catch {
    Write-Error "Hiba történt a telepítés során: $($_.Exception.Message)"
    exit 1
}
