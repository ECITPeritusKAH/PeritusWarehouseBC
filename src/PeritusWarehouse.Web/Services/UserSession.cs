using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;

namespace PeritusWarehouse.Web.Services;

// Holds the signed-in warehouse user for the lifetime of the browser tab (session storage).
public sealed class UserSession(ProtectedSessionStorage storage, IBcClient bc)
{
    private const string Key = "pw-user-id";
    private bool _loaded;

    public string UserId { get; private set; } = "";
    public List<string> Locations { get; private set; } = [];
    public bool IsRegistered => Locations.Count > 0;
    public event Action? Changed;

    public async Task LoadAsync()
    {
        if (_loaded) return;
        try
        {
            var saved = await storage.GetAsync<string>(Key);
            if (saved.Success && !string.IsNullOrWhiteSpace(saved.Value))
                await SignInAsync(saved.Value, persist: false);
        }
        catch (InvalidOperationException) { return; } // JS not available yet (prerender): retry after render
        catch (Exception) { /* unreadable storage: user signs in again */ }
        _loaded = true;
        Changed?.Invoke();
    }

    // Returns false when the id is not a warehouse employee at any location.
    public async Task<bool> SignInAsync(string userId, bool persist = true)
    {
        userId = userId.Trim();
        var locations = userId == "" ? [] : await bc.GetEmployeeLocationsAsync(userId);
        if (locations.Count == 0)
        {
            UserId = userId;
            Locations = [];
            Changed?.Invoke();
            return false;
        }
        UserId = userId;
        Locations = locations;
        if (persist) await storage.SetAsync(Key, userId);
        Changed?.Invoke();
        return true;
    }

    public async Task SignOutAsync()
    {
        UserId = "";
        Locations = [];
        await storage.DeleteAsync(Key);
        Changed?.Invoke();
    }
}
