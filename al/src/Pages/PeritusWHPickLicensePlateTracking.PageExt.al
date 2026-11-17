pageextension 91134 "PeritusWH Warehouse Pick LP" extends "Warehouse Picks"
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
                ToolTip = 'View license-plate quantities recorded for this warehouse pick.';

                trigger OnAction()
                var
                    TrackingLine: Record "PeritusWH Pick LP Line";
                    TrackingPage: Page "PeritusWH LP Tracking";
                begin
                    TrackingLine.SetRange("Activity No.", Rec."No.");
                    TrackingPage.SetTableView(TrackingLine);
                    TrackingPage.Run();
                end;
            }
        }
    }
}
