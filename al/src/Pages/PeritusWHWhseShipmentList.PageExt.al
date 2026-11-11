pageextension 91105 "PeritusWH Whse. Shipment List" extends "Warehouse Shipment List"
{
    layout
    {
        addlast(Control1)
        {
            field(PeritusWHPatternCode; Rec."PeritusWH Pattern Code")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the pick pattern the shipment was claimed under.';
            }
            field(PeritusWHPickedBy; Rec."PeritusWH Picked By")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the user who claimed the shipment in a pick batch.';
            }
            field(PeritusWHClaimedAt; Rec."PeritusWH Claimed At")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies when the shipment was claimed in a pick batch.';
            }
            field(PeritusWHBatchId; Rec."PeritusWH Batch Id")
            {
                ApplicationArea = Warehouse;
                Visible = false;
                ToolTip = 'Specifies the pick batch the shipment belongs to.';
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(PeritusWHReleasePickBatch)
            {
                ApplicationArea = Warehouse;
                Caption = 'Release Pick Batch Claim';
                Image = ReleaseDoc;
                ToolTip = 'Clear the pick batch claim on this shipment and all shipments in the same batch, so they can match a pick pattern again. Warehouse picks already created are kept.';

                trigger OnAction()
                var
                    Matching: Codeunit "PeritusWH Pick Matching";
                begin
                    if IsNullGuid(Rec."PeritusWH Batch Id") then
                        Error(NotClaimedErr);
                    if not Confirm(ReleaseQst) then
                        exit;
                    Matching.ReleaseBatch(Rec."PeritusWH Batch Id");
                    CurrPage.Update(false);
                end;
            }
            action(PeritusWHClearClaim)
            {
                ApplicationArea = Warehouse;
                Caption = 'Clear Claim (Selected)';
                Image = ClearLog;
                ToolTip = 'Remove Claimed At, Picked By and Pattern Code on the selected shipments only, so they can match a pick pattern again. Warehouse picks already created are kept.';

                trigger OnAction()
                var
                    Shipment: Record "Warehouse Shipment Header";
                begin
                    CurrPage.SetSelectionFilter(Shipment);
                    Shipment.SetFilter("PeritusWH Picked By", '<>''''');
                    if Shipment.IsEmpty() then
                        Error(NoneClaimedErr);
                    if not Confirm(ClearQst, false, Shipment.Count()) then
                        exit;
                    Shipment.FindSet(true);
                    repeat
                        Clear(Shipment."PeritusWH Batch Id");
                        Shipment."PeritusWH Pattern Code" := '';
                        Shipment."PeritusWH Picked By" := '';
                        Shipment."PeritusWH Claimed At" := 0DT;
                        Shipment.Modify();
                    until Shipment.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        NoneClaimedErr: Label 'None of the selected shipments are claimed.';
        ClearQst: Label 'Remove the claim on %1 selected shipment(s)?', Comment = '%1 = number of shipments';
        NotClaimedErr: Label 'The shipment is not part of a pick batch.';
        ReleaseQst: Label 'Release the pick batch claim for this shipment and the other shipments in the batch?';
}
