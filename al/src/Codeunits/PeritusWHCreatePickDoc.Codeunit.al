codeunit 91129 "PeritusWH Create Pick Doc"
{
    TableNo = "Warehouse Shipment Header";

    trigger OnRun()
    var
        ShptLine: Record "Warehouse Shipment Line";
    begin
        ShptLine.SetRange("No.", Rec."No.");
        ShptLine.SetHideValidationDialog(true);
        ShptLine.CreatePickDoc(ShptLine, Rec);
    end;
}
