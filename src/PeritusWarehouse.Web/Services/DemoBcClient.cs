namespace PeritusWarehouse.Web.Services;

/// <summary>Used when BC isn't configured, so the UI can be tried out.</summary>
public class DemoBcClient : IBcClient
{
    private static readonly Guid Id = Guid.Parse("00000000-0000-0000-0000-000000000001");

    public Task<PurchaseOrder?> FindPurchaseOrderAsync(string number, CancellationToken ct = default) =>
        Task.FromResult<PurchaseOrder?>(new(Id, number, "Demo Vendor", "Open"));

    public Task<List<PurchaseLine>> GetLinesAsync(string orderNumber, CancellationToken ct = default) =>
        Task.FromResult(new List<PurchaseLine>
        {
            new() { Id = Guid.NewGuid(), Sequence = 10000, ItemNo = "1896-S", Description = "ATHENS Desk", Quantity = 10 },
            new() { Id = Guid.NewGuid(), Sequence = 20000, ItemNo = "1906-S", Description = "ATHENS Mobile Pedestal", Quantity = 5, ReceivedQuantity = 2 }
        });

    public Task ReceiveAsync(Guid orderId, IEnumerable<PurchaseLine> lines, CancellationToken ct = default) => Task.CompletedTask;

    public Task<string?> GetCompanyNameAsync(CancellationToken ct = default) => Task.FromResult<string?>("Demo company");

    private readonly Guid _actId = Guid.NewGuid();
    private readonly Guid _pickActivityId = Guid.NewGuid();
    private Guid _pickBatchId;
    private int _licensePlateSequence;
    private string? _activePickLicensePlateNumber;
    private List<WhseLine> _wl =
    [
        new() { Id = Guid.NewGuid(), ActivityType = 1, ActivityNumber = "DEMO1", LineNumber = 10000, ActionType = 1, ItemNo = "1896-S", Description = "ATHENS Desk", BinCode = "RECEIVE", Quantity = 4, Outstanding = 4, QtyToHandle = 4, Unit = "PCS" },
        new() { Id = Guid.NewGuid(), ActivityType = 1, ActivityNumber = "DEMO1", LineNumber = 20000, ActionType = 2, ItemNo = "1896-S", Description = "ATHENS Desk", BinCode = "A1", Quantity = 4, Outstanding = 4, QtyToHandle = 4, Unit = "PCS" }
    ];
    private List<WhseLine> _pickLines =
    [
        new() { Id = Guid.NewGuid(), ActivityType = 2, ActivityNumber = "PICK-DEMO", LineNumber = 10000, ActionType = 1, ItemNo = "1896-S", Description = "ATHENS Desk", BinCode = "A1", Quantity = 4, Outstanding = 4, QtyToHandle = 4, Unit = "PCS" },
        new() { Id = Guid.NewGuid(), ActivityType = 2, ActivityNumber = "PICK-DEMO", LineNumber = 20000, ActionType = 2, ItemNo = "1896-S", Description = "ATHENS Desk", BinCode = "SHIP", Quantity = 4, Outstanding = 4, QtyToHandle = 4, Unit = "PCS" }
    ];
    private readonly List<PickLicensePlate> _pickLicensePlates = [];
    private readonly List<PickLicensePlateLine> _pickLicensePlateLines = [];

    public Task<List<WhseActivity>> GetWhseActivitiesAsync(string kind, CancellationToken ct = default) =>
        Task.FromResult(kind == "picks"
            ? (_pickLines.Count == 0 ? new List<WhseActivity>() : [new() { Id = _pickActivityId, Number = "PICK-DEMO", LocationCode = "MAIN", BatchId = _pickBatchId, ActiveLicensePlateNumber = _activePickLicensePlateNumber }])
            : (_wl.Count == 0 ? new List<WhseActivity>() : [new() { Id = _actId, Number = "DEMO1", LocationCode = "MAIN" }]));

    public Task<List<WhseLine>> GetWhseLinesAsync(string kind, string number, CancellationToken ct = default) =>
        Task.FromResult((kind == "picks" ? _pickLines : _wl).ToList());

    public Task RegisterWhseActivityAsync(string kind, Guid id, IEnumerable<WhseLine> lines, CancellationToken ct = default)
    {
        if (kind == "picks") _pickLines = [];
        else _wl = [];
        return Task.CompletedTask;
    }

