using Microsoft.AspNetCore.SignalR.Client;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("=== SignalR Connection Test ===");
        
        var deviceId = Environment.MachineName + "_TEST";
        var serverUrl = "https://remote-shutdown-system.onrender.com/shutdownhub";
        
        Console.WriteLine($"Device ID: {deviceId}");
        Console.WriteLine($"Server URL: {serverUrl}");
        Console.WriteLine();
        
        var connection = new HubConnectionBuilder()
            .WithUrl(serverUrl)
            .Build();

        connection.Closed += async (error) =>
        {
            Console.WriteLine($"Connection closed: {error?.Message}");
        };

        try
        {
            Console.WriteLine("Connecting...");
            await connection.StartAsync();
            Console.WriteLine("✅ Connected successfully!");
            
            // Listen for device list
            var deviceListReceived = new TaskCompletionSource<List<object>>();
            connection.On<List<object>>("DeviceList", (devices) =>
            {
                deviceListReceived.SetResult(devices);
            });
            
            Console.WriteLine("Registering device...");
            await connection.InvokeAsync("RegisterDevice", deviceId, Environment.MachineName);
            Console.WriteLine("✅ Device registered!");
            
            // Wait a bit for registration to complete
            await Task.Delay(1000);
            
            Console.WriteLine("Getting connected devices...");
            await connection.InvokeAsync("GetConnectedDevices");
            
            // Wait for device list response
            var devices = await deviceListReceived.Task;
            Console.WriteLine($"Connected devices count: {devices.Count}");
            foreach (var device in devices)
            {
                Console.WriteLine($"  - {device}");
            }
            
            Console.WriteLine("\nPress any key to disconnect...");
            Console.ReadKey();
            
            await connection.StopAsync();
            Console.WriteLine("Disconnected.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error: {ex.Message}");
            Console.WriteLine($"Stack: {ex.StackTrace}");
        }
    }
}
