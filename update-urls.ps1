# Automatikus URL frissítő script Render deployment után
# Használat: .\update-urls.ps1 "https://your-render-url.onrender.com"

param(
    [Parameter(Mandatory=$true)]
    [string]$RenderUrl
)

$HubUrl = "$RenderUrl/shutdownhub"

Write-Host "🔄 URL-ek frissítése..." -ForegroundColor Yellow
Write-Host "Render URL: $RenderUrl" -ForegroundColor Green
Write-Host "SignalR Hub URL: $HubUrl" -ForegroundColor Green

# 1. Windows Service appsettings.json frissítése
Write-Host "`n1. Windows Service konfigurációjának frissítése..." -ForegroundColor Cyan

$appsettingsPath = "WindowsService\appsettings.json"
$appsettingsContent = @"
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "SignalR": {
    "HubUrl": "$HubUrl"
  }
}
"@

$appsettingsContent | Out-File -FilePath $appsettingsPath -Encoding UTF8
Write-Host "✅ $appsettingsPath frissítve" -ForegroundColor Green

# 2. Web App index.html frissítése
Write-Host "`n2. Web App (index.html) frissítése..." -ForegroundColor Cyan

$indexPath = "WebApp\index.html"
if (Test-Path $indexPath) {
    $indexContent = Get-Content $indexPath -Raw
    $indexContent = $indexContent -replace 'withUrl\("http://localhost:5000/shutdownhub"\)', "withUrl(`"$HubUrl`")"
    $indexContent | Out-File -FilePath $indexPath -Encoding UTF8
    Write-Host "✅ $indexPath frissítve" -ForegroundColor Green
} else {
    Write-Host "⚠️  $indexPath nem található" -ForegroundColor Yellow
}

# 3. Mobile App frissítése
Write-Host "`n3. Mobile App (mobile.html) frissítése..." -ForegroundColor Cyan

$mobilePath = "WebApp\mobile.html"
if (Test-Path $mobilePath) {
    $mobileContent = Get-Content $mobilePath -Raw
    $mobileContent = $mobileContent -replace 'const CLOUD_URL = ".*?"', "const CLOUD_URL = `"$HubUrl`""
    $mobileContent | Out-File -FilePath $mobilePath -Encoding UTF8
    Write-Host "✅ $mobilePath frissítve" -ForegroundColor Green
} else {
    Write-Host "⚠️  $mobilePath nem található" -ForegroundColor Yellow
}

# 4. Windows Service rebuild
Write-Host "`n4. Windows Service újraépítése..." -ForegroundColor Cyan

Set-Location "WindowsService"
$buildResult = dotnet build -c Release 2>&1
Set-Location ".."

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Windows Service sikeresen újraépítve" -ForegroundColor Green
} else {
    Write-Host "❌ Build hiba:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    return
}

# 5. Service újratelepítése
Write-Host "`n5. Windows Service újratelepítése..." -ForegroundColor Cyan

Write-Host "Service leállítása és eltávolítása..." -ForegroundColor Yellow
try {
    .\uninstall-service.ps1
    Write-Host "✅ Service eltávolítva" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Service eltávolítási hiba (lehet, hogy nem volt telepítve): $($_.Exception.Message)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

Write-Host "Service újratelepítése..." -ForegroundColor Yellow
try {
    .\install-service.ps1
    Write-Host "✅ Service telepítve" -ForegroundColor Green
} catch {
    Write-Host "❌ Service telepítési hiba: $($_.Exception.Message)" -ForegroundColor Red
    return
}

Start-Sleep -Seconds 3

# 6. Service állapot ellenőrzése
Write-Host "`n6. Service állapot ellenőrzése..." -ForegroundColor Cyan

try {
    .\check-service.ps1
    Write-Host "✅ Service ellenőrzés befejezve" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Service ellenőrzési hiba: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n🎉 MINDEN KÉSZ!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "📱 Webes app: WebApp\index.html" -ForegroundColor White
Write-Host "📱 Mobil app: WebApp\mobile.html" -ForegroundColor White  
Write-Host "🖥️  Windows Service: Fut és csatlakozik a felhőhöz" -ForegroundColor White
Write-Host "🌐 Server URL: $RenderUrl" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green

Write-Host "`n📋 TESZTELÉS:" -ForegroundColor Cyan
Write-Host "1. Nyisd meg WebApp\index.html böngészőben" -ForegroundColor White
Write-Host "2. Ellenőrizd, hogy a PC megjelenik-e a listában" -ForegroundColor White
Write-Host "3. Próbáld ki a parancsokat (óvatosan!)" -ForegroundColor White
Write-Host "4. Telefonon nyisd meg WebApp\mobile.html-t" -ForegroundColor White
