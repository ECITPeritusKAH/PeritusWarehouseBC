codeunit 91128 "PeritusWH User Manual"
{
    trigger OnRun()
    begin
        Download();
    end;

    procedure Download()
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        FileName: Text;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(BuildHtml());
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        FileName := 'Peritus Warehouse User Manual.html';
        File.DownloadFromStream(InStream, '', '', 'HTML file (*.html)|*.html', FileName);
    end;

    procedure BuildHtml() ManualHtml: Text
    var
        Html: TextBuilder;
        Part01Lbl: Label '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Peritus Warehouse - User Manual</title>', Locked = true;
        Part02Lbl: Label '<style>body{font-family:Segoe UI,Arial,sans-serif;color:#1f2933;line-height:1.5;margin:0;background:#f3f6f8}main{max-width:900px;margin:0 auto;background:#fff;padding:40px 56px}h1{font-size:30px;color:#034b70;margin:0 0 8px}h2{color:#034b70;border-bottom:2px solid #46a5c9;padding-bottom:6px;margin-top:36px}.lead{font-size:17px;color:#52616b}.note{background:#eaf7fb;border-left:4px solid #46a5c9;padding:12px 16px}table{border-collapse:collapse;width:100%}td,th{border:1px solid #d5dde1;padding:6px 10px;text-align:left}th{background:#eaf1f4}ol,ul{padding-left:24px}footer{margin-top:44px;color:#65747c;font-size:12px}</style></head><body><main>', Locked = true;
        Part03Lbl: Label '<h1>Peritus Warehouse</h1><p class="lead">User manual for the warehouse worker menu and the handheld warehouse app.</p>';
        Part04Lbl: Label '<p class="note"><strong>Getting help:</strong> Open <strong>Warehouse Solution &gt; User Manual</strong> in the Warehouse Worker Role Center to view this guide at any time.</p>';
        Part05Lbl: Label '<h2>Purpose</h2><p>Peritus Warehouse adds a handheld web app for put-away, pick, transfer, receiving, inventory count and item lookup. Everything registered in the app is saved in Business Central. This extension adds pick patterns and the Warehouse Solution menu.</p>';
        Part06Lbl: Label '<h2>Warehouse Solution menu</h2><table><tr><th>Group</th><th>Page</th><th>Use it to</th></tr><tr><td>Periodic</td><td>Warehouse Shipments</td><td>View and process warehouse shipments</td></tr><tr><td>Periodic</td><td>Warehouse Physical Inventory Journals</td><td>Open warehouse physical inventory batches</td></tr><tr><td>Periodic</td><td>Warehouse Item Journals</td><td>Open warehouse item journal batches</td></tr><tr><td>Periodic</td><td>Pick Worksheets</td><td>Plan and initialize warehouse picks</td></tr><tr><td>Periodic</td><td>Put-away Worksheets</td><td>Plan and initialize item put-aways</td></tr>';
        Part07Lbl: Label '<tr><td>Data</td><td>Items</td><td>View and edit items</td></tr><tr><td>Data</td><td>Bin Contents</td><td>See items stored in bins</td></tr><tr><td>Data</td><td>Vendors</td><td>View and edit vendors</td></tr><tr><td>Data</td><td>Shipping Agents</td><td>View and edit shipping agents</td></tr><tr><td>Setup</td><td>Pick Patterns</td><td>Define rules that group shipments into picks</td></tr><tr><td>Setup</td><td>Locations</td><td>View and edit locations</td></tr><tr><td>Setup</td><td>Warehouse Setup</td><td>Configure warehouse management</td></tr><tr><td>User Manual</td><td>User Manual</td><td>Open this guide</td></tr></table>';
        Part08Lbl: Label '<h2>Pick patterns</h2><p>Open <strong>Warehouse Solution &gt; Setup &gt; Pick Patterns</strong>. A pattern is a set of rules that groups warehouse shipments into one pick batch. Each pattern has a priority, the number of shipments per batch (Order Count) and a container type.</p><h3>When is a shipment assigned to a pattern?</h3><p>Not when it is released. A shipment is never stored with a pattern in advance. Matching is calculated live whenever the Pick page opens, and the numbers shown per pattern are the released shipments that currently match it. The shipment is claimed only when a worker creates a pick batch.</p><h3>What does a pattern match on?</h3><ul><li>Released warehouse shipments at the pattern location that are not already claimed.</li><li>Shipment method: include or exclude lists.</li><li>Zone: at least one line in the zone.</li><li>Longest item: min and max length, from the item unit of measure.</li><li>Total weight and total volume of the shipment.</li></ul><p>A value of 0 means no limit. Shipments that already have a pick, for example made in Business Central, are not offered.</p><h3>When several patterns match</h3><p>The pattern with the lowest priority number wins. If the priority is the same, the lowest code wins. A shipment therefore appears under only one pattern.</p><h3>Creating a batch</h3><ol><li>The worker chooses a pattern on the Pick page.</li><li>The app takes up to Order Count matching shipments, oldest shipment date first.</li><li>The shipments are claimed with a batch id, the pattern code, the user and the time. No other worker can get them.</li><li>The standard warehouse picks are created in Business Central, and the worker picks the batch in the app.</li></ol><h3>Releasing a batch</h3><p>Releasing a batch removes the claim, so the shipments can match a pattern again. It does not delete the warehouse picks that were created. In the app: open Pick, enter your name, choose <strong>Show my batches</strong> and then <strong>Release batch</strong>. In Business Central: open <strong>Warehouse Shipments</strong>, where the pattern, picked by and claimed at columns show the claim, and choose <strong>Release Pick Batch Claim</strong>.</p><p class="note">If a shipment is changed after release, for example a new shipment method or a changed line, it simply matches a different pattern the next time. Once a pick exists, it no longer matches any pattern.</p>';
        Part09Lbl: Label '<h2>Demo data</h2><p>On the Pick Patterns page, choose <strong>Create Demo Data</strong>. It creates location PWDEMO with bins, four test items with stock, five patterns and 18 released warehouse shipments. Running it again adds 18 more shipments.</p>';
        Part10Lbl: Label '<h2>Handheld app</h2><table><tr><th>Page</th><th>Use it to</th></tr><tr><td>Receive purchase</td><td>Receive goods against a purchase order</td></tr><tr><td>Put-away</td><td>Select an activity, enter quantity handled on each line, choose Register</td></tr><tr><td>Pick</td><td>Choose a pattern to create a pick batch, enter quantities, choose Register</td></tr><tr><td>Transfer</td><td>Ship or receive released transfer orders</td></tr><tr><td>Inventory count</td><td>Enter counted quantities. Posting the journal is done in Business Central</td></tr><tr><td>Item lookup</td><td>Find an item by number, barcode or name</td></tr></table>';
        Part11Lbl: Label '<h2>Users and permissions</h2><ul><li>Everyone who creates or registers picks must be a warehouse employee at the location.</li><li>The service user used by the web app needs a Business Central permission set, and a warehouse employee entry at PWDEMO when the demo data is used.</li></ul>';
        Part12Lbl: Label '<h2>Troubleshooting</h2><ul><li>No shipments under a pattern: check that the shipments are released, not already picked or claimed, and fit the pattern filters.</li><li>Pick creation fails: check the warehouse employee setup for the location.</li><li>The app shows an error right after an update: wait about a minute and reload.</li></ul>';
        Part13Lbl: Label '<footer>Peritus Warehouse - User Manual | Generated from the installed extension</footer></main></body></html>', Locked = true;
    begin
        Html.AppendLine(Part01Lbl);
        Html.AppendLine(Part02Lbl);
        Html.AppendLine(Part03Lbl);
        Html.AppendLine(Part04Lbl);
        Html.AppendLine(Part05Lbl);
        Html.AppendLine(Part06Lbl);
        Html.AppendLine(Part07Lbl);
        Html.AppendLine(Part08Lbl);
        Html.AppendLine(Part09Lbl);
        Html.AppendLine(Part10Lbl);
        Html.AppendLine(Part11Lbl);
        Html.AppendLine(Part12Lbl);
        Html.AppendLine(Part13Lbl);
        ManualHtml := Html.ToText();
    end;
}
