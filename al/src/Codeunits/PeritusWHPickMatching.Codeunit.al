codeunit 91120 "PeritusWH Pick Matching"
{
    // Units follow the item card: length, weight and cubage per base unit of measure.

    procedure CountAvailable(Pattern: Record "PeritusWH Pick Pattern"): Integer
    var
        Shipments: Record "Warehouse Shipment Header" temporary;
    begin
        FindMatching(Pattern, 0, Shipments);
        exit(Shipments.Count());
    end;

    /// Fills Shipments with up to MaxCount matching shipments (0 = all), oldest shipment date first.
    procedure FindMatching(Pattern: Record "PeritusWH Pick Pattern"; MaxCount: Integer; var Shipments: Record "Warehouse Shipment Header" temporary)
    var
        Header: Record "Warehouse Shipment Header";
    begin
        Shipments.Reset();
        Shipments.DeleteAll();
        Header.SetCurrentKey("Shipment Date");
        Header.SetRange("Location Code", Pattern."Location Code");
        Header.SetRange(Status, Header.Status::Released);
        Header.SetFilter("PeritusWH Picked By", '=''''');
        if Header.FindSet() then
            repeat
                if Matches(Pattern, Header) then
                    if not HigherPriorityMatches(Pattern, Header) then begin
                        Shipments := Header;
                        Shipments.Insert();
                        if (MaxCount > 0) and (Shipments.Count() >= MaxCount) then
                            exit;
                    end;
            until Header.Next() = 0;
    end;

    local procedure HigherPriorityMatches(Pattern: Record "PeritusWH Pick Pattern"; Header: Record "Warehouse Shipment Header"): Boolean
    var
        Other: Record "PeritusWH Pick Pattern";
    begin
        Other.SetCurrentKey(Priority);
        Other.SetRange(Enabled, true);
        Other.SetRange("Location Code", Pattern."Location Code");
        Other.SetFilter(Priority, '<%1', Pattern.Priority);
        if Other.FindSet() then
            repeat
                if Matches(Other, Header) then
                    exit(true);
            until Other.Next() = 0;
        // Equal priority: lowest code wins
        Other.SetRange(Priority, Pattern.Priority);
        Other.SetFilter(Code, '<%1', Pattern.Code);
        if Other.FindSet() then
            repeat
                if Matches(Other, Header) then
                    exit(true);
            until Other.Next() = 0;
        exit(false);
    end;

    procedure Matches(Pattern: Record "PeritusWH Pick Pattern"; Header: Record "Warehouse Shipment Header"): Boolean
    var
        Line: Record "Warehouse Shipment Line";
        ItemUoM: Record "Item Unit of Measure";
        Item: Record Item;
        Weight: Decimal;
        Volume: Decimal;
        MaxLen: Decimal;
        ZoneHit: Boolean;
        HasLines: Boolean;
    begin
        if not ShippingMatches(Pattern, Header."Shipment Method Code") then
            exit(false);

        Line.SetRange("No.", Header."No.");
        if Line.FindSet() then
            repeat
                // Already has a pick: not available
                Line.CalcFields("Pick Qty.");
                if (Line."Pick Qty." <> 0) or (Line."Qty. Picked" <> 0) then
                    exit(false);
                HasLines := true;
                if Item.Get(Line."Item No.") then
                    if ItemUoM.Get(Line."Item No.", Item."Base Unit of Measure") then begin
                        Weight += ItemUoM.Weight * Line."Qty. Outstanding (Base)";
                        Volume += ItemUoM.Cubage * Line."Qty. Outstanding (Base)";
                        if ItemUoM.Length > MaxLen then
                            MaxLen := ItemUoM.Length;
                    end;
                if (Pattern."Zone Code" <> '') and (Line."Zone Code" = Pattern."Zone Code") then
                    ZoneHit := true;
            until Line.Next() = 0;
        if not HasLines then
            exit(false);
        if (Pattern."Zone Code" <> '') and not ZoneHit then
            exit(false);

        if not InRange(MaxLen, Pattern."Min Length", Pattern."Max Length") then
            exit(false);
        if not InRange(Weight, Pattern."Min Weight", Pattern."Max Weight") then
            exit(false);
        exit(InRange(Volume, Pattern."From Volume", Pattern."To Volume"));
    end;

    // 0 means unbounded
    local procedure InRange(Value: Decimal; MinValue: Decimal; MaxValue: Decimal): Boolean
    begin
        if (MinValue <> 0) and (Value < MinValue) then
            exit(false);
        if (MaxValue <> 0) and (Value > MaxValue) then
            exit(false);
        exit(true);
    end;

    local procedure ShippingMatches(Pattern: Record "PeritusWH Pick Pattern"; ShipmentMethod: Code[10]): Boolean
    var
        Ship: Record "PeritusWH Pick Shipping Method";
    begin
        Ship.SetRange("Pattern Code", Pattern.Code);
        Ship.SetRange("Shipping Method", ShipmentMethod);
        Ship.SetRange(Mode, Ship.Mode::Exclude);
        if not Ship.IsEmpty() then
            exit(false);
        Ship.SetRange(Mode, Ship.Mode::Include);
        Ship.SetRange("Shipping Method");
        if Ship.IsEmpty() then
            exit(true);
        Ship.SetRange("Shipping Method", ShipmentMethod);
        exit(not Ship.IsEmpty());
    end;

    /// Claims matching shipments for the user, creates standard warehouse picks and returns the batch id.
    procedure CreatePick(Pattern: Record "PeritusWH Pick Pattern"; UserId: Code[50]; BatchId: Guid)
    var
        Candidates: Record "Warehouse Shipment Header" temporary;
        Header: Record "Warehouse Shipment Header";
        ActLine: Record "Warehouse Activity Line";
        PickError: Text;
        Created: Integer;
        OrdersDone: Boolean;
        PickFailedErr: Label 'Could not create the pick for warehouse shipment %1: %2', Comment = '%1 = shipment no., %2 = error text';
    begin
        if not Pattern.Enabled then
            Error('Pick pattern %1 is disabled.', Pattern.Code);
        Header.LockTable();
        FindMatching(Pattern, 0, Candidates);
        if Candidates.IsEmpty() then
            Error('No orders available for pick pattern %1.', Pattern.Code);

        if IsNullGuid(BatchId) then
            Error('Batch id is required.');
        Candidates.FindSet();
        repeat
            Header.Get(Candidates."No.");
            // The pick report cannot run inside an open write transaction, so commit first.
            Commit();
            if not Codeunit.Run(Codeunit::"PeritusWH Create Pick Doc", Header) then begin
                // Skip shipments that cannot be picked (e.g. already picked) and try the next one.
                PickError := StrSubstNo(PickFailedErr, Header."No.", GetLastErrorText());
                ClearLastError();
                continue;
            end;
            Created += 1;
            if Created >= Pattern."Order Count" then
                OrdersDone := true;
            Header.Get(Candidates."No.");
            Header."PeritusWH Batch Id" := BatchId;
            Header."PeritusWH Pattern Code" := Pattern.Code;
            Header."PeritusWH Picked By" := UserId;
            Header."PeritusWH Claimed At" := CurrentDateTime();
            Header.Modify();

            ActLine.SetRange("Activity Type", ActLine."Activity Type"::Pick);
            ActLine.SetRange("Whse. Document Type", ActLine."Whse. Document Type"::Shipment);
            ActLine.SetRange("Whse. Document No.", Header."No.");
            ActLine.ModifyAll("PeritusWH Batch Id", BatchId);
        until OrdersDone or (Candidates.Next() = 0);
        if Created = 0 then
            Error(PickError);
    end;

    procedure ReleaseBatch(BatchId: Guid)
    var
        Header: Record "Warehouse Shipment Header";
    begin
        if IsNullGuid(BatchId) then
            exit;
        Header.SetRange("PeritusWH Batch Id", BatchId);
        if Header.FindSet() then
            repeat
                Clear(Header."PeritusWH Batch Id");
                Header."PeritusWH Pattern Code" := '';
                Header."PeritusWH Picked By" := '';
                Header."PeritusWH Claimed At" := 0DT;
                Header.Modify();
            until Header.Next() = 0;
    end;
}
