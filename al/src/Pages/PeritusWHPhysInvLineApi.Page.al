page 91102 "PeritusWH Phys. Inv. Line API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'inventoryCountLine';
    EntitySetName = 'inventoryCountLines';
    SourceTable = "Item Journal Line";
    SourceTableView = where("Phys. Inventory" = const(true));
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Inventory Count Line API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(journalTemplateName; Rec."Journal Template Name") { Caption = 'Journal Template Name'; Editable = false; }
                field(journalBatchName; Rec."Journal Batch Name") { Caption = 'Journal Batch Name'; Editable = false; }
                field(sequence; Rec."Line No.") { Caption = 'Sequence'; Editable = false; }
                field(itemNumber; Rec."Item No.") { Caption = 'Item Number'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; Editable = false; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; Editable = false; }
                field(binCode; Rec."Bin Code") { Caption = 'Bin Code'; Editable = false; }
                field(calculatedQuantity; Rec."Qty. (Calculated)") { Caption = 'Calculated Quantity'; Editable = false; }
                field(countedQuantity; Rec."Qty. (Phys. Inventory)") { Caption = 'Counted Quantity'; }
            }
        }
    }
}
