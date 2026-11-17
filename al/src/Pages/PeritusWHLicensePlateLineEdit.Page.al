page 91136 "PeritusWH LP Line Edit"
{
    PageType = List;
    ApplicationArea = Warehouse;
    UsageCategory = Lists;
    SourceTable = "PeritusWH Pick LP Line";
    Caption = 'License Plate Line Edit';
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(LicensePlateLines)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = Warehouse; }
                field("License Plate No."; Rec."License Plate No.") { ApplicationArea = Warehouse; }
                field("Batch Id"; Rec."Batch Id") { ApplicationArea = Warehouse; }
                field("Activity No."; Rec."Activity No.") { ApplicationArea = Warehouse; }
                field("Activity Line No."; Rec."Activity Line No.") { ApplicationArea = Warehouse; }
                field("Whse. Document Line No."; Rec."Whse. Document Line No.") { ApplicationArea = Warehouse; }
                field("Item No."; Rec."Item No.") { ApplicationArea = Warehouse; }
                field("Bin Code"; Rec."Bin Code") { ApplicationArea = Warehouse; }
                field("Zone Code"; Rec."Zone Code") { ApplicationArea = Warehouse; }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ApplicationArea = Warehouse; }
                field("Take Quantity"; Rec."Take Quantity") { ApplicationArea = Warehouse; }
                field("Place Quantity"; Rec."Place Quantity") { ApplicationArea = Warehouse; }
                field("Posted Quantity"; Rec."Posted Quantity") { ApplicationArea = Warehouse; }
            }
        }
    }
}
