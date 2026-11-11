page 91127 "PeritusWH Documentation"
{
    Caption = 'User Manual';
    PageType = Card;
    ApplicationArea = Warehouse;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            usercontrol(DocumentationViewer; WebPageViewer)
            {
                ApplicationArea = Warehouse;

                trigger ControlAddInReady(CallbackUrl: Text)
                var
                    UserManual: Codeunit "PeritusWH User Manual";
                begin
                    CurrPage.DocumentationViewer.SetContent(UserManual.BuildHtml());
                end;

                trigger DocumentReady()
                begin
                end;

                trigger Callback(Data: Text)
                begin
                end;

                trigger Refresh(CallbackUrl: Text)
                var
                    UserManual: Codeunit "PeritusWH User Manual";
                begin
                    CurrPage.DocumentationViewer.SetContent(UserManual.BuildHtml());
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PeritusWHDownloadManual)
            {
                ApplicationArea = Warehouse;
                Caption = 'Download';
                Image = Download;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Download the user manual as an HTML file.';

                trigger OnAction()
                var
                    UserManual: Codeunit "PeritusWH User Manual";
                begin
                    UserManual.Download();
                end;
            }
        }
    }
}
