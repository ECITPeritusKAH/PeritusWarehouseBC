table 91121 "PeritusWH Pick Shipping Method"
{
    Caption = 'Pick Pattern Shipping Method';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Pattern Code"; Code[20]) { Caption = 'Pattern Code'; TableRelation = "PeritusWH Pick Pattern"; }
        field(2; "Shipping Method"; Code[10]) { Caption = 'Shipping Method'; TableRelation = "Shipment Method"; }
        field(3; Mode; Enum "PeritusWH Shipping Filter Mode") { Caption = 'Mode'; }
    }

    keys
    {
        key(PK; "Pattern Code", "Shipping Method") { Clustered = true; }
    }
}
