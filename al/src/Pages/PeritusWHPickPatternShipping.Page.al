page 91126 "PeritusWH Pick Shipping Method"
{
    PageType = ListPart;
    SourceTable = "PeritusWH Pick Shipping Method";
    Caption = 'Shipping Methods';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Shipping Method"; Rec."Shipping Method") { ApplicationArea = All; }
                field(Mode; Rec.Mode) { ApplicationArea = All; }
            }
        }
    }
}
