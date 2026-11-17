tableextension 91122 "PeritusWH Whse. Act. Header" extends "Warehouse Activity Header"
{
    fields
    {
        field(50100; "PeritusWH Active LP No."; Code[20])
        {
            Caption = 'Active License Plate No.';
            DataClassification = CustomerContent;
            TableRelation = "PeritusWH License Plate"."No.";

            trigger OnValidate()
            var
                LicensePlate: Record "PeritusWH License Plate";
                ActivityLine: Record "Warehouse Activity Line";
            begin
                if "PeritusWH Active LP No." = '' then
                    exit;
                if not LicensePlate.Get("PeritusWH Active LP No.") then
                    Error('License plate %1 does not exist.', "PeritusWH Active LP No.");

                ActivityLine.SetRange("Activity Type", ActivityLine."Activity Type"::Pick);
                ActivityLine.SetRange("No.", "No.");
                ActivityLine.SetRange("PeritusWH Batch Id", LicensePlate."Batch Id");
                if ActivityLine.IsEmpty() then
                    Error('License plate %1 does not belong to the batch for pick %2.', LicensePlate."No.", "No.");
            end;
        }
    }
}
