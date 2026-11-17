table 91130 "PeritusWH License Plate"
{
    Caption = 'PeritusWH License Plate';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { Caption = 'No.'; }
        field(2; "Batch Id"; Guid) { Caption = 'Batch Id'; }
        field(3; "Pattern Code"; Code[20]) { Caption = 'Pattern Code'; TableRelation = "PeritusWH Pick Pattern"; }
        field(4; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; }
        field(5; "Created At"; DateTime) { Caption = 'Created At'; }
        field(6; "Place Confirmed"; Boolean) { Caption = 'Place Confirmed'; }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Batch; "Batch Id", "No.") { }
    }

    trigger OnInsert()
    var
        Shipment: Record "Warehouse Shipment Header";
        Pattern: Record "PeritusWH Pick Pattern";
        NoSeries: Codeunit "No. Series";
    begin
        if IsNullGuid("Batch Id") then
            Error('A pick batch is required to create a license plate.');
        Shipment.SetRange("PeritusWH Batch Id", "Batch Id");
        if not Shipment.FindFirst() then
            Error('No pick pattern was found for batch %1.', "Batch Id");
        Pattern.Get(Shipment."PeritusWH Pattern Code");
        if Pattern."License Plate Nos." = '' then
            Error('Set License Plate Nos. on pick pattern %1 before creating license plates.', Pattern.Code);

        "Pattern Code" := Pattern.Code;
        "No. Series" := Pattern."License Plate Nos.";
        "No." := NoSeries.GetNextNo("No. Series", WorkDate());
        "Created At" := CurrentDateTime();
    end;
}
