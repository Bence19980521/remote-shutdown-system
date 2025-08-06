# Egyszerű deployment Railway-re
# 1. Menj a https://railway.app oldalra
# 2. Regisztrálj GitHub-bal  
# 3. Kattints "New Project" -> "Deploy from GitHub repo"
# 4. Válaszd ki ezt a repo-t és a SignalRServer mappát
# 5. Railway automatikusan deploy-olja!
# 6. Kapni fogsz egy URL-t, pl: https://signalrserver-production-a1b2.up.railway.app

# FONTOS: Deployment után frissítsd ezeket a fájlokat a kapott URL-lel:

# 1. WindowsService/appsettings.json
Write-Host "1. Frissítsd a WindowsService/appsettings.json fájlban a HubUrl-t:"
Write-Host '   "HubUrl": "https://YOUR-RAILWAY-URL.railway.app/shutdownhub"'

# 2. WebApp/index.html és mobile.html
Write-Host "2. Frissítsd a WebApp fájlokban a CLOUD_URL-t:"
Write-Host '   const CLOUD_URL = "https://YOUR-RAILWAY-URL.railway.app/shutdownhub";'

# 3. Rebuild Windows Service
Write-Host "3. Build újra a Windows Service-t:"
cd WindowsService
dotnet build -c Release

# 4. Reinstall service
Write-Host "4. Telepítsd újra a Windows Service-t:"
Write-Host "   .\uninstall-service.ps1"
Write-Host "   .\install-service.ps1"

Write-Host ""
Write-Host "🎉 Kész! Most már bárhonnan elérheted a rendszered!"
Write-Host "📱 Mobil app: Nyisd meg mobile.html-t telefonon és 'Add to Home Screen'"
