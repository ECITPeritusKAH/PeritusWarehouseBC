codeunit 91127 "PeritusWH Demo Data"
{
    // Creates demo data for testing route picking: location PWDEMO with bins and stock, items with
    // dimensions/weight, pick patterns and released warehouse shipments. Master data is created
    // once; every run adds a new set of released shipments.

    procedure Create(): Integer
    var
        Created: Integer;
    begin
        EnsureShipmentMethods();
        DeleteUnclaimedPicks();
        EnsureUnitOfMeasure();
        EnsureLocation();
        EnsureWarehouseEmployee();
        EnsureItem(ItemSmall(), 'Demo item - small', 20, 10, 5, 0.3);
        EnsureItem(ItemMedium(), 'Demo item - medium', 40, 30, 20, 2);
        EnsureItem(ItemLong(), 'Demo item - long', 180, 10, 10, 3);
        EnsureItem(ItemHeavy(), 'Demo item - heavy', 50, 40, 40, 25);
        EnsurePatterns();
        PostStock(ItemSmall(), 500);
        PostStock(ItemMedium(), 500);
        PostStock(ItemLong(), 500);
        PostStock(ItemHeavy(), 500);
        Created := CreateOrders();
        exit(Created);
    end;

    // Picks left behind by earlier failed pick requests hide shipments from the patterns.
    local procedure DeleteUnclaimedPicks()
    var
        ActHeader: Record "Warehouse Activity Header";
        ActLine: Record "Warehouse Activity Line";
        ShptHeader: Record "Warehouse Shipment Header";
    begin
        ActHeader.SetRange(Type, ActHeader.Type::Pick);
        ActHeader.SetRange("Location Code", LocationCode());
        if ActHeader.FindSet() then
            repeat
                ActLine.SetRange("Activity Type", ActHeader.Type);
                ActLine.SetRange("No.", ActHeader."No.");
                ActLine.SetFilter("Qty. Handled", '<>0');
                if ActLine.IsEmpty() then begin
                    ActLine.SetRange("Qty. Handled");
                    ActLine.SetRange("Whse. Document Type", ActLine."Whse. Document Type"::Shipment);
                    if ActLine.FindFirst() then
                        if ShptHeader.Get(ActLine."Whse. Document No.") then
                            if ShptHeader."PeritusWH Picked By" = '' then
                                ActHeader.Delete(true);
                end;
            until ActHeader.Next() = 0;
    end;

    local procedure CreateOrders(): Integer
    var
        Customers: List of [Code[20]];
        Count: Integer;
    begin
        GetCustomers(Customers);

        // Small items, standard shipping: pattern SMALL
        Count += AddOrder(Customers, StdMethod(), 0, ItemSmall(), 1, '', 0);
        Count += AddOrder(Customers, StdMethod(), 0, ItemSmall(), 2, '', 0);
        Count += AddOrder(Customers, StdMethod(), 1, ItemSmall(), 3, '', 0);
        Count += AddOrder(Customers, StdMethod(), 1, ItemSmall(), 1, ItemMedium(), 1);
        Count += AddOrder(Customers, StdMethod(), 2, ItemSmall(), 2, '', 0);
        Count += AddOrder(Customers, StdMethod(), 2, ItemMedium(), 1, '', 0);
        Count += AddOrder(Customers, StdMethod(), 3, ItemMedium(), 2, '', 0);
        Count += AddOrder(Customers, StdMethod(), 3, ItemSmall(), 3, '', 0);

        // Express shipping: pattern EXPRESS
        Count += AddOrder(Customers, ExpressMethod(), 0, ItemSmall(), 1, '', 0);
        Count += AddOrder(Customers, ExpressMethod(), 0, ItemSmall(), 2, '', 0);
        Count += AddOrder(Customers, ExpressMethod(), 1, ItemMedium(), 1, '', 0);

        // Long item: pattern LONG
        Count += AddOrder(Customers, StdMethod(), 0, ItemLong(), 1, '', 0);
        Count += AddOrder(Customers, StdMethod(), 1, ItemLong(), 1, ItemSmall(), 2);

        // Heavy item: pattern HEAVY
        Count += AddOrder(Customers, StdMethod(), 0, ItemHeavy(), 1, '', 0);
        Count += AddOrder(Customers, StdMethod(), 2, ItemHeavy(), 2, '', 0);

        // Too heavy for SMALL, no other filter hit: pattern STANDARD
        Count += AddOrder(Customers, StdMethod(), 0, ItemMedium(), 4, '', 0);
        Count += AddOrder(Customers, StdMethod(), 1, ItemMedium(), 5, '', 0);
        Count += AddOrder(Customers, StdMethod(), 2, ItemMedium(), 6, '', 0);
        exit(Count);
    end;

    local procedure AddOrder(var Customers: List of [Code[20]]; ShipmentMethod: Code[10]; DaysOffset: Integer; Item1: Code[20]; Qty1: Decimal; Item2: Code[20]; Qty2: Decimal): Integer
    var
        SalesHeader: Record "Sales Header";
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
        WhseShptRelease: Codeunit "Whse.-Shipment Release";
        CustomerNo: Code[20];
    begin
        CustomerNo := Customers.Get((NextCustomer mod Customers.Count()) + 1);
        NextCustomer += 1;

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode());
        SalesHeader.Validate("Shipment Method Code", ShipmentMethod);
        SalesHeader.Validate("Shipment Date", WorkDate() + DaysOffset);
        SalesHeader.Validate("Your Reference", 'PWDEMO');
        SalesHeader.Modify(true);

        AddSalesLine(SalesHeader, 10000, Item1, Qty1);
        if Item2 <> '' then
            AddSalesLine(SalesHeader, 20000, Item2, Qty2);

        ReleaseSalesDoc.PerformManualRelease(SalesHeader);
        GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader);

        WhseShptLine.SetRange("Source Type", Database::"Sales Line");
        WhseShptLine.SetRange("Source Subtype", SalesHeader."Document Type".AsInteger());
        WhseShptLine.SetRange("Source No.", SalesHeader."No.");
        if not WhseShptLine.FindFirst() then
            Error('No warehouse shipment was created for sales order %1.', SalesHeader."No.");
        WhseShptHeader.Get(WhseShptLine."No.");
        WhseShptHeader.Validate("Shipment Method Code", ShipmentMethod);
        WhseShptHeader.Modify(true);
        WhseShptRelease.Release(WhseShptHeader);
        exit(1);
    end;

    local procedure AddSalesLine(SalesHeader: Record "Sales Header"; LineNo: Integer; ItemNo: Code[20]; Quantity: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        SalesLine.Validate("Location Code", LocationCode());
        SalesLine.Validate(Quantity, Quantity);
        SalesLine.Modify(true);
    end;

    local procedure GetCustomers(var Customers: List of [Code[20]])
    var
        Customer: Record Customer;
    begin
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        Customer.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        Customer.SetFilter("Customer Posting Group", '<>%1', '');
        if Customer.FindSet() then
            repeat
                Customers.Add(Customer."No.");
            until (Customer.Next() = 0) or (Customers.Count() >= 5);
        if Customers.Count() = 0 then
            Error('No unblocked customer with posting groups exists to create demo orders for.');
    end;

    local procedure EnsureShipmentMethods()
    begin
        EnsureShipmentMethod(StdMethod(), 'Demo standard shipping');
        EnsureShipmentMethod(ExpressMethod(), 'Demo express shipping');
    end;

    local procedure EnsureShipmentMethod(MethodCode: Code[10]; Description: Text[100])
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if ShipmentMethod.Get(MethodCode) then
            exit;
        ShipmentMethod.Init();
        ShipmentMethod.Code := MethodCode;
        ShipmentMethod.Description := CopyStr(Description, 1, MaxStrLen(ShipmentMethod.Description));
        ShipmentMethod.Insert(true);
    end;

    local procedure EnsureUnitOfMeasure()
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if UnitOfMeasure.Get(UoMCode()) then begin
            if UnitOfMeasure."International Standard Code" = '' then begin
                UnitOfMeasure."International Standard Code" := 'C62';
                UnitOfMeasure.Modify(true);
            end;
            exit;
        end;
        UnitOfMeasure.Init();
        UnitOfMeasure."International Standard Code" := 'C62';
        UnitOfMeasure.Code := UoMCode();
        UnitOfMeasure.Description := 'Piece';
        UnitOfMeasure.Insert(true);
    end;

    local procedure EnsureLocation()
    var
        Location: Record Location;
    begin
        if not Location.Get(LocationCode()) then begin
            Location.Init();
            Location.Code := LocationCode();
            Location.Name := 'Peritus Warehouse demo';
            Location.Insert(true);
            Location.Validate("Bin Mandatory", true);
            Location.Validate("Require Pick", true);
            Location.Validate("Require Shipment", true);
            Location.Modify(true);
        end;
        EnsureBin(BinFor(ItemSmall()));
        EnsureBin(BinFor(ItemMedium()));
        EnsureBin(BinFor(ItemLong()));
        EnsureBin(BinFor(ItemHeavy()));
    end;

    local procedure EnsureBin(BinCode: Code[20])
    var
        Bin: Record Bin;
    begin
        if Bin.Get(LocationCode(), BinCode) then
            exit;
        Bin.Init();
        Bin."Location Code" := LocationCode();
        Bin.Code := BinCode;
        Bin.Insert(true);
    end;

    local procedure EnsureWarehouseEmployee()
    var
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        if WarehouseEmployee.Get(UserId(), LocationCode()) then
            exit;
        WarehouseEmployee.Init();
        WarehouseEmployee."User ID" := CopyStr(UserId(), 1, MaxStrLen(WarehouseEmployee."User ID"));
        WarehouseEmployee."Location Code" := LocationCode();
        WarehouseEmployee.Insert(true);
    end;

    local procedure EnsureItem(ItemNo: Code[20]; Description: Text[100]; Length: Decimal; Width: Decimal; Height: Decimal; Weight: Decimal)
    var
        Item: Record Item;
        Template: Record Item;
        ItemUoM: Record "Item Unit of Measure";
    begin
        if Item.Get(ItemNo) then
            exit;

        Template.SetRange(Type, Template.Type::Inventory);
        Template.SetRange(Blocked, false);
        Template.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        Template.SetFilter("Inventory Posting Group", '<>%1', '');
        if not Template.FindFirst() then
            Error('No existing inventory item with posting groups exists to copy posting setup from.');

        Item.Init();
        Item."No." := ItemNo;
        Item.Insert(true);

        ItemUoM.Init();
        ItemUoM."Item No." := ItemNo;
        ItemUoM.Code := UoMCode();
        ItemUoM.Validate("Qty. per Unit of Measure", 1);
        ItemUoM.Validate(Length, Length);
        ItemUoM.Validate(Width, Width);
        ItemUoM.Validate(Height, Height);
        ItemUoM.Validate(Weight, Weight);
        ItemUoM.Insert(true);

        Item.Validate(Description, Description);
        Item.Validate("Base Unit of Measure", UoMCode());
        Item.Validate("Gen. Prod. Posting Group", Template."Gen. Prod. Posting Group");
        Item.Validate("Inventory Posting Group", Template."Inventory Posting Group");
        Item.Validate("VAT Prod. Posting Group", Template."VAT Prod. Posting Group");
        Item.Modify(true);

        EnsureInventoryPostingSetup(Item."Inventory Posting Group");
    end;

    local procedure EnsureInventoryPostingSetup(InventoryPostingGroup: Code[20])
    var
        InvtPostingSetup: Record "Inventory Posting Setup";
        SourceSetup: Record "Inventory Posting Setup";
    begin
        if InvtPostingSetup.Get(LocationCode(), InventoryPostingGroup) then
            exit;
        SourceSetup.SetRange("Invt. Posting Group Code", InventoryPostingGroup);
        if not SourceSetup.FindFirst() then
            Error('Inventory posting setup for group %1 does not exist.', InventoryPostingGroup);
        InvtPostingSetup.Init();
        InvtPostingSetup.TransferFields(SourceSetup, false);
        InvtPostingSetup."Location Code" := LocationCode();
        InvtPostingSetup."Invt. Posting Group Code" := InventoryPostingGroup;
        InvtPostingSetup.Insert(true);
    end;

    local procedure PostStock(ItemNo: Code[20]; TargetQuantity: Decimal)
    var
        Item: Record Item;
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
    begin
        Item.Get(ItemNo);
        Item.SetRange("Location Filter", LocationCode());
        Item.CalcFields(Inventory);
        if Item.Inventory >= TargetQuantity then
            exit;

        ItemJnlTemplate.SetRange(Type, ItemJnlTemplate.Type::Item);
        ItemJnlTemplate.SetRange(Recurring, false);
        if not ItemJnlTemplate.FindFirst() then
            Error('No item journal template exists to post demo stock with.');
        if not ItemJnlBatch.Get(ItemJnlTemplate.Name, BatchName()) then begin
            ItemJnlBatch.Init();
            ItemJnlBatch."Journal Template Name" := ItemJnlTemplate.Name;
            ItemJnlBatch.Name := BatchName();
            ItemJnlBatch.Insert(true);
        end;

        ItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplate.Name);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName());
        ItemJnlLine.DeleteAll();
        ItemJnlLine.Reset();

        ItemJnlLine.Init();
        ItemJnlLine."Journal Template Name" := ItemJnlTemplate.Name;
        ItemJnlLine."Journal Batch Name" := BatchName();
        ItemJnlLine."Line No." := 10000;
        ItemJnlLine.Insert(true);
        ItemJnlLine.Validate("Posting Date", WorkDate());
        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
        ItemJnlLine."Document No." := BatchName();
        ItemJnlLine.Validate("Item No.", ItemNo);
        ItemJnlLine.Validate("Location Code", LocationCode());
        ItemJnlLine.Validate("Bin Code", BinFor(ItemNo));
        ItemJnlLine.Validate(Quantity, TargetQuantity - Item.Inventory);
        ItemJnlLine.Modify(true);

        Clear(ItemJnlLine);
        ItemJnlLine."Journal Template Name" := ItemJnlTemplate.Name;
        ItemJnlLine."Journal Batch Name" := BatchName();
        Commit();
        if not Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJnlLine) then
            Error('Could not post demo stock for item %1: %2', ItemNo, GetLastErrorText());
    end;

    local procedure EnsurePatterns()
    begin
        EnsurePattern('PW-EXPRESS', 'Express orders', 1, 2, 0, 0, 0, 0, 'Express crate', true);
        EnsurePattern('PW-LONG', 'Long items', 5, 1, 0, 0, 100, 0, 'Long box', false);
        EnsurePattern('PW-HEAVY', 'Heavy items', 10, 1, 0, 20, 0, 0, 'Pallet', false);
        EnsurePattern('PW-SMALL', 'Small orders', 20, 4, 50, 0, 0, 5, 'Small box', false);
        EnsurePattern('PW-STANDARD', 'Standard orders', 100, 2, 0, 0, 0, 0, 'Standard box', false);
    end;

    local procedure EnsurePattern(PatternCode: Code[20]; Description: Text[100]; Priority: Integer; OrderCount: Integer; MaxLength: Decimal; MinWeight: Decimal; MinLength: Decimal; MaxWeight: Decimal; ContainerType: Text[50]; ExpressOnly: Boolean)
    var
        Pattern: Record "PeritusWH Pick Pattern";
        ShippingMethod: Record "PeritusWH Pick Shipping Method";
    begin
        if Pattern.Get(PatternCode) then
            exit;
        Pattern.Init();
        Pattern.Code := PatternCode;
        Pattern.Description := Description;
        Pattern.Enabled := true;
        Pattern.Priority := Priority;
        Pattern."Location Code" := LocationCode();
        Pattern."Order Count" := OrderCount;
        Pattern."Min Length" := MinLength;
        Pattern."Max Length" := MaxLength;
        Pattern."Min Weight" := MinWeight;
        Pattern."Max Weight" := MaxWeight;
        Pattern."Container Type" := ContainerType;
        Pattern.Insert(true);

        if ExpressOnly then begin
            ShippingMethod.Init();
            ShippingMethod."Pattern Code" := PatternCode;
            ShippingMethod."Shipping Method" := ExpressMethod();
            ShippingMethod.Mode := ShippingMethod.Mode::Include;
            ShippingMethod.Insert(true);
        end;
    end;

    local procedure LocationCode(): Code[10]
    begin
        exit('PWDEMO');
    end;

    local procedure BatchName(): Code[10]
    begin
        exit('PWDEMO');
    end;

    local procedure UoMCode(): Code[10]
    begin
        exit('PCS');
    end;

    local procedure StdMethod(): Code[10]
    begin
        exit('PW-STD');
    end;

    local procedure ExpressMethod(): Code[10]
    begin
        exit('PW-EXPR');
    end;

    local procedure ItemSmall(): Code[20]
    begin
        exit('PWDEMO-S');
    end;

    local procedure ItemMedium(): Code[20]
    begin
        exit('PWDEMO-M');
    end;

    local procedure ItemLong(): Code[20]
    begin
        exit('PWDEMO-L');
    end;

    local procedure ItemHeavy(): Code[20]
    begin
        exit('PWDEMO-H');
    end;

    local procedure BinFor(ItemNo: Code[20]): Code[20]
    begin
        exit('BIN-' + CopyStr(ItemNo, StrLen(ItemNo)));
    end;

    var
        NextCustomer: Integer;
}
