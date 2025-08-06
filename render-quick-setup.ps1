# GYORS RENDER DEPLOYMENT SCRIPT
# Ez a script végigvezet a teljes Render deployment folyamaton

Write-Host "🚀 RENDER.COM DEPLOYMENT GYORS ÚTMUTATÓ" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════" -ForegroundColor Green

Write-Host "`n📋 ELŐFELTÉTELEK ELLENŐRZÉSE:" -ForegroundColor Cyan

# GitHub fiók ellenőrzése
$hasGitHub = Read-Host "Van GitHub fiókod? (i/n)"
if ($hasGitHub -eq "n") {
    Write-Host "❌ Szükséged van GitHub fiókra!" -ForegroundColor Red
    Write-Host "1. Menj a https://github.com oldalra" -ForegroundColor Yellow
    Write-Host "2. Regisztrálj (ingyenes)" -ForegroundColor Yellow
    Write-Host "3. Futtasd újra ezt a scriptet" -ForegroundColor Yellow
    exit
}

# Render fiók ellenőrzése
$hasRender = Read-Host "Van Render.com fiókod? (i/n)"
if ($hasRender -eq "n") {
    Write-Host "❌ Szükséged van Render.com fiókra!" -ForegroundColor Red
    Write-Host "1. Menj a https://render.com oldalra" -ForegroundColor Yellow
    Write-Host "2. Kattints 'Get Started for Free'" -ForegroundColor Yellow
    Write-Host "3. Regisztrálj GitHub fiókkal" -ForegroundColor Yellow
    Write-Host "4. Futtasd újra ezt a scriptet" -ForegroundColor Yellow
    exit
}

Write-Host "`n✅ Előfeltételek OK!" -ForegroundColor Green

Write-Host "`n📂 GITHUB REPOSITORY KÉSZÍTÉSE:" -ForegroundColor Cyan
Write-Host "1. Menj a https://github.com oldalra" -ForegroundColor White
Write-Host "2. Kattints '+' → 'New repository'" -ForegroundColor White
Write-Host "3. Név: remote-shutdown-system" -ForegroundColor White
Write-Host "4. FONTOS: Válaszd 'Public' (ingyenes hosting-hoz kell)" -ForegroundColor Yellow
Write-Host "5. Pipáld be: 'Add a README file'" -ForegroundColor White
Write-Host "6. Kattints 'Create repository'" -ForegroundColor White

$repoReady = Read-Host "`nKész a GitHub repo? (i/n)"
if ($repoReady -eq "n") {
    Write-Host "Fejezd be a repo létrehozását és futtasd újra!" -ForegroundColor Yellow
    exit
}

Write-Host "`n📤 SIGNALR SERVER FELTÖLTÉSE:" -ForegroundColor Cyan
Write-Host "1. A GitHub repo-ban kattints 'uploading an existing file'" -ForegroundColor White
Write-Host "2. Húzd be ezt a teljes mappát: $(Get-Location)\SignalRServer" -ForegroundColor White
Write-Host "3. Commit message: 'Initial SignalR server upload'" -ForegroundColor White
Write-Host "4. Kattints 'Commit changes'" -ForegroundColor White

$uploadReady = Read-Host "`nFeltöltötted a SignalRServer mappát? (i/n)"
if ($uploadReady -eq "n") {
    Write-Host "Fejezd be a feltöltést és futtasd újra!" -ForegroundColor Yellow
    exit
}

Write-Host "`n🚀 RENDER DEPLOYMENT:" -ForegroundColor Cyan
Write-Host "1. Menj a https://render.com oldalra és jelentkezz be" -ForegroundColor White
Write-Host "2. Kattints 'New +' → 'Web Service'" -ForegroundColor White
Write-Host "3. Kattints 'Connect a repository'" -ForegroundColor White
Write-Host "4. Keress rá: 'remote-shutdown-system'" -ForegroundColor White
Write-Host "5. Kattints 'Connect' mellette" -ForegroundColor White