    public Task<List<PickLicensePlate>> GetPickLicensePlatesAsync(Guid batchId, CancellationToken ct = default) =>
        Task.FromResult(_pickLicensePlates.Where(x => x.BatchId == batchId).ToList());

    public Task<PickLicensePlate> CreatePickLicensePlateAsync(Guid batchId, CancellationToken ct = default)
    {
        var plate = new PickLicensePlate { Id = Guid.NewGuid(), BatchId = batchId, Number = $"LP{++_licensePlateSequence:00000}" };
        _pickLicensePlates.Add(plate);
        return Task.FromResult(plate);
    }

    public Task<List<PickLicensePlateLine>> GetPickLicensePlateLinesAsync(Guid batchId, CancellationToken ct = default) =>
        Task.FromResult(_pickLicensePlateLines.Where(x => x.BatchId == batchId).ToList());

    public Task SetPickActiveLicensePlateAsync(Guid activityId, string? licensePlateNumber, CancellationToken ct = default)
    {
        if (activityId != _pickActivityId)
            throw new InvalidOperationException("Pick activity was not found.");
        _activePickLicensePlateNumber = licensePlateNumber;
        return Task.CompletedTask;
    }

    public Task AddPickTakeAsync(Guid batchId, string licensePlateNumber, WhseLine line, decimal quantity, CancellationToken ct = default)
    {
        if (quantity <= 0 || quantity > line.Outstanding)
            throw new InvalidOperationException("Take quantity exceeds the remaining quantity.");
        var plate = _pickLicensePlates.FirstOrDefault(x => x.BatchId == batchId && x.Number == licensePlateNumber)
            ?? throw new InvalidOperationException("License plate was not found.");
        _pickLicensePlateLines.Add(new PickLicensePlateLine
        {
            Id = Guid.NewGuid(),
            BatchId = batchId,
            LicensePlateNumber = plate.Number,
            ActivityNumber = line.ActivityNumber,
            ActivityLineNumber = line.LineNumber,
            ItemNo = line.ItemNo,
            BinCode = line.BinCode,
            ZoneCode = line.ZoneCode,
            Unit = line.Unit,
            TakeQuantity = quantity
        });
        return Task.CompletedTask;
    }

    public Task SetPickPlaceAsync(Guid lineId, decimal quantity, CancellationToken ct = default)
    {
        var line = _pickLicensePlateLines.FirstOrDefault(x => x.Id == lineId)
            ?? throw new InvalidOperationException("Pick license plate line was not found.");
        if (quantity < line.PostedQuantity || quantity > line.TakeQuantity)
            throw new InvalidOperationException("Place quantity must be between posted quantity and Take quantity.");
        line.PlaceQuantity = quantity;
        return Task.CompletedTask;
    }

    public Task RegisterPickActivityAsync(Guid id, CancellationToken ct = default)
    {
        foreach (var lpLine in _pickLicensePlateLines.Where(x => x.ActivityNumber == "PICK-DEMO"))
            lpLine.PostedQuantity = lpLine.PlaceQuantity;
        _pickLines = [];
        return Task.CompletedTask;
    }

    private readonly TransferOrder _to = new() { Id = Guid.NewGuid(), Number = "TO-DEMO", FromCode = "MAIN", ToCode = "EAST", Status = "Released" };
    private readonly List<TransferLine> _tl =
    [
        new() { Id = Guid.NewGuid(), ItemNo = "1906-S", Description = "ATHENS Mobile Pedestal", Quantity = 5, QtyToShip = 5 }
    ];

    public Task<List<TransferOrder>> GetTransferOrdersAsync(CancellationToken ct = default) => Task.FromResult<List<TransferOrder>>([_to]);
    public Task<List<TransferLine>> GetTransferLinesAsync(string number, CancellationToken ct = default) => Task.FromResult(_tl.ToList());

    public Task PostTransferAsync(Guid id, bool ship, IEnumerable<TransferLine> lines, CancellationToken ct = default)
    {
        foreach (var l in lines) { if (ship) l.Shipped += l.Entry; else l.Received += l.Entry; }
        return Task.CompletedTask;
    }

