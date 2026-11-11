page 91129 "PeritusWH Whse. Employee API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'warehouseEmployee';
    EntitySetName = 'warehouseEmployees';
    SourceTable = "Warehouse Employee";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Warehouse Employee API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(userId; Rec."User ID") { Caption = 'User Id'; Editable = false; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; Editable = false; }
                field(isDefault; Rec.Default) { Caption = 'Default'; Editable = false; }
            }
        }
    }
}
