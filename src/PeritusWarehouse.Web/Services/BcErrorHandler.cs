using System.Net;
using System.Text.Json;

namespace PeritusWarehouse.Web.Services;

/// <summary>Error from BC or Entra ID with a message that is safe and useful to show to the worker.</summary>
public class BcApiException(string message, HttpStatusCode? status, Exception? inner = null) : HttpRequestException(message, inner, status);

/// <summary>Turns failed HTTP calls into <see cref="BcApiException"/> with a readable message.</summary>
public class BcErrorHandler : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
    {
        HttpResponseMessage resp;
        try { resp = await base.SendAsync(request, ct); }
        catch (HttpRequestException ex) when (ex is not BcApiException)
        {
            throw new BcApiException("Cannot reach Business Central. Check the network connection and try again.", null, ex);
        }
        catch (TaskCanceledException ex) when (!ct.IsCancellationRequested)
        {
            throw new BcApiException("Business Central did not respond in time. Try again.", null, ex);
        }

        if (resp.IsSuccessStatusCode) return resp;

        var body = await resp.Content.ReadAsStringAsync(ct);
        var status = resp.StatusCode;
        var isAuth = request.RequestUri?.Host.Contains("login.microsoftonline.com", StringComparison.OrdinalIgnoreCase) == true;
        resp.Dispose();
        throw new BcApiException(Describe(status, isAuth, Detail(body)), status);
    }

    private static string? Detail(string body)
    {
        try
        {
            var root = JsonDocument.Parse(body).RootElement;
            if (root.TryGetProperty("error", out var e))
            {
                if (e.ValueKind == JsonValueKind.String)
                    return root.TryGetProperty("error_description", out var d) ? FirstLine(d.GetString()) : e.GetString();
                if (e.TryGetProperty("message", out var m)) return m.GetString();
            }
        }
        catch { }
        return null;
    }

    private static string? FirstLine(string? s) => s?.Split('\n', 2)[0].Trim();

    private static string Describe(HttpStatusCode status, bool isAuth, string? detail)
    {
        var text = (isAuth, (int)status) switch
        {
            (true, _) => "Could not sign in to Business Central. The app credentials (client id/secret) or tenant are wrong or expired. Contact an administrator.",
            (_, 400) => "Business Central rejected the request.",
            (_, 401) => "Business Central did not accept the app's sign-in. Contact an administrator.",
            (_, 403) => "You do not have access to this in Business Central. The app user is missing a permission set, or is not set up as a warehouse employee for the location. Contact an administrator.",
            (_, 404) => "Not found in Business Central. The company, API or record may be missing, or the Peritus Warehouse extension is not installed.",
            (_, 409) => "The record was changed by someone else. Reload and try again.",
            (_, 429) => "Business Central is busy. Wait a moment and try again.",
            (_, 503) => "Business Central is temporarily unavailable. Try again shortly.",
            (_, >= 500) => "Business Central reported a server error. Try again, or contact an administrator if it persists.",
            _ => $"Business Central returned an error ({(int)status})."
        };
        return string.IsNullOrWhiteSpace(detail) ? text : $"{text} Details: {detail}";
    }
}
