table 91122 "PeritusWH Pick Request"
{
    Caption = 'Pick Request';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Batch Id"; Guid) { Caption = 'Batch Id'; }
        field(2; "Pattern Code"; Code[20]) { Caption = 'Pattern Code'; TableRelation = "PeritusWH Pick Pattern"; }
        field(3; "Operator"; Code[50]) { Caption = 'Operator'; }
    }

    keys
    {
        key(PK; "Batch Id") { Clustered = true; }
    }
}
