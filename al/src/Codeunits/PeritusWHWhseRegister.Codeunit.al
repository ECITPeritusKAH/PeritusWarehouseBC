codeunit 91108 "PeritusWH Whse. Register"
{
    procedure RegisterActivity(HeaderSystemId: Guid)
    var
        WhseActivityHeader: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActRegister: Codeunit "Whse.-Activity-Register";
    begin
        WhseActivityHeader.GetBySystemId(HeaderSystemId);
        WhseActivityLine.SetRange("Activity Type", WhseActivityHeader.Type);
        WhseActivityLine.SetRange("No.", WhseActivityHeader."No.");
        WhseActivityLine.FindFirst();
        WhseActRegister.Run(WhseActivityLine);
    end;
}
