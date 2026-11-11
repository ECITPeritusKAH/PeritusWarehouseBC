using PeritusWarehouse.Web.Services;
using PeritusWarehouse.Web.Components;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.Configure<BcOptions>(builder.Configuration.GetSection(BcOptions.Section));
if (builder.Configuration.GetSection(BcOptions.Section).Get<BcOptions>()?.IsConfigured == true)
{
    builder.Services.AddTransient<BcErrorHandler>();
    builder.Services.AddHttpClient<IBcClient, BcClient>().AddHttpMessageHandler<BcErrorHandler>();
}
else
    builder.Services.AddSingleton<IBcClient, DemoBcClient>();

builder.Services.AddScoped<UserSession>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}
app.UseStatusCodePagesWithReExecute("/not-found", createScopeForStatusCodePages: true);
app.UseHttpsRedirection();

app.UseAntiforgery();

app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
