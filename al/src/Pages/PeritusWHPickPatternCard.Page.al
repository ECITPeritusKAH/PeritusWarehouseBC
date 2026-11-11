page 91125 "PeritusWH Pick Pattern Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "PeritusWH Pick Pattern";
    Caption = 'Pick Pattern';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Enabled; Rec.Enabled) { ApplicationArea = All; }
                field(Priority; Rec.Priority) { ApplicationArea = All; ToolTip = 'Lowest number wins when an order matches several patterns.'; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; }
                field("Order Count"; Rec."Order Count") { ApplicationArea = All; ToolTip = 'Max orders per pick. Fewer are picked if fewer are available.'; }
                field("Container Type"; Rec."Container Type") { ApplicationArea = All; }
            }
            group(Filters)
            {
                field("Zone Code"; Rec."Zone Code") { ApplicationArea = All; ToolTip = 'Order qualifies if at least one line is in this zone.'; }
                field("Min Length"; Rec."Min Length") { ApplicationArea = All; }
                field("Max Length"; Rec."Max Length") { ApplicationArea = All; }
                field("Min Weight"; Rec."Min Weight") { ApplicationArea = All; }
                field("Max Weight"; Rec."Max Weight") { ApplicationArea = All; }
                field("From Volume"; Rec."From Volume") { ApplicationArea = All; }
                field("To Volume"; Rec."To Volume") { ApplicationArea = All; }
            }
            part(Shipping; "PeritusWH Pick Shipping Method")
            {
                ApplicationArea = All;
                SubPageLink = "Pattern Code" = field(Code);
            }
        }
    }
}
