page 91106 "PeritusWH Pick API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'pick';
    EntitySetName = 'picks';
    SourceTable = "Warehouse Activity Header";
    SourceTableView = where(Type = const(Pick));
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Pick API';

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
        ActionContext.SetObjectId(Page::"PeritusWH Pick API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
