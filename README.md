<<<<<<< HEAD
# Remote Shutdown System

Egy komplex rendszer, amely lehetővé teszi a számítógép távoli leállítását mobil alkalmazásból, akkor is, ha a telefon és a gép nem ugyanazon a hálózaton van.

## Rendszer komponensei

### 1. Windows Service (RemoteShutdownService)
- **Célja**: Háttérben futó szolgáltatás, amely automatikusan elindul a rendszerindításkor
- **Funkciók**:
  - SignalR kapcsolat fenntartása a szerverrel
  - Shutdown/restart parancsok fogadása és végrehajtása
  - Rendszer állapot jelentések küldése
  - Automatikus újracsatlakozás hálózati problémák esetén

### 2. Mobile App (React Native + Expo)
- **Célja**: Cross-platform mobil alkalmazás iOS és Android készülékekre
- **Funkciók**:
  - Csatlakoztatott eszközök listázása
  - Távoli shutdown/restart parancsok küldése
  - Eszköz állapot lekérdezése
  - Szerver konfiguráció beállítása

### 3. SignalR Server (ASP.NET Core)
- **Célja**: Központi kommunikációs szerver a felhőben
- **Funkciók**:
  - Valós idejű kommunikáció az eszközök és mobil app között
  - Eszköz regisztráció és állapot követés
  - Parancsok továbbítása a megfelelő eszközökre
  - CORS támogatás a cross-origin kommunikációhoz

## Telepítés és konfiguráció

### Előfeltételek
- .NET 8.0 SDK (Windows Service és SignalR Server)
- Node.js és npm (Mobil alkalmazás)
- Expo CLI (Mobil alkalmazás)

### SignalR Server telepítése

1. **Azure-ban vagy más felhő szolgáltatónál** hozz létre egy web app-ot
2. Telepítsd a SignalR Server projektet:
   ```bash
   cd SignalRServer
   dotnet publish -c Release
   ```
3. Töltsd fel az Azure-ba vagy saját szerverre
4. Jegyezd fel a szerver URL-jét (pl. `https://your-app.azurewebsites.net`)

### Windows Service telepítése

1. **Építsd le a projektet**:
   ```bash
   cd WindowsService
   dotnet publish -c Release -r win-x64 --self-contained
   ```

2. **Frissítsd a szerver URL-t** a `Worker.cs` fájlban:
   ```csharp
   private readonly string _serverUrl = "https://your-app.azurewebsites.net/shutdownhub";
   ```

3. **Telepítsd Windows Service-ként** (Adminisztrátori jogosultságokkal):
   ```cmd
   sc create RemoteShutdownService binPath="C:\path\to\your\RemoteShutdownService.exe"
   sc config RemoteShutdownService start=auto
   sc start RemoteShutdownService
   ```

### Mobil alkalmazás telepítése

1. **Telepítsd a függőségeket**:
   ```bash
   cd MobileApp
   npm install
   ```

2. **Indítsd el fejlesztési módban**:
   ```bash
   npx expo start
   ```

3. **Frissítsd a szerver URL-t** az alkalmazásban vagy használd a beállítások menüt

## Használat

### Első indítás
1. Indítsd el a SignalR szervert
2. Telepítsd és indítsd el a Windows Service-t a számítógépeken
3. Nyisd meg a mobil alkalmazást
4. Állítsd be a szerver URL-t a beállításokban
5. Az eszközök automatikusan megjelennek a listában

### Parancsok küldése
- **Shutdown**: Azonnal leállítja a kiválasztott számítógépet
- **Restart**: Újraindítja a kiválasztott számítógépet  
- **Status**: Lekéri a rendszer állapot információkat

## Biztonsági megfontolások

⚠️ **FONTOS BIZTONSÁGI FIGYELMEZTETÉSEK:**

1. **Hitelesítés**: A jelenlegi verzió nem tartalmaz hitelesítést. Éles használatra implementálj:
   - JWT token alapú hitelesítést
   - API kulcsokat
   - Felhasználói szerepköröket

2. **Titkosítás**: Használj HTTPS-t minden kommunikációhoz

3. **Hozzáférés korlátozás**: 
   - Korlátozd a SignalR hub hozzáférését
   - Implementálj IP whitelist-et
   - Használj VPN-t ha szükséges

4. **Auditálás**: Logold minden shutdown/restart műveletet

## Fejlesztési lehetőségek

- **Ütemezett műveletek**: Időzített shutdown/restart
- **Biztonsági kamerák**: Képek küldése a gépről shutdown előtt
- **Fájl átvitel**: Fájlok letöltése a gépről
- **Képernyő megosztás**: Távoli desktop funkciók
- **Többfelhasználós**: Családi/céges használatra optimalizálás

## Hibaelhárítás

### Windows Service nem indul
- Ellenőrizd a Windows Event Log-ot
- Győződj meg róla, hogy a .NET runtime telepítve van
- Ellenőrizd a fájl jogosultságokat

### Mobil app nem csatlakozik
- Ellenőrizd a szerver URL-t
- Győződj meg róla, hogy a szerver elérhető
- Ellenőrizd a tűzfal beállításokat

### Eszközök nem jelennek meg
- Ellenőrizd a Windows Service állapotát
- Nézd meg a SignalR szerver logokat
- Győződj meg róla, hogy mindkét oldal ugyanahhoz a szerverhez csatlakozik

## Támogatott platformok

- **Windows Service**: Windows 10/11, Windows Server 2019+
- **Mobil App**: iOS 12+, Android 8+
- **SignalR Server**: Linux, Windows, macOS (Docker támogatással)

## Licenc

Ez a projekt oktatási célokra készült. Éles használat előtt implementálj megfelelő biztonsági intézkedéseket.
=======
# remote-shutdown-system
>>>>>>> 3d1fc2e111ea47224c0ee5733fca696c9a452f93
