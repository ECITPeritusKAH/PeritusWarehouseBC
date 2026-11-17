page 91131 "PeritusWH Pick LP Line API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'pickLicensePlateLine';
    EntitySetName = 'pickLicensePlateLines';
    SourceTable = "PeritusWH Pick LP Line";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = false;
    Caption = 'Pick License Plate Line API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(entryNumber; Rec."Entry No.") { Caption = 'Entry Number'; Editable = false; }
                field(licensePlateNumber; Rec."License Plate No.") { Caption = 'License Plate Number'; }
                field(batchId; Rec."Batch Id") { Caption = 'Batch Id'; }
                field(activityNumber; Rec."Activity No.") { Caption = 'Activity Number'; }
                field(activityLineNumber; Rec."Activity Line No.") { Caption = 'Activity Line Number'; }
                field(warehouseDocumentLineNumber; Rec."Whse. Document Line No.") { Caption = 'Warehouse Document Line Number'; Editable = false; }
                field(itemNumber; Rec."Item No.") { Caption = 'Item Number'; Editable = false; }
                field(binCode; Rec."Bin Code") { Caption = 'Bin Code'; Editable = false; }
                field(zoneCode; Rec."Zone Code") { Caption = 'Zone Code'; Editable = false; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; Editable = false; }
                field(takeQuantity; Rec."Take Quantity") { Caption = 'Take Quantity'; }
                field(placeQuantity; Rec."Place Quantity") { Caption = 'Place Quantity'; }
                field(postedQuantity; Rec."Posted Quantity") { Caption = 'Posted Quantity'; Editable = false; }
            }
        }
    }
}
