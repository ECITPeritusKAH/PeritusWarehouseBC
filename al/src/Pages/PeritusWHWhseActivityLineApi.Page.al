page 91107 "PeritusWH Whse. Act. Line API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'warehouseActivityLine';
    EntitySetName = 'warehouseActivityLines';
    SourceTable = "Warehouse Activity Line";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Warehouse Activity Line API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                // 1 = Put-away, 2 = Pick
                field(activityType; ActivityType) { Caption = 'Activity Type'; Editable = false; }
                field(activityNumber; Rec."No.") { Caption = 'Activity Number'; Editable = false; }
                field(lineNumber; Rec."Line No.") { Caption = 'Line Number'; Editable = false; }
                // 1 = Take, 2 = Place
                field(actionType; ActionType) { Caption = 'Action Type'; Editable = false; }
                field(itemNumber; Rec."Item No.") { Caption = 'Item Number'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; Editable = false; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; Editable = false; }
                field(zoneCode; Rec."Zone Code") { Caption = 'Zone Code'; Editable = false; }
                field(binCode; Rec."Bin Code") { Caption = 'Bin Code'; Editable = false; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; Editable = false; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; Editable = false; }
                field(quantityOutstanding; Rec."Qty. Outstanding") { Caption = 'Quantity Outstanding'; Editable = false; }
                field(quantityHandled; Rec."Qty. Handled") { Caption = 'Quantity Handled'; Editable = false; }
                field(qtyToHandle; Rec."Qty. to Handle") { Caption = 'Quantity To Handle'; }
            }
        }
    }

    var
        ActivityType: Integer;
        ActionType: Integer;

    trigger OnAfterGetRecord()
    begin
        ActivityType := Rec."Activity Type".AsInteger();
        ActionType := Rec."Action Type".AsInteger();
    end;
}
