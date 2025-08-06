using Microsoft.AspNetCore.SignalR;
using System.Collections.Concurrent;

namespace SignalRServer.Hubs;

public class ShutdownHub : Hub
{
    private static readonly ConcurrentDictionary<string, DeviceInfo> ConnectedDevices = new();
    private readonly ILogger<ShutdownHub> _logger;

    public ShutdownHub(ILogger<ShutdownHub> logger)
    {
        _logger = logger;
    }

    public override async Task OnConnectedAsync()
    {
        _logger.LogInformation("Client connected: {ConnectionId}", Context.ConnectionId);
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        _logger.LogInformation("Client disconnected: {ConnectionId}", Context.ConnectionId);
        
        // Remove device from connected devices
        var deviceToRemove = ConnectedDevices.Values.FirstOrDefault(d => d.ConnectionId == Context.ConnectionId);
        if (deviceToRemove != null)
        {
            ConnectedDevices.TryRemove(deviceToRemove.DeviceId, out _);
            await Clients.All.SendAsync("DeviceDisconnected", deviceToRemove.DeviceId);
        }
        
        await base.OnDisconnectedAsync(exception);
    }

    public async Task RegisterDevice(string deviceId, string deviceName)
    {
        var deviceInfo = new DeviceInfo
        {
            DeviceId = deviceId,
            DeviceName = deviceName,
            ConnectionId = Context.ConnectionId,
            LastSeen = DateTime.UtcNow
        };

        ConnectedDevices.AddOrUpdate(deviceId, deviceInfo, (key, oldValue) =>
        {
            oldValue.ConnectionId = Context.ConnectionId;
            oldValue.LastSeen = DateTime.UtcNow;
            return oldValue;
        });

        _logger.LogInformation("Device registered: {DeviceId} ({DeviceName})", deviceId, deviceName);
        
        // Notify all clients about the new device
        await Clients.All.SendAsync("DeviceConnected", deviceInfo);
        
        // Send current device list to the newly connected client
        await Clients.Caller.SendAsync("DeviceList", ConnectedDevices.Values.ToList());
    }

    public async Task ShutdownDevice(string deviceId)
    {
        _logger.LogInformation("Shutdown requested for device: {DeviceId}", deviceId);
        
        if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            await Clients.Client(device.ConnectionId).SendAsync("ShutdownCommand");
            _logger.LogInformation("Shutdown command sent to device: {DeviceId}", deviceId);
        }
        else
        {
            _logger.LogWarning("Device not found: {DeviceId}", deviceId);
            await Clients.Caller.SendAsync("Error", $"Device {deviceId} not found");
        }
    }

    public async Task RestartDevice(string deviceId)
    {
        _logger.LogInformation("Restart requested for device: {DeviceId}", deviceId);
        
        if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            await Clients.Client(device.ConnectionId).SendAsync("RestartCommand");
            _logger.LogInformation("Restart command sent to device: {DeviceId}", deviceId);
        }
        else
        {
            _logger.LogWarning("Device not found: {DeviceId}", deviceId);
            await Clients.Caller.SendAsync("Error", $"Device {deviceId} not found");
        }
    }

    public async Task GetConnectedDevices()
    {
        await Clients.Caller.SendAsync("DeviceList", ConnectedDevices.Values.ToList());
    }

    public async Task UpdateDeviceStatus(string deviceId, string status)
    {
        if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            device.LastSeen = DateTime.UtcNow;
            await Clients.All.SendAsync("DeviceStatusUpdate", deviceId, status);
        }
    }
}

public class DeviceInfo
{
    public string DeviceId { get; set; } = string.Empty;
    public string DeviceName { get; set; } = string.Empty;
    public string ConnectionId { get; set; } = string.Empty;
    public DateTime LastSeen { get; set; }
}
