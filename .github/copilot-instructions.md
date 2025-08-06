<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Remote Shutdown System - Copilot Instructions

Ez egy távoli PC leállító rendszer, amely három fő komponensből áll:

## Projekt struktúra
- **WindowsService/**: .NET 8 Worker Service - háttérben futó Windows szolgáltatás
- **MobileApp/**: React Native + Expo alkalmazás - cross-platform mobil app
- **SignalRServer/**: ASP.NET Core SignalR hub - központi kommunikációs szerver

## Technológiai stack
- **Backend**: .NET 8, ASP.NET Core, SignalR
- **Mobile**: React Native, Expo, TypeScript/JavaScript
- **Kommunikáció**: SignalR WebSocket connections
- **Platform**: Windows Service, iOS/Android mobil alkalmazás

## Főbb funkciók
- Távoli számítógép leállítás/újraindítás
- Valós idejű eszköz állapot monitoring
- Cross-platform mobil support
- Automatikus eszköz felismerés és regisztráció

## Fejlesztési irányelvek
- Használj async/await mintákat a .NET kódban
- Implementálj megfelelő error handling-et
- Kövesd a React Native best practices-eket
- Biztosítsd a cross-platform kompatibilitást
- Logold a kritikus műveleteket

## Biztonsági megfontolások
- Ez egy proof-of-concept projekt
- Éles használathoz implementálj hitelesítést
- Használj HTTPS-t minden kommunikációhoz
- Korlátozd a hozzáférést megfelelő authorization-nal
