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
                field(placeConfirmed; Rec."Place Confirmed") { Caption = 'Place Confirmed'; Editable = false; }
            }
        }
    }

    [ServiceEnabled]
    procedure confirmPlace(var ActionContext: WebServiceActionContext)
    begin
        if not Rec."Place Confirmed" then begin
            Rec."Place Confirmed" := true;
            Rec.Modify(true);
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"PeritusWH License Plate API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
