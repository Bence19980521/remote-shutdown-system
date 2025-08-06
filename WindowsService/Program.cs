using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace RemoteShutdownService;

public class Program
{
    public static async Task Main(string[] args)
    {
        // Check if running as console app for testing
        if (args.Contains("--console"))
        {
            await CreateHostBuilder(args).Build().RunAsync();
        }
        else
        {
            // Run as Windows Service
            await CreateHostBuilder(args).Build().RunAsync();
        }
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .UseWindowsService(options =>
            {
                options.ServiceName = "RemoteShutdownService";
            })
            .ConfigureServices((hostContext, services) =>
            {
                services.AddHostedService<Worker>();
            })
            .ConfigureLogging((context, logging) =>
            {
                logging.ClearProviders();
                logging.AddConsole();
                logging.AddEventLog(settings =>
                {
                    settings.SourceName = "RemoteShutdownService";
                });
            });
}
