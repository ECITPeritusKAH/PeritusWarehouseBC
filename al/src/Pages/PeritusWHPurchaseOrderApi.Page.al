page 91100 "PeritusWH Purchase Order API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'purchaseOrder';
    EntitySetName = 'purchaseOrders';
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = const(Order));
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Purchase Order API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'Number'; Editable = false; }
                field(vendorNumber; Rec."Buy-from Vendor No.") { Caption = 'Vendor Number'; Editable = false; }
                field(vendorName; Rec."Buy-from Vendor Name") { Caption = 'Vendor Name'; Editable = false; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
            }
        }
    }

    [ServiceEnabled]
    procedure receive(var ActionContext: WebServiceActionContext)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
    begin
        PurchaseHeader.GetBySystemId(Rec.SystemId);
        if PurchaseHeader.Status <> PurchaseHeader.Status::Released then
            Error('Purchase order %1 must be released before it can be received.', PurchaseHeader."No.");
        PurchaseHeader.Receive := true;
        PurchaseHeader.Invoice := false;
        PurchPost.Run(PurchaseHeader);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"PeritusWH Purchase Order API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), PurchaseHeader.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
