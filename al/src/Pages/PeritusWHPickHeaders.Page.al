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
    ModifyAllowed = true;
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
                field(activeLicensePlateNumber; Rec."PeritusWH Active LP No.") { Caption = 'Active License Plate Number'; }
                field(destinationCustomerName; DestinationCustomerName) { Caption = 'Destination Customer Name'; Editable = false; }
            }
        }
    }

    var
        DestinationCustomerName: Text[100];

    trigger OnAfterGetRecord()
    var
        PickListLine: Record "Warehouse Activity Line";
        Customer: Record Customer;
    begin
        Clear(DestinationCustomerName);
        PickListLine.SetRange("Activity Type", PickListLine."Activity Type"::Pick);
        PickListLine.SetRange("No.", Rec."No.");
        if not PickListLine.FindFirst() then
            exit;
        if PickListLine."Destination Type" <> PickListLine."Destination Type"::Customer then
            exit;
        if PickListLine."Destination No." = '' then
            exit;
        if Customer.Get(PickListLine."Destination No.") then
            DestinationCustomerName := Customer.Name;
    end;

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
