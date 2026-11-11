page 91103 "PeritusWH Inv. Count Batch API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'inventoryCountBatch';
    EntitySetName = 'inventoryCountBatches';
    SourceTable = "Item Journal Batch";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Inventory Count Batch API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(journalTemplateName; Rec."Journal Template Name") { Caption = 'Journal Template Name'; Editable = false; }
                field(name; Rec.Name) { Caption = 'Name'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; Editable = false; }
                field(releasedToMobile; Rec."PeritusWH Released To Mobile") { Caption = 'Released To Mobile'; }
            }
        }
    }
}
