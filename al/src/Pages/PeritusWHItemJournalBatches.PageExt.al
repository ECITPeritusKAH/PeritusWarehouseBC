pageextension 91104 "PeritusWH Item Journal Batches" extends "Item Journal Batches"
{
    layout
    {
        addlast(Control1)
        {
            field("PeritusWH Released To Mobile"; Rec."PeritusWH Released To Mobile")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the journal is available in the Peritus Warehouse mobile app.';
            }
        }
    }
}
