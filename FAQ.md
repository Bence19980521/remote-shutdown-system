# Gyakran Ismételt Kérdések (FAQ)

## Általános kérdések

### Q: Hogyan működik a rendszer?
A: A rendszer három komponensből áll:
1. **Windows Service** - fut a számítógépen háttérben
2. **SignalR Server** - központi kommunikációs szerver (felhőben)
3. **Mobil App** - távoli irányítás telefonról

A kommunikáció valós időben történik WebSocket-en keresztül.

### Q: Biztonságos a rendszer?
A: Ez egy fejlesztési/oktatási verzió. Éles használathoz implementálni kell:
- Felhasználói hitelesítést
- API kulcsokat
- HTTPS titkosítást
- Audit logokat

### Q: Milyen operációs rendszereken fut?
A: 
- **Windows Service**: Windows 10/11, Windows Server 2019+
- **Mobil App**: iOS 12+, Android 8+
- **SignalR Server**: Bármely platform (.NET 8 támogatással)

## Telepítési problémák

### Q: "dotnet" parancs nem található
A: Telepítsd a .NET 8.0 SDK-t: https://dotnet.microsoft.com/download/dotnet/8.0

### Q: Windows Service nem telepíthető
A: 
1. Futtasd a PowerShell-t **Rendszergazdaként**
2. Ellenőrizd a Windows Defender beállításokat
3. Próbáld ki a `install-service.ps1` script-et

### Q: Mobil app nem indul
A: 
1. Telepítsd a Node.js-t és npm-et
2. Futtasd `npm install` a MobileApp mappában
3. Telepítsd az Expo CLI-t: `npm install -g expo-cli`

## Kapcsolódási problémák

### Q: Mobil app nem találja az eszközöket
A: Ellenőrizd:
1. SignalR szerver fut-e
2. Windows Service fut-e (Services.msc-ben)
3. Szerver URL helyes-e az app beállításaiban
4. Tűzfal nem blokkolja-e a kapcsolatot

### Q: "localhost" nem elérhető a telefonról
A: Cseréld a `localhost`-ot a számítógép IP címére:
1. Nyiss parancssort: `ipconfig`
2. Másold ki az IPv4 címet (pl. 192.168.1.100)
3. Használd: `http://192.168.1.100:5000/shutdownhub`

### Q: Azure-ban telepített szerver nem elérhető
A: Ellenőrizd:
1. HTTPS-t használj HTTP helyett
2. CORS beállítások helyesek-e
3. Azure App Service fut-e
4. Nincsenek-e IP korlátozások

## Használati kérdések

### Q: Hogyan állítom le az összes gépet egyszerre?
A: Jelenleg az app egyesével kezeli az eszközöket. Implementálható "Összes leállítása" funkció.

### Q: Lehet időzített leállítást beállítani?
A: A jelenlegi verzió azonnal állít le. Implementálható ütemezett műveletek.

### Q: Hogyan nézhetem meg a rendszer állapotát?
A: Kattints a "Status" gombra az eszköz mellett a mobil appban.

## Hibaelhárítás

### Q: Windows Service leáll magától
A: Nézd meg a Windows Event Log-ot:
```powershell
Get-EventLog -LogName Application -Source RemoteShutdownService -Newest 10
```

### Q: SignalR szerver hibák
A: Ellenőrizd a szerver logokat és a port elérhetőségét.

### Q: Mobil app crashes
A: 
1. Újraindítás
2. Cache törlése
3. App újratelepítése

## Fejlesztési kérdések

### Q: Hogyan adok hozzá új funkciókat?
A: A projekt moduláris felépítésű:
- Windows Service: Worker.cs módosítása
- Mobil App: App.js szerkesztése  
- SignalR Hub: ShutdownHub.cs bővítése

### Q: Hogyan implementálom a hitelesítést?
A: 
1. JWT token-ek hozzáadása
2. SignalR hub authorization
3. Mobil app login screen
4. Felhasználói szerepkörök

### Q: Támogatott-e más platform?
A: Linux/macOS Windows Service helyett systemd/launchd service-eket igényel.

## Teljesítmény

### Q: Mennyire terheli a rendszert?
A: Minimális erőforrásigény:
- RAM: ~20-50 MB
- CPU: <1% idle állapotban
- Hálózat: ~1 KB/perc heartbeat

### Q: Hány eszközt támogat?
A: Nincs beépített limit, de függ a SignalR szerver kapacitásától.

## Támogatás

### Q: Hol kaphatok segítséget?
A: 
1. README.md és INSTALL.md dokumentáció
2. GitHub Issues (ha publikus repo)
3. Windows Event Log hibák esetén
4. SignalR szerver logok

### Q: Hogyan jelentek hibát?
A: 
1. Másold ki a hibaüzenetet
2. Add meg a lépéseket a reprodukáláshoz
3. Csatold a releváns log fájlokat
4. Jelezd az operációs rendszer verzióját
