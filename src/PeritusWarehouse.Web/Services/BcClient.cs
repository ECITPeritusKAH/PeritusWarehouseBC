using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;

namespace PeritusWarehouse.Web.Services;

/// <summary>Talks to BC standard API v2.0. Holds no data; token is cached in memory only.</summary>
public class BcClient(HttpClient http, IOptions<BcOptions> options) : IBcClient
{
    private readonly BcOptions _o = options.Value;
    private static string? _token;
    private static DateTimeOffset _expires;
    private static readonly SemaphoreSlim _lock = new(1, 1);

    private string Base =>
        $"https://api.businesscentral.dynamics.com/v2.0/{_o.TenantId}/{_o.Environment}/api/peritus/warehouse/v1.0/companies({_o.CompanyId})";

    private async Task AuthorizeAsync(CancellationToken ct)
    {
        await _lock.WaitAsync(ct);
        try
        {
            if (_token is null || _expires < DateTimeOffset.UtcNow.AddMinutes(2))
            {
                using var resp = await http.PostAsync(
                    $"https://login.microsoftonline.com/{_o.TenantId}/oauth2/v2.0/token",
                    new FormUrlEncodedContent(new Dictionary<string, string>
                    {
                        ["grant_type"] = "client_credentials",
                        ["client_id"] = _o.ClientId,
                        ["client_secret"] = _o.ClientSecret,
                        ["scope"] = "https://api.businesscentral.dynamics.com/.default"
                    }), ct);
                resp.EnsureSuccessStatusCode();
                var json = await resp.Content.ReadFromJsonAsync<JsonElement>(ct);
                _token = json.GetProperty("access_token").GetString();
                _expires = DateTimeOffset.UtcNow.AddSeconds(json.GetProperty("expires_in").GetInt32());
            }
        }
        finally { _lock.Release(); }
        http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _token);
    }

    private sealed record ODataList<T>(List<T> value);

    public async Task<PurchaseOrder?> FindPurchaseOrderAsync(string number, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var url = $"{Base}/purchaseOrders?$filter=number eq '{number.Replace("'", "''")}'";
        var r = await http.GetFromJsonAsync<ODataList<PurchaseOrder>>(url, ct);
        return r?.value.FirstOrDefault();
    }

    public async Task<List<PurchaseLine>> GetLinesAsync(string orderNumber, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var r = await http.GetFromJsonAsync<ODataList<PurchaseLine>>(
            $"{Base}/purchaseOrderLines?$filter=documentNumber eq '{orderNumber.Replace("'", "''")}'", ct);
        return r?.value ?? [];
    }

    public async Task ReceiveAsync(Guid orderId, IEnumerable<PurchaseLine> lines, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        foreach (var l in lines.Where(l => l.ToReceive > 0))
        {
            using var req = new HttpRequestMessage(HttpMethod.Patch,
                $"{Base}/purchaseOrderLines({l.Id})")
            {
                Content = new StringContent(JsonSerializer.Serialize(new { receiveQuantity = l.ToReceive }),
                    Encoding.UTF8, "application/json")
            };
            req.Headers.TryAddWithoutValidation("If-Match", "*");
            using var patch = await http.SendAsync(req, ct);
            await EnsureSuccessAsync(patch, ct);
        }
        // Bound action from the AL extension in /al.
        using var post = await http.PostAsync($"{Base}/purchaseOrders({orderId})/{_o.ReceiveAction}", null, ct);
        await EnsureSuccessAsync(post, ct);
    }

    public async Task<string?> GetCompanyNameAsync(CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var url = $"https://api.businesscentral.dynamics.com/v2.0/{_o.TenantId}/{_o.Environment}/api/v2.0/companies({_o.CompanyId})?$select=name,displayName";
        var c = await http.GetFromJsonAsync<JsonElement>(url, ct);
        var display = c.TryGetProperty("displayName", out var d) ? d.GetString() : null;
        return string.IsNullOrWhiteSpace(display) ? c.GetProperty("name").GetString() : display;
    }

    public async Task<List<ItemInfo>> SearchItemsAsync(string query, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var q = query.Trim().Replace("'", "''");
        var baseUrl = $"https://api.businesscentral.dynamics.com/v2.0/{_o.TenantId}/{_o.Environment}/api/v2.0/companies({_o.CompanyId})/items" +
                      "?$select=number,displayName,gtin,inventory,baseUnitOfMeasureCode,unitPrice,blocked&$top=25&$filter=";
        // BC rejects OR across different fields, so each field is queried on its own.
        var result = new List<ItemInfo>();
        foreach (var filter in new[] { $"number eq '{q}'", $"gtin eq '{q}'", $"startswith(number,'{q}')", $"contains(displayName,'{q}')" })
        {
            var r = await http.GetFromJsonAsync<ODataList<ItemInfo>>(baseUrl + Uri.EscapeDataString(filter), ct);
            foreach (var i in r?.value ?? [])
                if (result.All(x => x.Number != i.Number)) result.Add(i);
            if (result.Count >= 25) break;
        }
        return result;
    }

    public async Task<List<CountBatch>> GetCountBatchesAsync(CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var filter = $"journalTemplateName eq '{_o.CountTemplate.Replace("'", "''")}'";
        var r = await http.GetFromJsonAsync<ODataList<CountBatch>>(
            $"{Base}/inventoryCountBatches?$filter={Uri.EscapeDataString(filter)}", ct);
        return r?.value ?? [];
    }

    public async Task<List<CountLine>> GetCountLinesAsync(string batchName, CancellationToken ct = default)
    {
        var filter = $"journalTemplateName eq '{_o.CountTemplate.Replace("'", "''")}' and journalBatchName eq '{batchName.Replace("'", "''")}'";
        var r = await http.GetFromJsonAsync<ODataList<CountLine>>(
            $"{Base}/inventoryCountLines?$filter={Uri.EscapeDataString(filter)}", ct);
        return r?.value ?? [];
    }

    public async Task SetCountedAsync(Guid lineId, decimal quantity, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        using var req = new HttpRequestMessage(HttpMethod.Patch, $"{Base}/inventoryCountLines({lineId})")
        {
            Content = new StringContent(JsonSerializer.Serialize(new { countedQuantity = quantity }),
                Encoding.UTF8, "application/json")
        };
        req.Headers.TryAddWithoutValidation("If-Match", "*");
        using var resp = await http.SendAsync(req, ct);
        await EnsureSuccessAsync(resp, ct);
    }

    private async Task PatchAsync(string url, object body, CancellationToken ct)
    {
        using var req = new HttpRequestMessage(HttpMethod.Patch, url)
        {
            Content = new StringContent(JsonSerializer.Serialize(body), Encoding.UTF8, "application/json")
        };
        req.Headers.TryAddWithoutValidation("If-Match", "*");
        using var resp = await http.SendAsync(req, ct);
        await EnsureSuccessAsync(resp, ct);
    }

    private static int ActivityTypeOf(string kind) => kind == "picks" ? 2 : 1;

    public async Task<List<WhseActivity>> GetWhseActivitiesAsync(string kind, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var r = await http.GetFromJsonAsync<ODataList<WhseActivity>>($"{Base}/{kind}?$top=50", ct);
        return r?.value ?? [];
    }

    public async Task<List<WhseLine>> GetWhseLinesAsync(string kind, string number, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var r = await http.GetFromJsonAsync<ODataList<WhseLine>>(
            $"{Base}/warehouseActivityLines?$filter={Uri.EscapeDataString($"activityNumber eq '{number.Replace("'", "''")}'")}", ct);
        var type = ActivityTypeOf(kind);
        return r?.value.Where(l => l.ActivityType == type).OrderBy(l => l.LineNumber).ToList() ?? [];
    }

    public async Task RegisterWhseActivityAsync(string kind, Guid id, IEnumerable<WhseLine> lines, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        foreach (var l in lines.Where(l => l.Entry != l.QtyToHandle))
            await PatchAsync($"{Base}/warehouseActivityLines({l.Id})", new { qtyToHandle = l.Entry }, ct);
        using var post = await http.PostAsync($"{Base}/{kind}({id})/Microsoft.NAV.register", null, ct);
        await EnsureSuccessAsync(post, ct);
    }

    public async Task<List<TransferOrder>> GetTransferOrdersAsync(CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var r = await http.GetFromJsonAsync<ODataList<TransferOrder>>(
            $"{Base}/transferOrders?$filter={Uri.EscapeDataString("status eq 'Released'")}&$top=50", ct);
        return r?.value ?? [];
    }

    public async Task<List<TransferLine>> GetTransferLinesAsync(string number, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var r = await http.GetFromJsonAsync<ODataList<TransferLine>>(
            $"{Base}/transferOrderLines?$filter={Uri.EscapeDataString($"documentNumber eq '{number.Replace("'", "''")}'")}", ct);
        return r?.value ?? [];
    }

    public async Task PostTransferAsync(Guid id, bool ship, IEnumerable<TransferLine> lines, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        foreach (var l in lines)
            await PatchAsync($"{Base}/transferOrderLines({l.Id})",
                ship ? new { qtyToShip = l.Entry } : new { qtyToReceive = l.Entry }, ct);
        using var post = await http.PostAsync($"{Base}/transferOrders({id})/Microsoft.NAV.{(ship ? "ship" : "receive")}", null, ct);
        await EnsureSuccessAsync(post, ct);
    }

    private static async Task EnsureSuccessAsync(HttpResponseMessage resp, CancellationToken ct)
    {
        if (resp.IsSuccessStatusCode) return;
        var body = await resp.Content.ReadAsStringAsync(ct);
        var message = body;
        try { message = JsonDocument.Parse(body).RootElement.GetProperty("error").GetProperty("message").GetString() ?? body; }
        catch { }
        throw new HttpRequestException($"BC {(int)resp.StatusCode}: {message}");
    }

    // Pick patterns live in the custom API group; the rest of the client uses the same Base.
    public async Task<List<PickPattern>> GetPickPatternsAsync(CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var r = await http.GetFromJsonAsync<ODataList<PickPattern>>($"{Base}/pickPatterns?$orderby=priority", ct);
        return r?.value ?? [];
    }

    public async Task<List<WhseActivity>> CreatePickBatchAsync(string patternCode, string operatorName, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var batchId = Guid.NewGuid();
        using var post = await http.PostAsJsonAsync($"{Base}/pickRequests",
            new { batchId, patternCode, @operator = operatorName }, ct);
        await EnsureSuccessAsync(post, ct);

        return await GetPickBatchActivitiesAsync(batchId, ct);
    }

    public async Task<List<WhseActivity>> GetPickBatchActivitiesAsync(Guid batchId, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        var lines = await http.GetFromJsonAsync<ODataList<WhseLine>>(
            $"{Base}/pickLines?$filter={Uri.EscapeDataString($"batchId eq {batchId}")}", ct);
        var numbers = (lines?.value ?? []).Select(l => l.ActivityNumber).Distinct().ToList();
        var result = new List<WhseActivity>();
        foreach (var n in numbers)
        {
            var a = await http.GetFromJsonAsync<ODataList<WhseActivity>>(
                $"{Base}/picks?$filter={Uri.EscapeDataString($"number eq '{n.Replace("'", "''")}'")}", ct);
            result.AddRange(a?.value ?? []);
        }
        return result;
    }

    private sealed record EmployeeRow([property: System.Text.Json.Serialization.JsonPropertyName("locationCode")] string LocationCode);

    public async Task<List<string>> GetEmployeeLocationsAsync(string userId, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        // BC stores the user id as a Code field, which is upper case.
        var who = userId.Trim().ToUpperInvariant().Replace("'", "''");
        var r = await http.GetFromJsonAsync<ODataList<EmployeeRow>>(
            $"{Base}/warehouseEmployees?$filter={Uri.EscapeDataString($"userId eq '{who}'")}", ct);
        return (r?.value ?? []).Select(x => x.LocationCode).Distinct().ToList();
    }

    public async Task<List<PickBatch>> GetClaimedPickBatchesAsync(string operatorName, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        // BC stores the user as a Code field, which is upper case.
        var who = operatorName.Trim().ToUpperInvariant().Replace("'", "''");
        var r = await http.GetFromJsonAsync<ODataList<PickBatchRow>>(
            $"{Base}/pickBatches?$filter={Uri.EscapeDataString($"pickedBy eq '{who}'")}", ct);
        return (r?.value ?? [])
            .Where(x => x.BatchId != Guid.Empty)
            .GroupBy(x => x.BatchId)
            .Select(g => new PickBatch
            {
                BatchId = g.Key,
                ShipmentRecordId = g.First().Id,
                PatternCode = g.First().PatternCode,
                Shipments = g.Select(x => x.ShipmentNumber).ToList()
            }).ToList();
    }

    public async Task ReleasePickBatchAsync(PickBatch batch, CancellationToken ct = default)
    {
        await AuthorizeAsync(ct);
        using var post = await http.PostAsync($"{Base}/pickBatches({batch.ShipmentRecordId})/Microsoft.NAV.release", null, ct);
        await EnsureSuccessAsync(post, ct);
    }
}