Write-Host "`n⚙️  FONTOS BEÁLLÍTÁSOK:" -ForegroundColor Red
Write-Host "Name: signalr-shutdown-server" -ForegroundColor Yellow
Write-Host "Region: Frankfurt (EU)" -ForegroundColor Yellow
Write-Host "Branch: main" -ForegroundColor Yellow
Write-Host "Root Directory: SignalRServer  <-- EZ FONTOS!" -ForegroundColor Red
Write-Host "Runtime: Docker" -ForegroundColor Yellow
Write-Host "Build Command: (üresen hagyva)" -ForegroundColor Yellow
Write-Host "Start Command: (üresen hagyva)" -ForegroundColor Yellow

Write-Host "`n🔧 ENVIRONMENT VARIABLES:" -ForegroundColor Cyan
Write-Host "Az 'Environment' tab alatt add hozzá:" -ForegroundColor White
Write-Host "ASPNETCORE_ENVIRONMENT = Production" -ForegroundColor Yellow
Write-Host "ASPNETCORE_URLS = http://0.0.0.0:`$PORT" -ForegroundColor Yellow

Write-Host "`n🎯 DEPLOY INDÍTÁSA:" -ForegroundColor Cyan
Write-Host "1. Kattints 'Create Web Service'" -ForegroundColor White
Write-Host "2. Várj 3-5 percet amíg builddel" -ForegroundColor White
Write-Host "3. Ha zöld 'Live' státusz látszik = SIKERES!" -ForegroundColor Green

$deployReady = Read-Host "`nSikeres a deployment? Látod a zöld 'Live' státuszt? (i/n)"
if ($deployReady -eq "n") {
    Write-Host "`n🔍 HIBAELHÁRÍTÁS:" -ForegroundColor Red
    Write-Host "- Ellenőrizd a 'Logs' tab-ot" -ForegroundColor White
    Write-Host "- Root Directory: SignalRServer (pontosan így!)" -ForegroundColor White
    Write-Host "- Environment változók helyesen vannak-e beállítva" -ForegroundColor White
    Write-Host "`nMiután javítottad, futtasd újra ezt a scriptet!" -ForegroundColor Yellow
    exit
}

# URL bekérése
Write-Host "`n🌐 RENDER URL MEGADÁSA:" -ForegroundColor Cyan
Write-Host "Másold ki a Render URL-t (pl: https://signalr-shutdown-server-abc123.onrender.com)" -ForegroundColor White
$renderUrl = Read-Host "Render URL"

if (-not $renderUrl -or $renderUrl -notmatch "^https://.*\.onrender\.com$") {
    Write-Host "❌ Hibás URL formátum!" -ForegroundColor Red
    Write-Host "Példa: https://signalr-shutdown-server-abc123.onrender.com" -ForegroundColor Yellow
    exit
}

Write-Host "`n🔧 AUTOMATIKUS URL FRISSÍTÉS..." -ForegroundColor Cyan
Write-Host "Most automatikusan frissítem az összes URL-t a rendszerben..." -ForegroundColor White

# URL frissítő script futtatása
try {
    .\update-urls.ps1 $renderUrl
    Write-Host "`n🎉 DEPLOYMENT SIKERES!" -ForegroundColor Green
} catch {
    Write-Host "❌ Hiba az URL frissítéskor: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Próbáld manuálisan: .\update-urls.ps1 `"$renderUrl`"" -ForegroundColor Yellow
}

Write-Host "`n📱 VÉGSŐ TESZTELÉS:" -ForegroundColor Cyan
Write-Host "1. Nyisd meg: WebApp\index.html" -ForegroundColor White
Write-Host "2. Látnod kell: 'Sikeresen csatlakozva!'" -ForegroundColor White
Write-Host "3. A PC-d megjelenik a listában" -ForegroundColor White
Write-Host "4. Próbáld ki telefonon: WebApp\mobile.html" -ForegroundColor White

Write-Host "`n🏆 GRATULÁLOK!" -ForegroundColor Green
Write-Host "A távoli PC leállító rendszered most már bárhonnan elérhető!" -ForegroundColor Green
