# RENDER.COM DEPLOYMENT - RÉSZLETES ÚTMUTATÓ

## 1. Render.com Regisztráció és Setup

### 1.1 Fiók létrehozása
1. Menj a https://render.com oldalra
2. Kattints a "Get Started for Free" gombra
3. Regisztrálj GitHub fiókkal (vagy email-lel)
4. Erősítsd meg az email címedet

### 1.2 GitHub Repository Kapcsolás
1. A Render Dashboard-on kattints "New +"
2. Válaszd "Web Service"
3. Kattints "Connect GitHub" 
4. Engedd át a GitHub hozzáférést
5. Válaszd ki a projekted repository-ját
6. Ha nincs GitHub repo, akkor:
   - Menj GitHub.com-ra
   - Hozz létre új repository-t "remote-shutdown-system" néven
   - Upload-old a SignalRServer mappát

## 2. Web Service Konfigurálás

### 2.1 Alapbeállítások
```
Name: signalr-shutdown-server
Region: Frankfurt (EU) vagy Oregon (US)
Branch: main
Root Directory: SignalRServer  (FONTOS!)
```

### 2.2 Build & Deploy Beállítások
```
Runtime: Docker

Build Command: (üresen hagyva)
Start Command: (üresen hagyva)
```

### 2.3 Pricing Plan
```
Instance Type: Free
- 750 óra/hó (kb. 31 nap)
- 512 MB RAM
- 0.1 CPU
- Automatikus sleep 15 perc inaktivitás után
```

## 3. Környezeti Változók (Environment Variables)
A "Environment" tab alatt add hozzá:
```
ASPNETCORE_ENVIRONMENT = Production
ASPNETCORE_URLS = http://0.0.0.0:$PORT
```

## 4. Deploy Indítása
1. Kattints "Create Web Service"
2. Render automatikusan építi és indítja az alkalmazást
3. Várj 3-5 percet
4. A publikus URL: https://signalr-shutdown-server-XXXXX.onrender.com

## 5. Működés ellenőrzése
- Ha minden OK, akkor az URL megnyitásával látod: "SignalR Shutdown Server is running!"
- Health check: https://your-url.onrender.com/health

## 6. Ingyenes korlátok
- 750 óra/hó (körülbelül 31 nap)
- 15 perc inaktivitás után "alszik" 
- Első kérésre 10-30 másodperc alatt "felébred"
- 500 MB kimenő forgalom/hó

## 7. Problémamegoldás
- Ha a build failel: ellenőrizd a Root Directory beállítást
- Ha nem indul: nézd meg a "Logs" tab-ot
- Port hibák: ASPNETCORE_URLS környezeti változó ellenőrzése

---

# LÉPÉSRŐL LÉPÉSRE ÚTMUTATÓ

## LÉPÉS 1: GitHub Repository létrehozása

### 1.1 GitHub fiók létrehozása (ha nincs)
1. Menj a https://github.com oldalra
2. Kattints "Sign up" 
3. Adj meg felhasználónevet, email-t, jelszót
4. Erősítsd meg az email címedet

### 1.2 Új Repository létrehozása
1. GitHub-on kattints a "+" jel mellett a "New repository"
2. Repository név: `remote-shutdown-system`
3. Description: `Távoli PC leállító rendszer`
4. **FONTOS**: Válaszd a "Public" opciót (ingyenes hosting-hoz kell)
5. Pipáld be: "Add a README file"
6. Kattints "Create repository"

### 1.3 Fájlok feltöltése
1. A létrehozott repo-ban kattints "uploading an existing file"
2. Húzd be a teljes `SignalRServer` mappát
3. Commit message: "Initial SignalR server upload"
4. Kattints "Commit changes"

## LÉPÉS 2: Render.com Setup

### 2.1 Render fiók létrehozása
1. Menj a https://render.com oldalra
2. Kattints "Get Started for Free"
3. Válaszd "Sign up with GitHub"
4. Authorize-áld a Render-t a GitHub fiókodhoz

### 2.2 Web Service létrehozása
1. A Render Dashboard-on kattints "New +"
2. Válaszd "Web Service"
3. Kattints "Connect a repository"
4. Keress rá a `remote-shutdown-system` repo-ra
5. Kattints "Connect" mellette

### 2.3 Service konfiguráció (PONTOSAN ÍGY!)
```
Name: signalr-shutdown-server
Region: Frankfurt (EU) - alacsonyabb latency
Branch: main
Root Directory: SignalRServer
Runtime: Docker
Build Command: (hagyja üresen)
Start Command: (hagyja üresen)
```

### 2.4 Environment Variables beállítása
A "Environment" részben add hozzá:
```
Key: ASPNETCORE_ENVIRONMENT
Value: Production

Key: ASPNETCORE_URLS  
Value: http://0.0.0.0:$PORT
```

### 2.5 Deploy indítása
1. Kattints "Create Web Service"
2. Render elkezdi az építést - ez 3-5 percet vesz igénybe
3. Kövesd a "Logs" tab-ban a folyamatot

## LÉPÉS 3: URL lekérése és tesztelés