    private readonly List<ItemInfo> _items =
    [
        new() { Number = "1896-S", Description = "ATHENS Desk", Gtin = "5701234000011", Inventory = 10, Unit = "PCS", UnitPrice = 1397.3m },
        new() { Number = "1906-S", Description = "ATHENS Mobile Pedestal", Gtin = "5701234000028", Inventory = 5, Unit = "PCS", UnitPrice = 666.4m }
    ];

    public Task<List<ItemInfo>> SearchItemsAsync(string query, CancellationToken ct = default) =>
        Task.FromResult(_items.Where(i => i.Number.Contains(query, StringComparison.OrdinalIgnoreCase)
            || (i.Description ?? "").Contains(query, StringComparison.OrdinalIgnoreCase)
            || i.Gtin == query).ToList());

    private readonly List<CountLine> _count =
    [
        new() { Id = Guid.NewGuid(), ItemNo = "1896-S", Description = "ATHENS Desk", LocationCode = "MAIN", BinCode = "A1", CalculatedQuantity = 10, CountedQuantity = 10 },
        new() { Id = Guid.NewGuid(), ItemNo = "1906-S", Description = "ATHENS Mobile Pedestal", LocationCode = "MAIN", BinCode = "A2", CalculatedQuantity = 5, CountedQuantity = 5 }
    ];

    public Task<List<CountBatch>> GetCountBatchesAsync(CancellationToken ct = default) =>
        Task.FromResult(new List<CountBatch> { new() { Name = "DEFAULT", Description = "Demo count" } });

    public Task<List<CountLine>> GetCountLinesAsync(string batchName, CancellationToken ct = default) => Task.FromResult(_count);

    public Task SetCountedAsync(Guid lineId, decimal quantity, CancellationToken ct = default)
    {
        var l = _count.FirstOrDefault(x => x.Id == lineId);
        if (l is not null) l.CountedQuantity = quantity;
        return Task.CompletedTask;
    }

    public Task<List<PickPattern>> GetPickPatternsAsync(CancellationToken ct = default) =>
        Task.FromResult(new List<PickPattern>
        {
            new() { Code = "WEB-SMALL", Description = "Web orders, small box", Priority = 10, LocationCode = "MAIN", OrderCount = 12, ContainerType = "Small box", AvailableCount = 9 },
            new() { Code = "LONG", Description = "Long items", Priority = 5, LocationCode = "MAIN", OrderCount = 1, ContainerType = "Long box", AvailableCount = 0 }
        });

    public Task<List<string>> GetEmployeeLocationsAsync(string userId, CancellationToken ct = default) =>
        Task.FromResult(new List<string> { "DEMO" });

    public Task<List<PickBatch>> GetClaimedPickBatchesAsync(string operatorName, CancellationToken ct = default) =>
        Task.FromResult(new List<PickBatch>());

    public Task ReleasePickBatchAsync(PickBatch batch, CancellationToken ct = default) => Task.CompletedTask;

    public Task<List<WhseActivity>> GetPickBatchActivitiesAsync(Guid batchId, CancellationToken ct = default) =>
        Task.FromResult(_pickLines.Count == 0
            ? new List<WhseActivity>()
            : [new() { Id = _pickActivityId, Number = "PICK-DEMO", LocationCode = "MAIN", BatchId = batchId, ActiveLicensePlateNumber = _activePickLicensePlateNumber }]);

    public Task<List<WhseActivity>> CreatePickBatchAsync(string patternCode, string operatorName, CancellationToken ct = default)
    {
        _pickBatchId = Guid.NewGuid();
        _pickLines =
        [
            new() { Id = Guid.NewGuid(), ActivityType = 2, ActivityNumber = "PICK-DEMO", LineNumber = 10000, ActionType = 1, ItemNo = "1896-S", Description = "ATHENS Desk", BinCode = "A1", Quantity = 4, Outstanding = 4, QtyToHandle = 4, Unit = "PCS" },
            new() { Id = Guid.NewGuid(), ActivityType = 2, ActivityNumber = "PICK-DEMO", LineNumber = 20000, ActionType = 2, ItemNo = "1896-S", Description = "ATHENS Desk", BinCode = "SHIP", Quantity = 4, Outstanding = 4, QtyToHandle = 4, Unit = "PCS" }
        ];
        _pickLicensePlates.Clear();
        _pickLicensePlateLines.Clear();
        _activePickLicensePlateNumber = null;
        return GetPickBatchActivitiesAsync(_pickBatchId, ct);
    }
}
