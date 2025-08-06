# Remote Shutdown System - Telepítési útmutató

## Gyors telepítés (Windows)

### 1. Előfeltételek telepítése

**Töltsd le és telepítsd:**
- .NET 8.0 SDK: https://dotnet.microsoft.com/download/dotnet/8.0
- Node.js: https://nodejs.org/ (LTS verzió)
- Git: https://git-scm.com/

### 2. Projekt építése

Nyiss egy PowerShell terminált **Rendszergazdaként** és futtasd:

```powershell
# Windows Service építése
cd WindowsService
dotnet restore
dotnet build -c Release
dotnet publish -c Release -r win-x64 --self-contained

# SignalR Server építése  
cd ../SignalRServer
dotnet restore
dotnet build -c Release
dotnet publish -c Release

# Mobil app függőségek telepítése
cd ../MobileApp
npm install
```

### 3. SignalR Server telepítése

**Opció A: Helyi fejlesztési szerver**
```powershell
cd SignalRServer
dotnet run
# A szerver fut: http://localhost:5000
```

**Opció B: Azure App Service (ajánlott éles használatra)**
1. Hozz létre egy Azure App Service-t
2. Töltsd fel a `SignalRServer/bin/Release/net8.0/publish` mappát
3. Jegyezd fel az URL-t (pl. `https://your-app.azurewebsites.net`)

### 4. Windows Service telepítése

```powershell
# Frissítsd a szerver URL-t a Worker.cs-ben (sorban 15)
# Építsd le a service-t
cd WindowsService
dotnet publish -c Release -r win-x64 --self-contained

# Telepítsd Windows Service-ként (Rendszergazdaként!)
$servicePath = "C:\Users\User\Desktop\geplallito\WindowsService\bin\Release\net8.0\win-x64\publish\RemoteShutdownService.exe"
sc.exe create RemoteShutdownService binPath= $servicePath
sc.exe config RemoteShutdownService start= auto
sc.exe start RemoteShutdownService

# Ellenőrizd a szolgáltatás állapotát
sc.exe query RemoteShutdownService
```

### 5. Mobil alkalmazás indítása

```powershell
cd MobileApp
npx expo start
```

Ezután:
1. Telepítsd az Expo Go alkalmazást a telefonodra
2. Scanneld be a QR kódot
3. Az alkalmazásban állítsd be a szerver URL-t
4. Az eszközeid megjelennek a listában

## Hibaelhárítás

### "Access denied" hiba Windows Service telepítésekor
- Futtasd a PowerShell-t **Rendszergazdaként**
- Ellenőrizd a Windows Defender beállításokat

### Mobil app nem csatlakozik
- Győződj meg róla, hogy a SignalR szerver fut
- Ellenőrizd a szerver URL-t az alkalmazás beállításaiban
- Ha helyi szervert használsz, cseréld `localhost`-ot a gép IP címére

### Windows Service nem indul
```powershell
# Nézd meg a Windows Event Log-ot
Get-EventLog -LogName Application -Source RemoteShutdownService -Newest 10

# Vagy indítsd console módban teszteléshez:
cd WindowsService\bin\Release\net8.0\win-x64\publish
.\RemoteShutdownService.exe --console
```

## Biztonsági figyelmeztetés

⚠️ **Ez egy fejlesztési/teszt verzió!** Éles használat előtt:
- Implementálj hitelesítést
- Használj HTTPS-t
- Korlátozd a hozzáférést
- Auditáld a műveleteket

## További segítség

Ha problémába ütközöl:
1. Ellenőrizd a README.md fájlt
2. Nézd meg a logokat
3. Győződj meg róla, hogy minden előfeltétel telepítve van
