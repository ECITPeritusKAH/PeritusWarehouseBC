page 91121 "PeritusWH Pick Pattern API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'pickPattern';
    EntitySetName = 'pickPatterns';
    SourceTable = "PeritusWH Pick Pattern";
    SourceTableView = where(Enabled = const(true));
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Pick Pattern API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(code; Rec.Code) { Caption = 'Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(priority; Rec.Priority) { Caption = 'Priority'; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; }
                field(orderCount; Rec."Order Count") { Caption = 'Order Count'; }
                field(containerType; Rec."Container Type") { Caption = 'Container Type'; }
                field(availableCount; AvailableCount) { Caption = 'Available Count'; }
            }
        }
    }

    var
        AvailableCount: Integer;

    trigger OnAfterGetRecord()
    var
        Matching: Codeunit "PeritusWH Pick Matching";
    begin
        AvailableCount := Matching.CountAvailable(Rec);
    end;
}
