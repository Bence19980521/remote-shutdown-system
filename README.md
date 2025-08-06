# Remote Shutdown System

Egy komplex rendszer, amely lehetővé teszi a számítógép távoli leállítását mobil alkalmazásból, akkor is, ha a telefon és a gép nem ugyanazon a hálózaton van.

## 📱 Mobil App Használat

**Telefonon nyisd meg**: `https://remote-shutdown-system.onrender.com/mobile.html`

### PWA Telepítés:
- **Android**: Chrome → "Hozzáadás a kezdőképernyőhöz"
- **iPhone**: Safari → Megosztás → "Hozzáadás a kezdőképernyőhöz"

## 🏗️ Rendszer komponensei

### 1. Windows Service (RemoteShutdownService)
- **Célja**: Háttérben futó szolgáltatás, amely automatikusan elindul a rendszerindításkor
- **Funkciók**:
  - SignalR kapcsolat fenntartása a szerverrel
  - Shutdown/restart parancsok fogadása és végrehajtása
  - Rendszer állapot jelentések küldése
  - Automatikus újracsatlakozás hálózati problémák esetén

### 2. Web App (PWA)
- **Célja**: Cross-platform mobil alkalmazás iOS és Android készülékekre
- **Funkciók**:
  - Csatlakoztatott eszközök listázása
  - Távoli shutdown/restart parancsok küldése
  - Eszköz állapot lekérdezése
  - Telepíthető PWA alkalmazás

### 3. SignalR Server (ASP.NET Core)
- **Célja**: Központi kommunikációs szerver a felhőben (Render.com)
- **Funkciók**:
  - Valós idejű kommunikáció WebSocket-en keresztül
  - Eszköz regisztráció és menedzsment
  - Parancs továbbítás a mobil app és Windows szolgáltatás között
  - Eszköz állapot nyomon követése

## 🚀 Telepítés és Beállítás

### Windows Service telepítése:
```powershell
# Admin PowerShell-ben:
.\install-service.ps1
```

### Service ellenőrzése:
```powershell
.\check-service.ps1
```

### Service eltávolítása:
```powershell
.\uninstall-service.ps1
```

## 🔧 Technológiai Stack

- **Backend**: .NET 8, ASP.NET Core, SignalR
- **Frontend**: HTML5, CSS3, JavaScript (PWA)
- **Platform**: Windows Service, Web Browser
- **Hosting**: Render.com (cloud deployment)
- **Kommunikáció**: SignalR WebSocket connections

## 📡 Hálózati Architektúra

```
[Mobil Device] ↔ [Internet] ↔ [Render.com SignalR Server] ↔ [Internet] ↔ [Windows PC Service]
```

A rendszer így működik bárhonnan a világból, nem kell ugyanazon a hálózaton lenni!

## 🛠️ Fejlesztési Útmutató

### Projekt buildelése:
```powershell
# Windows Service
cd WindowsService
dotnet restore
dotnet build

# SignalR Server
cd SignalRServer
dotnet restore
dotnet build
```

### Helyi tesztelés:
```powershell
# SignalR Server indítása
cd SignalRServer
dotnet run

# Böngészőben: http://localhost:5000
```

## 📄 Biztonsági Megjegyzések

⚠️ **Ez egy proof-of-concept projekt!**

Éles használathoz javasolt:
- Hitelesítés implementálása
- HTTPS használata
- API kulcsok bevezetése
- Hozzáférés korlátozása

## 📞 Támogatás

Ha problémába ütközöl:
1. Ellenőrizd a Windows Service fut-e: `.\check-service.ps1`
2. Nézd meg a log fájlokat
3. Ellenőrizd az internetkapcsolatot
4. Próbáld újra telepíteni a szolgáltatást
