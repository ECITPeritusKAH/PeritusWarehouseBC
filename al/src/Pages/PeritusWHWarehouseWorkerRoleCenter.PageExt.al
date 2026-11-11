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
                    action(PeritusWHLocations)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Locations';
                        RunObject = Page "Location List";
                        ToolTip = 'View and edit warehouse locations.';
                    }
                    action(PeritusWHWarehouseSetup)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Warehouse Setup';
                        RunObject = Page "Warehouse Setup";
                        ToolTip = 'Configure warehouse management settings.';
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
