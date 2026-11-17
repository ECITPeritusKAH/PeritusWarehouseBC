pageextension 91100 "PeritusWH Warehouse Worker RC" extends "Whse. Worker WMS Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(PeritusWHWarehouseSolution)
            {
                Caption = 'Warehouse Solution';

                group(PeritusWHPeriodic)
                {
                    Caption = 'Periodic';

                    action(PeritusWHPhysicalInventoryJournals)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Warehouse Physical Inventory Journals';
                        RunObject = Page "Whse. Journal Batches List";
                        RunPageView = where("Template Type" = const("Physical Inventory"));
                        ToolTip = 'Open warehouse physical inventory journal batches.';
                    }
                    action(PeritusWHWarehouseItemJournals)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Warehouse Item Journals';
                        RunObject = Page "Whse. Journal Batches List";
                        RunPageView = where("Template Type" = const(Item));
                        ToolTip = 'Open warehouse item journal batches.';
                    }
                    action(PeritusWHWarehouseShipments)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Warehouse Shipments';
                        RunObject = Page "Warehouse Shipment List";
                        ToolTip = 'View and process warehouse shipments.';
                    }
                    action(PeritusWHWarehousePicks)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Warehouse Picks';
                        RunObject = Page "Warehouse Picks";
                        ToolTip = 'View and process warehouse picks.';
                    }
                    action(PeritusWHPickWorksheets)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Pick Worksheets';
                        RunObject = Page "Pick Worksheet";
                        ToolTip = 'Plan and initialize warehouse picks.';
                    }
                    action(PeritusWHPutAwayWorksheets)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Put-away Worksheets';
                        RunObject = Page "Put-away Worksheet";
                        ToolTip = 'Plan and initialize item put-aways.';
                    }
                }
                group(PeritusWHData)
                {
                    Caption = 'Data';

                    action(PeritusWHItems)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Items';
                        RunObject = Page "Item List";
                        ToolTip = 'View and edit item records.';
                    }
                    action(PeritusWHLicensePlateTracking)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'License Plate Tracking';
                        RunObject = Page "PeritusWH LP Tracking";
                        ToolTip = 'View pick license-plate tracking lines.';
                    }
                    action(PeritusWHBinContents)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Bin Contents';
                        RunObject = Page "Bin Contents List";
                        ToolTip = 'View items stored in warehouse bins.';
                    }
                    action(PeritusWHVendors)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Vendors';
                        RunObject = Page "Vendor List";
                        ToolTip = 'View and edit vendor records.';
                    }
                    action(PeritusWHShippingAgents)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Shipping Agents';
                        RunObject = Page "Shipping Agents";
                        ToolTip = 'View and edit shipping agent records.';
                    }
                }
                group(PeritusWHSetup)
                {
                    Caption = 'Setup';

                    action(PeritusWHPickPatterns)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Pick Patterns';
                        RunObject = Page "PeritusWH Pick Patterns";
                        ToolTip = 'Configure rules for matching warehouse shipments to pick patterns.';
                    }
                    action(PeritusWHLicensePlateEdit)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'License Plate Edit';
                        RunObject = Page "PeritusWH License Plate Edit";
                        ToolTip = 'View and edit license-plate records.';
                    }
                    action(PeritusWHLicensePlateLineEdit)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'License Plate Line Edit';
                        RunObject = Page "PeritusWH LP Line Edit";
                        ToolTip = 'View and edit pick license-plate lines.';
                    }
                }
                group(PeritusWHUserManual)
                {
                    Caption = 'User Manual';

                    action(PeritusWHUserManualPage)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'User Manual';
                        RunObject = Page "PeritusWH Documentation";
                        ToolTip = 'Open the Peritus Warehouse user manual.';
                    }
                }
            }
        }
    }
}
