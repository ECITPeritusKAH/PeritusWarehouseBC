using System.Text.Json.Serialization;

namespace PeritusWarehouse.Web.Services;

public record PurchaseOrder(
    [property: JsonPropertyName("id")] Guid Id,
    [property: JsonPropertyName("number")] string Number,
    [property: JsonPropertyName("vendorName")] string? VendorName,
    [property: JsonPropertyName("status")] string? Status);

public class PurchaseLine
{
    [JsonPropertyName("id")] public Guid Id { get; set; }
    [JsonPropertyName("sequence")] public int Sequence { get; set; }
    [JsonPropertyName("itemNumber")] public string? ItemNo { get; set; }
    [JsonPropertyName("description")] public string? Description { get; set; }
    [JsonPropertyName("quantity")] public decimal Quantity { get; set; }
    [JsonPropertyName("receivedQuantity")] public decimal ReceivedQuantity { get; set; }

    // Client-side only; nothing is stored in this app.
    [JsonIgnore] public decimal ToReceive { get; set; }
    [JsonIgnore] public decimal Outstanding => Quantity - ReceivedQuantity;
}

public class CountLine
{
    [JsonPropertyName("id")] public Guid Id { get; set; }
    [JsonPropertyName("itemNumber")] public string? ItemNo { get; set; }
    [JsonPropertyName("description")] public string? Description { get; set; }
    [JsonPropertyName("locationCode")] public string? LocationCode { get; set; }
    [JsonPropertyName("binCode")] public string? BinCode { get; set; }
    [JsonPropertyName("calculatedQuantity")] public decimal CalculatedQuantity { get; set; }
    [JsonPropertyName("countedQuantity")] public decimal CountedQuantity { get; set; }

    // Client-side only; the count lives in the BC journal line.
    [JsonIgnore] public decimal Entry { get; set; }
}

public class CountBatch
{
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("description")] public string? Description { get; set; }
    [JsonPropertyName("releasedToMobile")] public bool ReleasedToMobile { get; set; }
}

public class ItemInfo
{
    [JsonPropertyName("number")] public string Number { get; set; } = "";
    [JsonPropertyName("displayName")] public string? Description { get; set; }
    [JsonPropertyName("gtin")] public string? Gtin { get; set; }
    [JsonPropertyName("inventory")] public decimal Inventory { get; set; }
    [JsonPropertyName("baseUnitOfMeasureCode")] public string? Unit { get; set; }
    [JsonPropertyName("unitPrice")] public decimal UnitPrice { get; set; }
    [JsonPropertyName("blocked")] public bool Blocked { get; set; }
}

public class WhseActivity
{
    [JsonPropertyName("id")] public Guid Id { get; set; }
    [JsonPropertyName("number")] public string Number { get; set; } = "";
    [JsonPropertyName("locationCode")] public string? LocationCode { get; set; }
    [JsonPropertyName("assignedUserId")] public string? AssignedUserId { get; set; }
}

public class WhseLine
{
    [JsonPropertyName("id")] public Guid Id { get; set; }
    [JsonPropertyName("activityType")] public int ActivityType { get; set; }
    [JsonPropertyName("activityNumber")] public string ActivityNumber { get; set; } = "";
    [JsonPropertyName("lineNumber")] public int LineNumber { get; set; }
    [JsonPropertyName("actionType")] public int ActionType { get; set; }
    [JsonPropertyName("itemNumber")] public string? ItemNo { get; set; }
    [JsonPropertyName("description")] public string? Description { get; set; }
    [JsonPropertyName("locationCode")] public string? LocationCode { get; set; }
    [JsonPropertyName("zoneCode")] public string? ZoneCode { get; set; }
    [JsonPropertyName("binCode")] public string? BinCode { get; set; }
    [JsonPropertyName("unitOfMeasureCode")] public string? Unit { get; set; }
    [JsonPropertyName("quantity")] public decimal Quantity { get; set; }
    [JsonPropertyName("quantityOutstanding")] public decimal Outstanding { get; set; }
    [JsonPropertyName("quantityHandled")] public decimal Handled { get; set; }
    [JsonPropertyName("qtyToHandle")] public decimal QtyToHandle { get; set; }

    [JsonIgnore] public decimal Entry { get; set; }
}

public class TransferOrder
{
    [JsonPropertyName("id")] public Guid Id { get; set; }
    [JsonPropertyName("number")] public string Number { get; set; } = "";
    [JsonPropertyName("fromCode")] public string? FromCode { get; set; }
    [JsonPropertyName("toCode")] public string? ToCode { get; set; }
    [JsonPropertyName("status")] public string? Status { get; set; }
}

public class TransferLine
{
    [JsonPropertyName("id")] public Guid Id { get; set; }
    [JsonPropertyName("itemNumber")] public string? ItemNo { get; set; }
    [JsonPropertyName("description")] public string? Description { get; set; }
    [JsonPropertyName("quantity")] public decimal Quantity { get; set; }
    [JsonPropertyName("quantityShipped")] public decimal Shipped { get; set; }
    [JsonPropertyName("quantityReceived")] public decimal Received { get; set; }
    [JsonPropertyName("qtyToShip")] public decimal QtyToShip { get; set; }
    [JsonPropertyName("qtyToReceive")] public decimal QtyToReceive { get; set; }

    [JsonIgnore] public decimal ToShipOpen => Quantity - Shipped;
    [JsonIgnore] public decimal InTransit => Shipped - Received;
    [JsonIgnore] public decimal Entry { get; set; }
}

public class PickBatch
{
    public Guid BatchId { get; set; }
    public Guid ShipmentRecordId { get; set; }
    public string PatternCode { get; set; } = "";
    public List<string> Shipments { get; set; } = [];
}

public class PickBatchRow
{
    [JsonPropertyName("id")] public Guid Id { get; set; }
    [JsonPropertyName("batchId")] public Guid BatchId { get; set; }
    [JsonPropertyName("shipmentNumber")] public string ShipmentNumber { get; set; } = "";
    [JsonPropertyName("patternCode")] public string PatternCode { get; set; } = "";
}

public class PickPattern
{
    [JsonPropertyName("code")] public string Code { get; set; } = "";
    [JsonPropertyName("description")] public string? Description { get; set; }
    [JsonPropertyName("priority")] public int Priority { get; set; }
    [JsonPropertyName("locationCode")] public string? LocationCode { get; set; }
    [JsonPropertyName("orderCount")] public int OrderCount { get; set; }
    [JsonPropertyName("containerType")] public string? ContainerType { get; set; }
    [JsonPropertyName("availableCount")] public int AvailableCount { get; set; }
}
