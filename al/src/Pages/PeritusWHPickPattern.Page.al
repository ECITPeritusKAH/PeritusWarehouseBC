page 91120 "PeritusWH Pick Patterns"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PeritusWH Pick Pattern";
    Caption = 'Pick Patterns';
    CardPageId = "PeritusWH Pick Pattern Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Enabled; Rec.Enabled) { ApplicationArea = All; }
                field(Priority; Rec.Priority) { ApplicationArea = All; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; }
                field("Order Count"; Rec."Order Count") { ApplicationArea = All; }
                field(Available; Available) { ApplicationArea = All; Caption = 'Available Orders'; Editable = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PeritusWHCreateDemoData)
            {
                ApplicationArea = All;
                Caption = 'Create Demo Data';
                Image = TestFile;
                ToolTip = 'Create location PWDEMO with stock, demo pick patterns and released warehouse shipments for testing route picking.';

                trigger OnAction()
                var
                    DemoData: Codeunit "PeritusWH Demo Data";
                    Created: Integer;
                begin
                    if not Confirm('Create demo data (location PWDEMO, items, pick patterns and released warehouse shipments)?') then
                        exit;
                    Created := DemoData.Create();
                    CurrPage.Update(false);
                    Message('Demo data created: %1 released warehouse shipments at location PWDEMO.', Created);
                end;
            }
        }
    }

    var
        Available: Integer;

    trigger OnAfterGetRecord()
    var
        Matching: Codeunit "PeritusWH Pick Matching";
    begin
        Available := Matching.CountAvailable(Rec);
    end;
}
