page 91101 "PeritusWH Purchase Line API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'purchaseOrderLine';
    EntitySetName = 'purchaseOrderLines';
    SourceTable = "Purchase Line";
    SourceTableView = where("Document Type" = const(Order), Type = const(Item));
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Purchase Line API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'Document Number'; Editable = false; }
                field(sequence; Rec."Line No.") { Caption = 'Sequence'; Editable = false; }
                field(itemNumber; Rec."No.") { Caption = 'Item Number'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; Editable = false; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; Editable = false; }
                field(receivedQuantity; Rec."Quantity Received") { Caption = 'Received Quantity'; Editable = false; }
                field(receiveQuantity; Rec."Qty. to Receive") { Caption = 'Receive Quantity'; }
            }
        }
    }
}
