page 91110 "PeritusWH Transfer Line API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'transferOrderLine';
    EntitySetName = 'transferOrderLines';
    SourceTable = "Transfer Line";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Transfer Line API';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(documentNumber; Rec."Document No.") { Caption = 'Document Number'; Editable = false; }
                field(lineNumber; Rec."Line No.") { Caption = 'Line Number'; Editable = false; }
                field(itemNumber; Rec."Item No.") { Caption = 'Item Number'; Editable = false; }
                field(description; Rec.Description) { Caption = 'Description'; Editable = false; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; Editable = false; }
                field(quantityShipped; Rec."Quantity Shipped") { Caption = 'Quantity Shipped'; Editable = false; }
                field(quantityReceived; Rec."Quantity Received") { Caption = 'Quantity Received'; Editable = false; }
                field(qtyToShip; Rec."Qty. to Ship") { Caption = 'Quantity To Ship'; }
                field(qtyToReceive; Rec."Qty. to Receive") { Caption = 'Quantity To Receive'; }
            }
        }
    }
}
