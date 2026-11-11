page 91124 "PeritusWH Pick Request API"
{
    PageType = API;
    APIPublisher = 'peritus';
    APIGroup = 'warehouse';
    APIVersion = 'v1.0';
    EntityName = 'pickRequest';
    EntitySetName = 'pickRequests';
    SourceTable = "PeritusWH Pick Request";
    ODataKeyFields = "Batch Id";
    DelayedInsert = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Pick Request API';

    // POST creates the pick: the app supplies batchId so it can read the lines back.
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(batchId; Rec."Batch Id") { Caption = 'Batch Id'; }
                field(patternCode; Rec."Pattern Code") { Caption = 'Pattern Code'; }
                field(operator; Rec."Operator") { Caption = 'Operator'; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Pattern: Record "PeritusWH Pick Pattern";
        Matching: Codeunit "PeritusWH Pick Matching";
    begin
        Pattern.Get(Rec."Pattern Code");
        Matching.CreatePick(Pattern, Rec."Operator", Rec."Batch Id");
        exit(true);
    end;
}
