permissionset 91120 "PeritusWH Warehouse"
{
    Assignable = true;
    Caption = 'Peritus Warehouse';

    Permissions =
        tabledata "PeritusWH Pick Pattern" = RIMD,
        tabledata "PeritusWH Pick Request" = RIMD,
        tabledata "PeritusWH Pick Shipping Method" = RIMD,
        table "PeritusWH Pick Pattern" = X,
        table "PeritusWH Pick Request" = X,
        table "PeritusWH Pick Shipping Method" = X,
        codeunit "PeritusWH Whse. Register" = X,
        codeunit "PeritusWH User Manual" = X,
        codeunit "PeritusWH Pick Matching" = X,
        codeunit "PeritusWH Demo Data" = X,
        codeunit "PeritusWH Create Pick Doc" = X,
        page "PeritusWH Pick Shipping Method" = X,
        page "PeritusWH Pick Request API" = X,
        page "PeritusWH Transfer Line API" = X,
        page "PeritusWH Purchase Line API" = X,
        page "PeritusWH Put-away API" = X,
        page "PeritusWH Inv. Count Batch API" = X,
        page "PeritusWH Pick Pattern Card" = X,
        page "PeritusWH Whse. Act. Line API" = X,
        page "PeritusWH Purchase Order API" = X,
        page "PeritusWH Pick Pattern API" = X,
        page "PeritusWH Documentation" = X,
        page "PeritusWH Phys. Inv. Line API" = X,
        page "PeritusWH Pick Batch API" = X,
        page "PeritusWH Whse. Employee API" = X,
        page "PeritusWH Transfer Order API" = X,
        page "PeritusWH Pick API" = X,
        page "PeritusWH Pick Line API" = X,
        page "PeritusWH Pick Patterns" = X;
}
