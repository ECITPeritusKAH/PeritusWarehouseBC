table 91120 "PeritusWH Pick Pattern"
{
    Caption = 'Pick Pattern';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[20]) { Caption = 'Code'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; Enabled; Boolean) { Caption = 'Enabled'; InitValue = true; }
        field(4; Priority; Integer) { Caption = 'Priority'; }
        field(5; "Location Code"; Code[10]) { Caption = 'Location Code'; TableRelation = Location; NotBlank = true; }
        field(6; "Order Count"; Integer) { Caption = 'Order Count'; MinValue = 1; InitValue = 1; }
        field(7; "Zone Code"; Code[10]) { Caption = 'Zone Code'; TableRelation = Zone.Code where("Location Code" = field("Location Code")); }
        field(8; "Min Length"; Decimal) { Caption = 'Min Length'; MinValue = 0; }
        field(9; "Max Length"; Decimal) { Caption = 'Max Length'; MinValue = 0; }
        field(10; "Min Weight"; Decimal) { Caption = 'Min Weight'; MinValue = 0; }
        field(11; "Max Weight"; Decimal) { Caption = 'Max Weight'; MinValue = 0; }
        field(12; "From Volume"; Decimal) { Caption = 'From Volume'; MinValue = 0; }
        field(13; "To Volume"; Decimal) { Caption = 'To Volume'; MinValue = 0; }
        field(14; "Container Type"; Text[50]) { Caption = 'Container Type'; }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
        key(Prio; Priority) { }
    }

    trigger OnDelete()
    var
        Ship: Record "PeritusWH Pick Shipping Method";
    begin
        Ship.SetRange("Pattern Code", Code);
        Ship.DeleteAll();
    end;

    trigger OnInsert()
    begin
        if Priority = 0 then
            Priority := 100;
    end;
}
