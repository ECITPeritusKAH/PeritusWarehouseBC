page 91122 "PeritusWH Pick Line API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'pickLine';
    EntitySetName = 'pickLines';
    SourceTable = "Warehouse Activity Line";
    SourceTableView = where("Activity Type" = const(Pick));
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Pick Line API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(batchId; Rec."PeritusWH Batch Id") { Caption = 'Batch Id'; Editable = false; }
                field(activityNumber; Rec."No.") { Caption = 'Activity Number'; Editable = false; }
                field(lineNumber; Rec."Line No.") { Caption = 'Line Number'; Editable = false; }
                field(actionType; ActionType) { Caption = 'Action Type'; Editable = false; }
                field(shipmentNumber; Rec."Whse. Document No.") { Caption = 'Shipment Number'; Editable = false; }
                field(itemNumber; Rec."Item No.") { Caption = 'Item Number'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; Editable = false; }
                field(zoneCode; Rec."Zone Code") { Caption = 'Zone Code'; Editable = false; }
                field(binCode; Rec."Bin Code") { Caption = 'Bin Code'; Editable = false; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; Editable = false; }
                field(qtyToHandle; Rec."Qty. to Handle") { Caption = 'Quantity To Handle'; }
            }
        }
    }

    var
        ActionType: Integer;

    trigger OnAfterGetRecord()
    begin
        ActionType := Rec."Action Type".AsInteger();
    end;
}
