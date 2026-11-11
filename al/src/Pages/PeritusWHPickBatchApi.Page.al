page 91123 "PeritusWH Pick Batch API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'pickBatch';
    EntitySetName = 'pickBatches';
    SourceTable = "Warehouse Shipment Header";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Pick Batch API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(batchId; Rec."PeritusWH Batch Id") { Caption = 'Batch Id'; Editable = false; }
                field(shipmentNumber; Rec."No.") { Caption = 'Shipment Number'; Editable = false; }
                field(patternCode; Rec."PeritusWH Pattern Code") { Caption = 'Pattern Code'; Editable = false; }
                field(pickedBy; Rec."PeritusWH Picked By") { Caption = 'Picked By'; Editable = false; }
            }
        }
    }

    [ServiceEnabled]
    procedure release(var ActionContext: WebServiceActionContext)
    var
        Matching: Codeunit "PeritusWH Pick Matching";
    begin
        Matching.ReleaseBatch(Rec."PeritusWH Batch Id");
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"PeritusWH Pick Batch API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