### 3.1 Publikus URL megszerzése
1. Ha a deploy sikeres, látni fogod a zöld "Live" státuszt
2. A publikus URL itt lesz: `https://signalr-shutdown-server-XXXXX.onrender.com`
3. Másold ki ezt az URL-t!

### 3.2 Tesztelés
1. Nyisd meg az URL-t böngészőben
2. Látnod kell: "SignalR Shutdown Server is running!"
3. Ha ezt látod = SIKERES! 🎉

## LÉPÉS 4: URL-ek frissítése a rendszerben

### 4.1 Windows Service frissítése
1. Nyisd meg: `WindowsService/appsettings.json`
2. Cseréld ki a HubUrl-t a Render URL-edre:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "SignalR": {
    "HubUrl": "https://signalr-shutdown-server-XXXXX.onrender.com/shutdownhub"
  }
}
```

### 4.2 Web App frissítése
1. Nyisd meg: `WebApp/index.html`
2. Keress rá: `withUrl("http://localhost:5000/shutdownhub")`
3. Cseréld ki a Render URL-edre:
```javascript
.withUrl("https://signalr-shutdown-server-XXXXX.onrender.com/shutdownhub")
```

4. Ugyanez a `WebApp/mobile.html` fájlban:
```javascript
const CLOUD_URL = "https://signalr-shutdown-server-XXXXX.onrender.com/shutdownhub";
```

## LÉPÉS 5: Windows Service újratelepítése

### 5.1 Service leállítása és eltávolítása
1. Nyiss PowerShell-t ADMIN jogokkal
2. Navigálj a projekt mappájába:
```powershell
cd "c:\Users\User\Desktop\geplallito"
```
3. Futtasd az eltávolító scriptet:
```powershell
.\uninstall-service.ps1
```

### 5.2 Újraépítés frissített konfigurációval
```powershell
cd WindowsService
dotnet build -c Release
```

### 5.3 Service újratelepítése
```powershell
cd ..
.\install-service.ps1
```

### 5.4 Service ellenőrzése
```powershell
.\check-service.ps1
```

## LÉPÉS 6: Teljes rendszer tesztelése

### 6.1 Windows Service kapcsolat ellenőrzése
1. Nyisd meg az Event Viewer-t (Windows + X → Event Viewer)
2. Menj: Applications and Services Logs → RemoteShutdownService
3. Látnod kell: "Connected to SignalR hub" üzenetet
4. Ha látod = a PC csatlakozott a felhő szerverhez! ✅

### 6.2 Web App tesztelése
1. Nyisd meg: `WebApp/index.html` böngészőben
2. Látnod kell: "✅ Sikeresen csatlakozva a szerverhez!"
3. A PC-d meg kell jelenjen a listában
4. Próbáld ki a "Leállítás" gombot (óvatosan!)

### 6.3 Mobil App tesztelése
1. Telefonon nyisd meg: `WebApp/mobile.html`
2. Vagy másold ki a teljes fájl tartalmát és mentsd .html kiterjesztéssel
3. Upload-old valahova (pl. Google Drive) és nyisd meg onnan
4. Látnod kell ugyanazt mint a web app-ban

## LÉPÉS 7: Hibaelhárítás

### 7.1 "Service nem csatlakozik"
- Ellenőrizd a `appsettings.json`-ben az URL-t
- Rebuild: `dotnet build -c Release`
- Service restart: `.\uninstall-service.ps1` majd `.\install-service.ps1`

### 7.2 "Web app nem csatlakozik"  
- Ellenőrizd a böngésző Console-t (F12)
- Ellenőrizd az URL-t a JavaScript kódban
- Próbáld meg inkognito módban

### 7.3 "Render app alszik"
- Az ingyenes Render 15 perc inaktivitás után "elalszik"
- Első kérésre 10-30 másodperc alatt "felébred"
- Ez normális működés az ingyenes tier-ben

### 7.4 "CORS hibák"
- A SignalR szerver már be van állítva CORS-ra
- Ha mégis problémák vannak, ellenőrizd a böngésző console-t

## EREDMÉNY 🎉

Ha minden jól ment:
- ✅ Windows Service fut és csatlakozik a felhő szerverhez
- ✅ Web app működik és látja a PC-t  
- ✅ Mobil app működik telefonon
- ✅ Bárhonnan le tudod állítani a PC-det!

## Költségek
- **Render.com**: 750 óra/hó ingyenes (körülbelül egész hónap)
- **GitHub**: teljesen ingyenes public repo-khoz
- **Összesen**: 0 Ft/hó! 💸

---

# ALTERNATÍVÁK (ha Render nem megy)

## Opció 2: Vercel (ingyenes)
1. https://vercel.com → Sign up with GitHub
2. Import repository → válaszd a SignalRServer mappát  
3. Framework Preset: Other
4. Build Command: `dotnet publish -c Release -o out`
5. Output Directory: `out`

## Opció 3: Netlify (ingyenes)
1. https://netlify.com → Sign up with GitHub
2. Sites → Add new site → Import from Git
3. Build command: `dotnet publish -c Release -o dist`
4. Publish directory: `dist`

## Opció 4: Heroku (ingyenes tier megszűnt, de van dyno credit)
1. https://heroku.com → Create account
2. Install Heroku CLI
3. `heroku create your-app-name`
4. `git push heroku main`
