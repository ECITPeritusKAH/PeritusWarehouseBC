codeunit 91108 "PeritusWH Whse. Register"
{
    procedure RegisterActivity(HeaderSystemId: Guid)
    var
        WhseActivityHeader: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActRegister: Codeunit "Whse.-Activity-Register";
    begin
        WhseActivityHeader.GetBySystemId(HeaderSystemId);
        WhseActivityLine.SetRange("Activity Type", WhseActivityHeader.Type);
        WhseActivityLine.SetRange("No.", WhseActivityHeader."No.");
        WhseActivityLine.FindFirst();
        if (WhseActivityHeader.Type = WhseActivityHeader.Type::Pick) and HasPickBatch(WhseActivityHeader."No.") then begin
            RegisterPickActivity(WhseActivityHeader."No.");
            exit;
        end;
        WhseActRegister.Run(WhseActivityLine);
    end;

    local procedure HasPickBatch(ActivityNo: Code[20]): Boolean
    var
        ActivityLine: Record "Warehouse Activity Line";
    begin
        ActivityLine.SetRange("Activity Type", ActivityLine."Activity Type"::Pick);
        ActivityLine.SetRange("No.", ActivityNo);
        ActivityLine.SetFilter("PeritusWH Batch Id", '<>%1', ZeroGuid());
        exit(not ActivityLine.IsEmpty());
    end;

    local procedure RegisterPickActivity(ActivityNo: Code[20])
    var
        ActivityLine: Record "Warehouse Activity Line";
        LicensePlateLine: Record "PeritusWH Pick LP Line";
        WhseActRegister: Codeunit "Whse.-Activity-Register";
        RegisterQty: Decimal;
        HasTake: Boolean;
        HasPlaceToRegister: Boolean;
    begin
        ActivityLine.SetRange("Activity Type", ActivityLine."Activity Type"::Pick);
        ActivityLine.SetRange("No.", ActivityNo);
        if ActivityLine.FindSet() then
            repeat
                RegisterQty := 0;
                if ActivityLine."Action Type" = ActivityLine."Action Type"::Take then begin
                    HasTake := true;
                    LicensePlateLine.Reset();
                    LicensePlateLine.SetRange("Activity No.", ActivityNo);
                    LicensePlateLine.SetRange("Activity Line No.", ActivityLine."Line No.");
                    if LicensePlateLine.FindSet() then
                        repeat
                            if LicensePlateLine."Place Quantity" > LicensePlateLine."Take Quantity" then
                                Error('Place quantity exceeds Take quantity for license plate %1.', LicensePlateLine."License Plate No.");
                            RegisterQty += LicensePlateLine."Place Quantity" - LicensePlateLine."Posted Quantity";
                        until LicensePlateLine.Next() = 0;
                end else begin
                LicensePlateLine.Reset();
                LicensePlateLine.SetRange("Activity No.", ActivityNo);
                    LicensePlateLine.SetRange("Whse. Document Line No.", ActivityLine."Whse. Document Line No.");
                    if LicensePlateLine.FindSet() then
                        repeat
                            RegisterQty += LicensePlateLine."Place Quantity" - LicensePlateLine."Posted Quantity";
                        until LicensePlateLine.Next() = 0;
                end;
                if RegisterQty > 0 then
                    HasPlaceToRegister := true;
                ActivityLine.Validate("Qty. to Handle", RegisterQty);
                ActivityLine.Modify();
            until ActivityLine.Next() = 0;

        if not HasTake then
            Error('No Take lines were found for pick %1.', ActivityNo);
        if not HasPlaceToRegister then
            Error('Place at least part of the picked quantity before registering pick %1.', ActivityNo);
        ActivityLine.SetRange("Action Type", ActivityLine."Action Type"::Take);
        ActivityLine.FindFirst();
        WhseActRegister.Run(ActivityLine);

        LicensePlateLine.Reset();
        LicensePlateLine.SetRange("Activity No.", ActivityNo);
        if LicensePlateLine.FindSet(true) then
            repeat
                LicensePlateLine."Posted Quantity" := LicensePlateLine."Place Quantity";
                LicensePlateLine.Modify();
            until LicensePlateLine.Next() = 0;
    end;

    local procedure ZeroGuid(): Guid
    var
        EmptyGuid: Guid;
    begin
        exit(EmptyGuid);
    end;
}
