namespace PeritusWarehouse.Web.Services;

public class BcOptions
{
    public const string Section = "BusinessCentral";
    public string TenantId { get; set; } = "";
    public string ClientId { get; set; } = "";
    public string ClientSecret { get; set; } = "";
    public string Environment { get; set; } = "Production";
    public string CompanyId { get; set; } = "";
    public string ReceiveAction { get; set; } = "Microsoft.NAV.receive";
    public string CountTemplate { get; set; } = "PHYS. INVE";
    public bool IsConfigured => TenantId != "" && ClientId != "" && ClientSecret != "" && CompanyId != "";
}
