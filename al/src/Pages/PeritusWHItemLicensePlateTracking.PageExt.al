pageextension 91133 "PeritusWH Item Card LP" extends "Item Card"
{
    actions
    {
        addlast(Processing)
        {
            action(PeritusWHLicensePlateTracking)
            {
                ApplicationArea = Warehouse;
                Caption = 'License Plate Tracking';
                Image = Tracking;
                ToolTip = 'View pick license-plate quantities recorded for this item.';

                trigger OnAction()
                var
                    TrackingLine: Record "PeritusWH Pick LP Line";
                    TrackingPage: Page "PeritusWH LP Tracking";
                begin
                    TrackingLine.SetRange("Item No.", Rec."No.");
                    TrackingPage.SetTableView(TrackingLine);
                    TrackingPage.Run();
                end;
            }
        }
    }
}
