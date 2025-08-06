# Use the official .NET 8 runtime as a base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

# Use the .NET 8 SDK for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["SignalRServer.csproj", "./"]
RUN dotnet restore "./SignalRServer.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "SignalRServer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SignalRServer.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SignalRServer.dll"]
