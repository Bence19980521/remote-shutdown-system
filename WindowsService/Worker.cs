using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.SignalR.Client;
using System.Diagnostics;
using System.Management;
using Newtonsoft.Json;

namespace RemoteShutdownService;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly IConfiguration _configuration;
    private HubConnection? _connection;
    private readonly string _deviceId;
    private readonly string _serverUrl;

    public Worker(ILogger<Worker> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
        _deviceId = Environment.MachineName + "_" + GetMachineId();
        _serverUrl = _configuration["SignalR:HubUrl"] ?? "http://localhost:5000/shutdownhub";
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ConnectToSignalR();
                
                if (_connection?.State == HubConnectionState.Connected)
                {
                    _logger.LogInformation("Connected to SignalR hub");
                    
                    // Wait for connection to be closed or cancellation
                    await Task.Delay(5000, stoppingToken);
                }
                else
                {
                    _logger.LogWarning("Failed to connect to SignalR hub, retrying in 30 seconds...");
                    await Task.Delay(30000, stoppingToken);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in worker service");
                await Task.Delay(30000, stoppingToken);
            }
        }
    }

    private async Task ConnectToSignalR()
    {
        try
        {
            if (_connection?.State == HubConnectionState.Connected)
                return;

            _connection = new HubConnectionBuilder()
                .WithUrl(_serverUrl)
                .WithAutomaticReconnect()
                .Build();

            // Register device when connected
            _connection.On("RegisterDevice", async () =>
            {
                await _connection.InvokeAsync("RegisterDevice", _deviceId, Environment.MachineName);
                _logger.LogInformation($"Device registered: {_deviceId}");
            });

            // Handle shutdown command
            _connection.On<string>("Shutdown", async (deviceId) =>
            {
                if (deviceId == _deviceId || deviceId == "ALL")
                {
                    _logger.LogWarning($"Shutdown command received for device: {deviceId}");
                    await ShutdownComputer();
                }
            });

            // Handle restart command
            _connection.On<string>("Restart", async (deviceId) =>
            {
                if (deviceId == _deviceId || deviceId == "ALL")
                {
                    _logger.LogWarning($"Restart command received for device: {deviceId}");
                    await RestartComputer();
                }
            });

            // Handle status request
            _connection.On<string>("GetStatus", async (deviceId) =>
            {
                if (deviceId == _deviceId)
                {
                    var status = await GetSystemStatus();
                    await _connection.InvokeAsync("DeviceStatus", _deviceId, status);
                    _logger.LogInformation($"Status sent for device: {_deviceId}");
                }
            });

            await _connection.StartAsync();
            
            // Register this device
            await _connection.InvokeAsync("RegisterDevice", _deviceId, Environment.MachineName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to connect to SignalR hub");
        }
    }

    private async Task ShutdownComputer()
    {
        try
        {
            _logger.LogWarning("Initiating system shutdown...");
            
            // Send confirmation back to mobile app
            if (_connection?.State == HubConnectionState.Connected)
            {
                await _connection.InvokeAsync("ShutdownConfirmation", _deviceId, "Shutdown initiated");
            }

            // Wait a bit for the message to be sent
            await Task.Delay(2000);

            // Execute shutdown command
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "shutdown",
                    Arguments = "/s /t 5", // Shutdown in 5 seconds
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };
            process.Start();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to shutdown computer");
        }
    }

    private async Task RestartComputer()
    {
        try
        {
            _logger.LogWarning("Initiating system restart...");
            
            // Send confirmation back to mobile app
            if (_connection?.State == HubConnectionState.Connected)
            {
                await _connection.InvokeAsync("RestartConfirmation", _deviceId, "Restart initiated");
            }

            // Wait a bit for the message to be sent
            await Task.Delay(2000);

            // Execute restart command
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "shutdown",
                    Arguments = "/r /t 5", // Restart in 5 seconds
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };
            process.Start();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to restart computer");
        }
    }

    private async Task<object> GetSystemStatus()
    {
        try
        {
            var status = new
            {
                MachineName = Environment.MachineName,
                UserName = Environment.UserName,
                OSVersion = Environment.OSVersion.ToString(),
                WorkingSet = Environment.WorkingSet,
                ProcessorCount = Environment.ProcessorCount,
                TickCount = Environment.TickCount64,
                LastBootTime = DateTime.Now.AddMilliseconds(-Environment.TickCount64),
                AvailableMemory = await GetAvailableMemory(),
                CPUUsage = await GetCPUUsage()
            };
            
            return status;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get system status");
            return new { Error = "Failed to get system status" };
        }
    }

    private Task<long> GetAvailableMemory()
    {
        try
        {
            var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_OperatingSystem");
            foreach (ManagementObject mo in searcher.Get())
            {
                return Task.FromResult(Convert.ToInt64(mo["FreePhysicalMemory"]) * 1024); // Convert from KB to bytes
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get available memory");
        }
        return Task.FromResult(0L);
    }

    private Task<float> GetCPUUsage()
    {
        try
        {
            var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_Processor");
            foreach (ManagementObject mo in searcher.Get())
            {
                return Task.FromResult(Convert.ToSingle(mo["LoadPercentage"]));
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get CPU usage");
        }
        return Task.FromResult(0f);
    }

    private string GetMachineId()
    {
        try
        {
            var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_ComputerSystemProduct");
            foreach (ManagementObject mo in searcher.Get())
            {
                return mo["UUID"]?.ToString() ?? Guid.NewGuid().ToString();
            }
            return Guid.NewGuid().ToString();
        }
        catch
        {
            return Guid.NewGuid().ToString();
        }
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        if (_connection != null)
        {
            await _connection.DisposeAsync();
        }
        await base.StopAsync(cancellationToken);
    }
}
