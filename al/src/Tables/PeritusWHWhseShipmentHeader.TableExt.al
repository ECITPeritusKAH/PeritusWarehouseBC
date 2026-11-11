tableextension 91120 "PeritusWH Whse. Ship. Header" extends "Warehouse Shipment Header"
{
    fields
    {
        field(50100; "PeritusWH Batch Id"; Guid) { Caption = 'Pick Batch Id'; DataClassification = SystemMetadata; }
        field(50101; "PeritusWH Pattern Code"; Code[20]) { Caption = 'Pick Pattern'; DataClassification = SystemMetadata; }
        field(50102; "PeritusWH Picked By"; Code[50]) { Caption = 'Picked By'; DataClassification = EndUserIdentifiableInformation; }
        field(50103; "PeritusWH Claimed At"; DateTime) { Caption = 'Claimed At'; DataClassification = SystemMetadata; }
    }
}
