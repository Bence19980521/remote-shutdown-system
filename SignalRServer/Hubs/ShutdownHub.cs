<<<<<<< HEAD
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
    public async Task RegisterDevice(string deviceId, string deviceName)
    {
        var deviceInfo = new DeviceInfo
        {
            DeviceId = deviceId,
            DeviceName = deviceName,
            ConnectionId = Context.ConnectionId,
            LastSeen = DateTime.UtcNow
        };
        ConnectedDevices.AddOrUpdate(deviceId, deviceInfo, (key, oldValue) => deviceInfo);
        
        _logger.LogInformation($"Device registered: {deviceName} ({deviceId})");
        
        // Notify all clients about the new device
        await Clients.All.SendAsync("DeviceRegistered", deviceId, deviceName);
    }
    public async Task GetDevices()
    {
        var onlineDevices = ConnectedDevices.Values
            .Where(d => DateTime.UtcNow.Subtract(d.LastSeen).TotalMinutes < 5)
            .ToList();
        foreach (var device in onlineDevices)
        {
            await Clients.Caller.SendAsync("DeviceRegistered", device.DeviceId, device.DeviceName);
        }
    }
    public async Task Shutdown(string deviceId)
    {
        _logger.LogWarning($"Shutdown command received for device: {deviceId}");
        
        if (deviceId == "ALL")
        {
            // Send shutdown to all connected devices
            var deviceConnections = ConnectedDevices.Values.Select(d => d.ConnectionId).ToList();
            await Clients.Clients(deviceConnections).SendAsync("Shutdown", deviceId);
        }
        else if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            await Clients.Client(device.ConnectionId).SendAsync("Shutdown", deviceId);
        }
        else
        {
            await Clients.Caller.SendAsync("Error", $"Device {deviceId} not found or offline");
        }
    }
    public async Task Restart(string deviceId)
    {
        _logger.LogWarning($"Restart command received for device: {deviceId}");
        
        if (deviceId == "ALL")
        {
            // Send restart to all connected devices
            var deviceConnections = ConnectedDevices.Values.Select(d => d.ConnectionId).ToList();
            await Clients.Clients(deviceConnections).SendAsync("Restart", deviceId);
        }
        else if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            await Clients.Client(device.ConnectionId).SendAsync("Restart", deviceId);
        }
        else
        {
            await Clients.Caller.SendAsync("Error", $"Device {deviceId} not found or offline");
        }
    }
    public async Task GetStatus(string deviceId)
    {
        _logger.LogInformation($"Status request for device: {deviceId}");
        
        if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            await Clients.Client(device.ConnectionId).SendAsync("GetStatus", deviceId);
        }
        else
        {
            await Clients.Caller.SendAsync("Error", $"Device {deviceId} not found or offline");
        }
    }
    public async Task ShutdownConfirmation(string deviceId, string message)
    {
        _logger.LogInformation($"Shutdown confirmation from {deviceId}: {message}");
        await Clients.All.SendAsync("ShutdownConfirmation", deviceId, message);
    }
    public async Task RestartConfirmation(string deviceId, string message)
    {
        _logger.LogInformation($"Restart confirmation from {deviceId}: {message}");
        await Clients.All.SendAsync("RestartConfirmation", deviceId, message);
    }
    public async Task DeviceStatus(string deviceId, object status)
    {
        _logger.LogInformation($"Status received from {deviceId}");
        await Clients.All.SendAsync("DeviceStatus", deviceId, status);
    }
    public override async Task OnConnectedAsync()
    {
        _logger.LogInformation($"Client connected: {Context.ConnectionId}");
        await base.OnConnectedAsync();
    }
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        _logger.LogInformation($"Client disconnected: {Context.ConnectionId}");
        
        // Find and remove the disconnected device
        var disconnectedDevice = ConnectedDevices.Values.FirstOrDefault(d => d.ConnectionId == Context.ConnectionId);
        if (disconnectedDevice != null)
        {
            ConnectedDevices.TryRemove(disconnectedDevice.DeviceId, out _);
            await Clients.All.SendAsync("DeviceDisconnected", disconnectedDevice.DeviceId);
            _logger.LogInformation($"Device disconnected: {disconnectedDevice.DeviceName}");
        }
        await base.OnDisconnectedAsync(exception);
    }
}
public class DeviceInfo
{
    public string DeviceId { get; set; } = string.Empty;
    public string DeviceName { get; set; } = string.Empty;
    public string ConnectionId { get; set; } = string.Empty;
    public DateTime LastSeen { get; set; }
}
=======
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
    public async Task RegisterDevice(string deviceId, string deviceName)
    {
        var deviceInfo = new DeviceInfo
        {
            DeviceId = deviceId,
            DeviceName = deviceName,
            ConnectionId = Context.ConnectionId,
            LastSeen = DateTime.UtcNow
        };
        ConnectedDevices.AddOrUpdate(deviceId, deviceInfo, (key, oldValue) => deviceInfo);
        
        _logger.LogInformation($"Device registered: {deviceName} ({deviceId})");
        
        // Notify all clients about the new device
        await Clients.All.SendAsync("DeviceRegistered", deviceId, deviceName);
    }
    public async Task GetDevices()
    {
        var onlineDevices = ConnectedDevices.Values
            .Where(d => DateTime.UtcNow.Subtract(d.LastSeen).TotalMinutes < 5)
            .ToList();
        foreach (var device in onlineDevices)
        {
            await Clients.Caller.SendAsync("DeviceRegistered", device.DeviceId, device.DeviceName);
        }
    }
    public async Task Shutdown(string deviceId)
    {
        _logger.LogWarning($"Shutdown command received for device: {deviceId}");
        
        if (deviceId == "ALL")
        {
            // Send shutdown to all connected devices
            var deviceConnections = ConnectedDevices.Values.Select(d => d.ConnectionId).ToList();
            await Clients.Clients(deviceConnections).SendAsync("Shutdown", deviceId);
        }
        else if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            await Clients.Client(device.ConnectionId).SendAsync("Shutdown", deviceId);
        }
        else
        {
            await Clients.Caller.SendAsync("Error", $"Device {deviceId} not found or offline");
        }
    }
    public async Task Restart(string deviceId)
    {
        _logger.LogWarning($"Restart command received for device: {deviceId}");
        
        if (deviceId == "ALL")
        {
            // Send restart to all connected devices
            var deviceConnections = ConnectedDevices.Values.Select(d => d.ConnectionId).ToList();
            await Clients.Clients(deviceConnections).SendAsync("Restart", deviceId);
        }
        else if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            await Clients.Client(device.ConnectionId).SendAsync("Restart", deviceId);
        }
        else
        {
            await Clients.Caller.SendAsync("Error", $"Device {deviceId} not found or offline");
        }
    }
    public async Task GetStatus(string deviceId)
    {
        _logger.LogInformation($"Status request for device: {deviceId}");
        
        if (ConnectedDevices.TryGetValue(deviceId, out var device))
        {
            await Clients.Client(device.ConnectionId).SendAsync("GetStatus", deviceId);
        }
        else
        {
            await Clients.Caller.SendAsync("Error", $"Device {deviceId} not found or offline");
        }
    }
    public async Task ShutdownConfirmation(string deviceId, string message)
    {
        _logger.LogInformation($"Shutdown confirmation from {deviceId}: {message}");
        await Clients.All.SendAsync("ShutdownConfirmation", deviceId, message);
    }
    public async Task RestartConfirmation(string deviceId, string message)
    {
        _logger.LogInformation($"Restart confirmation from {deviceId}: {message}");
        await Clients.All.SendAsync("RestartConfirmation", deviceId, message);
    }
    public async Task DeviceStatus(string deviceId, object status)
    {
        _logger.LogInformation($"Status received from {deviceId}");
        await Clients.All.SendAsync("DeviceStatus", deviceId, status);
    }
    public override async Task OnConnectedAsync()
    {
        _logger.LogInformation($"Client connected: {Context.ConnectionId}");
        await base.OnConnectedAsync();
    }
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        _logger.LogInformation($"Client disconnected: {Context.ConnectionId}");
        
        // Find and remove the disconnected device
        var disconnectedDevice = ConnectedDevices.Values.FirstOrDefault(d => d.ConnectionId == Context.ConnectionId);
        if (disconnectedDevice != null)
        {
            ConnectedDevices.TryRemove(disconnectedDevice.DeviceId, out _);
            await Clients.All.SendAsync("DeviceDisconnected", disconnectedDevice.DeviceId);
            _logger.LogInformation($"Device disconnected: {disconnectedDevice.DeviceName}");
        }
        await base.OnDisconnectedAsync(exception);
    }
}
public class DeviceInfo
{
    public string DeviceId { get; set; } = string.Empty;
    public string DeviceName { get; set; } = string.Empty;
    public string ConnectionId { get; set; } = string.Empty;
    public DateTime LastSeen { get; set; }
}
>>>>>>> 3d1fc2e111ea47224c0ee5733fca696c9a452f93
