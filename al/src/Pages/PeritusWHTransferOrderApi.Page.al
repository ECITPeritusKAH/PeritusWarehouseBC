page 91109 "PeritusWH Transfer Order API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'transferOrder';
    EntitySetName = 'transferOrders';
    SourceTable = "Transfer Header";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Transfer Order API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'Number'; Editable = false; }
                field(fromCode; Rec."Transfer-from Code") { Caption = 'Transfer-from Code'; Editable = false; }
                field(toCode; Rec."Transfer-to Code") { Caption = 'Transfer-to Code'; Editable = false; }
                field(inTransitCode; Rec."In-Transit Code") { Caption = 'In-Transit Code'; Editable = false; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
            }
        }
    }

    [ServiceEnabled]
    procedure ship(var ActionContext: WebServiceActionContext)
    var
        TransferHeader: Record "Transfer Header";
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
    begin
        TransferHeader.GetBySystemId(Rec.SystemId);
        if TransferHeader.Status <> TransferHeader.Status::Released then
            Error('Transfer order %1 must be released before it can be shipped.', TransferHeader."No.");
        TransferPostShipment.Run(TransferHeader);
        SetResult(ActionContext, TransferHeader.SystemId);
    end;

    [ServiceEnabled]
    procedure receive(var ActionContext: WebServiceActionContext)
    var
        TransferHeader: Record "Transfer Header";
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
    begin
        TransferHeader.GetBySystemId(Rec.SystemId);
        TransferPostReceipt.Run(TransferHeader);
        SetResult(ActionContext, TransferHeader.SystemId);
    end;

    local procedure SetResult(var ActionContext: WebServiceActionContext; Id: Guid)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"PeritusWH Transfer Order API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Id);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
