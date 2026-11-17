table 91131 "PeritusWH Pick LP Line"
{
    Caption = 'Pick License Plate Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "License Plate No."; Code[20]) { Caption = 'License Plate No.'; TableRelation = "PeritusWH License Plate"; }
        field(3; "Batch Id"; Guid) { Caption = 'Batch Id'; }
        field(4; "Activity No."; Code[20]) { Caption = 'Activity No.'; }
        field(5; "Activity Line No."; Integer) { Caption = 'Activity Line No.'; }
        field(6; "Whse. Document Line No."; Integer) { Caption = 'Warehouse Document Line No.'; }
        field(7; "Item No."; Code[20]) { Caption = 'Item No.'; }
        field(8; "Bin Code"; Code[20]) { Caption = 'Bin Code'; }
        field(9; "Zone Code"; Code[10]) { Caption = 'Zone Code'; }
        field(10; "Unit of Measure Code"; Code[10]) { Caption = 'Unit of Measure Code'; }
        field(11; "Take Quantity"; Decimal) { Caption = 'Take Quantity'; MinValue = 0; }
        field(12; "Place Quantity"; Decimal) { Caption = 'Place Quantity'; MinValue = 0; }
        field(13; "Posted Quantity"; Decimal) { Caption = 'Posted Quantity'; MinValue = 0; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Batch; "Batch Id", "Activity No.", "Activity Line No.") { }
    }

    trigger OnInsert()
    var
        LicensePlate: Record "PeritusWH License Plate";
        ActivityLine: Record "Warehouse Activity Line";
        ExistingLine: Record "PeritusWH Pick LP Line";
        Taken: Decimal;
    begin
        if not LicensePlate.Get("License Plate No.") then
            Error('License plate %1 does not exist.', "License Plate No.");
        if LicensePlate."Batch Id" <> "Batch Id" then
            Error('License plate %1 belongs to another pick batch.', "License Plate No.");
        ActivityLine.SetRange("Activity Type", ActivityLine."Activity Type"::Pick);
        ActivityLine.SetRange("No.", "Activity No.");
        ActivityLine.SetRange("Line No.", "Activity Line No.");
        if not ActivityLine.FindFirst() then
            Error('Pick line %1/%2 was not found.', "Activity No.", "Activity Line No.");
        if ActivityLine."Action Type" <> ActivityLine."Action Type"::Take then
            Error('Take quantities can only be recorded on Take lines.');
        if ActivityLine."PeritusWH Batch Id" <> "Batch Id" then
            Error('Pick line %1/%2 belongs to another batch.', "Activity No.", "Activity Line No.");
        if "Take Quantity" <= 0 then
            Error('Take quantity must be greater than zero.');

        ExistingLine.SetRange("Activity No.", "Activity No.");
        ExistingLine.SetRange("Activity Line No.", "Activity Line No.");
        if ExistingLine.FindSet() then
            repeat
                Taken += ExistingLine."Take Quantity" - ExistingLine."Posted Quantity";
            until ExistingLine.Next() = 0;
        if Taken + "Take Quantity" > ActivityLine."Qty. Outstanding" then
            Error('Take quantity exceeds the remaining quantity on pick line %1.', "Activity Line No.");
        "Whse. Document Line No." := ActivityLine."Whse. Document Line No.";
        "Item No." := ActivityLine."Item No.";
        "Bin Code" := ActivityLine."Bin Code";
        "Zone Code" := ActivityLine."Zone Code";
        "Unit of Measure Code" := ActivityLine."Unit of Measure Code";

        ActivityLine.Validate("Qty. to Handle", Taken + "Take Quantity");
        ActivityLine.Modify();
        UpdatePlaceLines(ActivityLine."No.", ActivityLine."Whse. Document Line No.");
    end;

    trigger OnModify()
    var
        ActivityLine: Record "Warehouse Activity Line";
    begin
        if ("License Plate No." <> xRec."License Plate No.") or
           ("Batch Id" <> xRec."Batch Id") or
           ("Activity No." <> xRec."Activity No.") or
           ("Activity Line No." <> xRec."Activity Line No.") or
           ("Take Quantity" <> xRec."Take Quantity")
        then
            Error('License plate, pick line, and Take quantity cannot be changed after the Take is saved.');
        if "Place Quantity" < "Posted Quantity" then
            Error('Place quantity cannot be less than the quantity already posted.');
        if "Place Quantity" > "Take Quantity" then
            Error('Place quantity cannot exceed the quantity taken.');

        ActivityLine.SetRange("Activity Type", ActivityLine."Activity Type"::Pick);
        ActivityLine.SetRange("No.", "Activity No.");
        ActivityLine.SetRange("Action Type", ActivityLine."Action Type"::Place);
        ActivityLine.SetRange("Whse. Document Line No.", "Whse. Document Line No.");
        if "Place Quantity" <> xRec."Place Quantity" then
            UpdatePlaceLineQuantities(ActivityLine);
    end;

    local procedure UpdatePlaceLines(ActivityNo: Code[20]; DocumentLineNo: Integer)
    var
        ActivityLine: Record "Warehouse Activity Line";
    begin
        ActivityLine.SetRange("Activity Type", ActivityLine."Activity Type"::Pick);
        ActivityLine.SetRange("No.", ActivityNo);
        ActivityLine.SetRange("Action Type", ActivityLine."Action Type"::Place);
        ActivityLine.SetRange("Whse. Document Line No.", DocumentLineNo);
        UpdatePlaceLineQuantities(ActivityLine);
    end;

    local procedure UpdatePlaceLineQuantities(var ActivityLine: Record "Warehouse Activity Line")
    var
        ExistingLine: Record "PeritusWH Pick LP Line";
        PlaceToHandle: Decimal;
    begin
        ExistingLine.SetRange("Activity No.", "Activity No.");
        ExistingLine.SetRange("Whse. Document Line No.", "Whse. Document Line No.");
        if ExistingLine.FindSet() then
            repeat
                if ExistingLine."Entry No." = "Entry No." then
                    PlaceToHandle += "Place Quantity" - "Posted Quantity"
                else
                    PlaceToHandle += ExistingLine."Place Quantity" - ExistingLine."Posted Quantity";
            until ExistingLine.Next() = 0;
        if ActivityLine.FindSet() then
            repeat
                ActivityLine.Validate("Qty. to Handle", PlaceToHandle);
                ActivityLine.Modify();
            until ActivityLine.Next() = 0;
    end;
}
