page 91132 "PeritusWH LP Tracking"
{
    PageType = List;
    ApplicationArea = Warehouse;
    UsageCategory = Lists;
    SourceTable = "PeritusWH Pick LP Line";
    SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'License Plate Tracking';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Tracking)
            {
                field("License Plate No."; Rec."License Plate No.") { ApplicationArea = Warehouse; }
                field("Item No."; Rec."Item No.") { ApplicationArea = Warehouse; }
                field("Activity No."; Rec."Activity No.") { ApplicationArea = Warehouse; }
                field("Batch Id"; Rec."Batch Id") { ApplicationArea = Warehouse; }
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
