page 91105 "PeritusWH Put-away API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'putAway';
    EntitySetName = 'putAways';
    SourceTable = "Warehouse Activity Header";
    SourceTableView = where(Type = const("Put-away"));
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Put-away API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'Number'; Editable = false; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; Editable = false; }
                field(assignedUserId; Rec."Assigned User ID") { Caption = 'Assigned User Id'; Editable = false; }
            }
        }
    }

    [ServiceEnabled]
    procedure register(var ActionContext: WebServiceActionContext)
    var
        PeritusWHWhseRegister: Codeunit "PeritusWH Whse. Register";
    begin
        PeritusWHWhseRegister.RegisterActivity(Rec.SystemId);
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"PeritusWH Put-away API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
