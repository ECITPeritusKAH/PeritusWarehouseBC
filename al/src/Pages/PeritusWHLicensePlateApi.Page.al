page 91130 "PeritusWH License Plate API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'pickLicensePlate';
    EntitySetName = 'pickLicensePlates';
    SourceTable = "PeritusWH License Plate";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Pick License Plate API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'Number'; Editable = false; }
                field(batchId; Rec."Batch Id") { Caption = 'Batch Id'; }
                field(patternCode; Rec."Pattern Code") { Caption = 'Pattern Code'; Editable = false; }
                field(noSeries; Rec."No. Series") { Caption = 'No. Series'; Editable = false; }
                field(createdAt; Rec."Created At") { Caption = 'Created At'; Editable = false; }
            }
        }
    }
}
