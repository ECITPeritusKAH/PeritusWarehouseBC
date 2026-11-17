page 91135 "PeritusWH License Plate Edit"
{
    PageType = List;
    ApplicationArea = Warehouse;
    UsageCategory = Lists;
    SourceTable = "PeritusWH License Plate";
    Caption = 'License Plate Edit';
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(LicensePlates)
            {
                field("No."; Rec."No.") { ApplicationArea = Warehouse; }
                field("Batch Id"; Rec."Batch Id") { ApplicationArea = Warehouse; }
                field("Pattern Code"; Rec."Pattern Code") { ApplicationArea = Warehouse; }
                field("No. Series"; Rec."No. Series") { ApplicationArea = Warehouse; }
                field("Created At"; Rec."Created At") { ApplicationArea = Warehouse; }
                field("Place Confirmed"; Rec."Place Confirmed") { ApplicationArea = Warehouse; }
            }
        }
    }
}
