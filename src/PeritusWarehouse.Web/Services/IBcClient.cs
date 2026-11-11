namespace PeritusWarehouse.Web.Services;

public interface IBcClient
{
    Task<PurchaseOrder?> FindPurchaseOrderAsync(string number, CancellationToken ct = default);
    Task<List<PurchaseLine>> GetLinesAsync(string orderNumber, CancellationToken ct = default);
    Task ReceiveAsync(Guid orderId, IEnumerable<PurchaseLine> lines, CancellationToken ct = default);
    Task<string?> GetCompanyNameAsync(CancellationToken ct = default);
    // kind: "putAways" or "picks"
    Task<List<WhseActivity>> GetWhseActivitiesAsync(string kind, CancellationToken ct = default);
    Task<List<WhseLine>> GetWhseLinesAsync(string kind, string number, CancellationToken ct = default);
    Task RegisterWhseActivityAsync(string kind, Guid id, IEnumerable<WhseLine> lines, CancellationToken ct = default);
    Task<List<TransferOrder>> GetTransferOrdersAsync(CancellationToken ct = default);
    Task<List<TransferLine>> GetTransferLinesAsync(string number, CancellationToken ct = default);
    Task PostTransferAsync(Guid id, bool ship, IEnumerable<TransferLine> lines, CancellationToken ct = default);
    Task<List<ItemInfo>> SearchItemsAsync(string query, CancellationToken ct = default);
    Task<List<CountBatch>> GetCountBatchesAsync(CancellationToken ct = default);
    Task<List<CountLine>> GetCountLinesAsync(string batchName, CancellationToken ct = default);
    Task SetCountedAsync(Guid lineId, decimal quantity, CancellationToken ct = default);
    // Location codes where the user id is registered as a warehouse employee (empty = not registered).
    Task<List<string>> GetEmployeeLocationsAsync(string userId, CancellationToken ct = default);
    Task<List<PickPattern>> GetPickPatternsAsync(CancellationToken ct = default);
    // Creates the pick in BC for the pattern; returns the activities in the new batch.
    Task<List<WhseActivity>> CreatePickBatchAsync(string patternCode, string operatorName, CancellationToken ct = default);
    // Batches the operator has claimed and not released.
    Task<List<PickBatch>> GetClaimedPickBatchesAsync(string operatorName, CancellationToken ct = default);
    // Clears the claim so the shipments can match a pattern again. Existing warehouse picks are kept.
    Task<List<WhseActivity>> GetPickBatchActivitiesAsync(Guid batchId, CancellationToken ct = default);
    Task ReleasePickBatchAsync(PickBatch batch, CancellationToken ct = default);
}
