# Peritus Warehouse - User Manual

Peritus Warehouse is a web app for warehouse workers that can be used on a handheld or a PC browser. It works on top of Business Central (BC): everything you do is saved in BC.

Open the app in a browser on your handheld or PC: https://peritus-warehouse.azurewebsites.net

## Pages

| Page | Address | Use it to |
|---|---|---|
| Home | `/` | Choose a task |
| Receive purchase | `/receive/purchase` | Receive goods against a purchase order |
| Put-away | `/putaway` | Put received goods on their bins |
| Pick | `/pick` | Pick goods for warehouse shipments |
| Transfer | `/transfer` | Ship and receive transfer orders |
| Inventory count | `/count` | Record counted quantities |
| Item lookup | `/items` | Find an item by number, barcode or name |

## Put-away

1. Open **Put-away** and select an activity.
2. For each Take/Place line, enter the quantity handled.
3. Choose **Register**.

## Pick

1. Open **Pick**. The list shows the pick patterns with the number of shipments available for each.
2. Choose a pattern. The app claims the matching shipments and creates the warehouse picks in BC.
3. Choose to handle one pick list at a time, or combine the pick lists into one list sorted by Bin.
4. Create or select a license plate, enter a Take quantity, and confirm it. The selected license plate is saved in BC for that pick list and restored when you return to it. More license plates can be created whenever needed.
5. Choose **Place** to review all confirmed Take quantities, enter Place quantities, and confirm them. Register is available here when the saved Place quantities equal the Take quantities for every picked line in that pick list.
6. Register each pick list separately from Place. Registration posts the saved Take/Place quantities for that pick list.

Which shipments belong to which pattern is set up in BC (see below).

### Track license plates on a PC

Use the Peritus Warehouse web app in your PC browser; the license-plate workflow is the same as on a handheld.

1. Open **Pick**, choose a pattern, then choose whether to work one pick list at a time or combine the batch.
2. Before confirming a Take quantity, select an existing license plate or choose **New license plate**. New numbers come from the number series configured on the pick pattern.
3. Enter the quantity and choose **Confirm Take**. The pick list remembers the selected plate when you return to it.
4. Choose **Place** to review each picked item, its license plate, and its Take, Place, and Posted quantities. Enter the Place quantity and choose **Confirm Place**.
5. Register the pick list from the Place screen. In combined mode, each pick list is registered separately.

Plate assignments and quantities are saved in BC. Use the tracking actions described below to review them in BC.

### How pick patterns work

- **Not at release.** A shipment is not given a pattern when it is released. Matching is live: the numbers on the Pick page are the released, unclaimed shipments that match each pattern right now.
- **Matching rules.** Shipment method (include/exclude), zone, longest item, total weight and total volume. 0 means no limit. Shipments that already have a pick are not offered.
- **One pattern per shipment.** If several match, the lowest priority number wins, then the lowest code.
- **Batch.** When you choose a pattern, the app takes up to *Order Count* matching shipments (oldest shipment date first), claims them for you and creates the standard warehouse picks in BC.
- **License plates.** Set **License Plate Nos.** on each pick pattern to a configured BC number series. The app assigns a number only when the operator creates a plate. Take and Place quantities are saved in BC against that batch and plate; only confirmed Place quantities can be registered.
- **Release batch.** Removes the claim so the shipments can match a pattern again. It does not delete the picks. In the app: Pick > enter your name > *Show my batches* > *Release batch*. In BC: *Warehouse Shipments* > *Release Pick Batch Claim* (the pattern, picked by and claimed at columns show claimed shipments).
- If a shipment changes after release, it matches a different pattern next time. Once a pick exists, it matches none.

## Transfer

1. Open **Transfer** and select a released transfer order.
2. Toggle **Ship** or **Receive**, set the quantities, and post.

## Inventory count

1. Open **Inventory count** and select a count journal. Only journals released to mobile are listed.
2. Enter the counted quantity on each line.
3. Posting the journal is done in BC, not in the app.

## Item lookup

Type or scan an item number, barcode (GTIN) or name.

## Setup in Business Central (administrators)

- **Pick Patterns:** In BC, search for *Pick Patterns*. A shipment matches a pattern on location, shipment method (include/exclude), zone, longest line, total weight and total volume. A value of 0 means no limit. If several patterns match, the lowest priority number wins.
- **Demo data:** On the Pick Patterns page, choose **Create Demo Data**. It creates location `PWDEMO`, four test items with stock, five patterns and 18 released shipments for testing. Running it again adds 18 more shipments.
- **Users:** Anyone who creates picks must be a warehouse employee at the location. The app's service user also needs a BC permission set, and a warehouse employee entry at `PWDEMO` if you use the demo data.

## License-plate tracking in Business Central

- **From an item:** Open the item card and choose **Process > License Plate Tracking** to see pick tracking rows for that item.
- **From a pick list:** Open **Warehouse Picks**, select a pick, and choose **Process > License Plate Tracking** to see its tracking rows.
- The list shows the license plate, item, pick number, batch, bin, and Take, Place, and Posted quantities. It is read-only; tracking is recorded by the Peritus Warehouse app.

## Troubleshooting

- **Page shows an error or 500 right after an update:** wait about a minute and reload.
- **No shipments under a pattern:** check that the shipments are released, are not already picked or claimed, and fit the pattern's filters.
- **Pick creation fails:** check that the service user is a warehouse employee at the shipment's location.
