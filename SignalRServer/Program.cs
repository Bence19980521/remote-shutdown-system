using SignalRServer.Hubs;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddSignalR();
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

// Enable static files
app.UseStaticFiles();

app.UseRouting();
app.UseCors();

app.MapHub<ShutdownHub>("/shutdownhub");

app.MapGet("/", () => "SignalR Shutdown Server is running!");

app.MapGet("/devices", (IServiceProvider serviceProvider) =>
{
    // This would require accessing the hub's static data
    // For now, return a simple message
    return Results.Ok("Use SignalR hub for device management");
});

app.Run();
