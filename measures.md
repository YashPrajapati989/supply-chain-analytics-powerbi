# DAX Measure Documentation

> **Important:** Keep business logic as **measures** where possible. The earlier circular-dependency issue occurred because a calculated column/measure chain referenced `Reorder Priority` and `Priority Rank` in both directions. The recommended pattern is: **base measures → independent priority/risk measures → visual Top N filtering**.

## Core executive measures

### Total Revenue

```DAX
Total Revenue =
SUM('core orders'[revenue_gbp])
```

### Total Gross Profit

```DAX
Total Gross Profit =
SUM('core orders'[gross_profit_gbp])
```

### Gross Profit Margin %

```DAX
Gross Profit Margin % =
DIVIDE(
    [Total Gross Profit],
    [Total Revenue],
    0
)
```

### Total Orders

```DAX
Total Orders =
DISTINCTCOUNT('core orders'[order_id])
```

### Total Procurement Spend

```DAX
Total Procurement Spend =
SUM('core purchase orders'[po_value_gbp])
```

### Total Purchase Orders

```DAX
Total Purchase Orders =
DISTINCTCOUNT('core purchase orders'[po_id])
```

---

## Logistics measures

### Total Shipments

```DAX
Total Shipments =
DISTINCTCOUNT('core shipments'[shipment_id])
```

### On-Time Delivery %

```DAX
On-Time Delivery % =
DIVIDE(
    CALCULATE(
        COUNTROWS('core shipments'),
        'core shipments'[on_time] = TRUE()
    ),
    [Total Shipments],
    0
)
```

Format as **Percentage** with 2 decimal places.

### Average Delivery Days

Use `actual_days`, not `delivery_days`, because the shipment table contains `actual_days`.

```DAX
Average Delivery Days =
AVERAGE('core shipments'[actual_days])
```

### Late Shipments

```DAX
Late Shipments =
CALCULATE(
    COUNTROWS('core shipments'),
    'core shipments'[on_time] = FALSE()
)
```

### Late Delivery %

```DAX
Late Delivery % =
1 - [On-Time Delivery %]
```

### Average Transport Cost

```DAX
Average Transport Cost =
AVERAGE('core shipments'[transport_cost_gbp])
```

---

## Inventory measures

### Current Stock Units

```DAX
Current Stock Units =
SUM('core inventory'[current_stock_units])
```

### Inventory Value

```DAX
Inventory Value =
SUM('core inventory'[inventory_value_gbp])
```

### Products Requiring Reorder

```DAX
Products Requiring Reorder =
CALCULATE(
    DISTINCTCOUNT('core inventory'[product_id]),
    FILTER(
        'core inventory',
        'core inventory'[current_stock_units]
            < 'core inventory'[reorder_point_units]
    )
)
```

### Stock Shortfall

```DAX
Stock Shortfall =
SUMX(
    'core inventory',
    MAX(
        'core inventory'[reorder_point_units]
            - 'core inventory'[current_stock_units],
        0
    )
)
```

### Reorder Gap Units

```DAX
Reorder Gap Units =
SUMX(
    'core inventory',
    MAX(
        'core inventory'[reorder_point_units]
            - 'core inventory'[current_stock_units],
        0
    )
)
```

### Healthy Stock %

```DAX
Healthy Stock % =
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT('core inventory'[product_id]),
        'core inventory'[current_stock_units]
            >= 'core inventory'[reorder_point_units]
    ),
    DISTINCTCOUNT('core inventory'[product_id]),
    0
)
```

---

## Procurement / supplier measures

### Average Lead Time

If lead time is already stored in the purchase-order table:

```DAX
Average Lead Time =
AVERAGE('core purchase orders'[lead_time_days])
```

If lead time is derived from PO date and received date:

```DAX
Average Lead Time =
AVERAGEX(
    FILTER(
        'core purchase orders',
        NOT ISBLANK('core purchase orders'[received_date])
    ),
    DATEDIFF(
        'core purchase orders'[po_date],
        'core purchase orders'[received_date],
        DAY
    )
)
```

### Supplier On-Time Delivery %

If supplier and shipment relationships are correctly configured, the existing `[On-Time Delivery %]` measure can be placed against `supplier_name`.

Do **not** create a separate calculated column for supplier OTD.

---

## Management-action logic

A robust approach is to keep action logic independent from ranking logic.

### Supplier Risk Action

Example threshold logic:

```DAX
Supplier Risk Action =
VAR OTD = [On-Time Delivery %]
RETURN
SWITCH(
    TRUE(),
    OTD < 0.55, "Immediate Review",
    OTD < 0.60, "Monitor",
    "Stable"
)
```

Adjust the thresholds if the business target changes.

### Supplier Risk Rank

Use a measure that ranks suppliers by the risk metric:

```DAX
Supplier Risk Rank =
RANKX(
    ALLSELECTED('core product_supplier'[supplier_name]),
    [On-Time Delivery %],
    ,
    ASC,
    DENSE
)
```

This is intentionally separate from the action label.

---

## Top-5 management table

Do **not** create a `Priority Rank` calculated column that depends on `Reorder Priority` if `Reorder Priority` also depends on the rank. That creates a circular dependency.

Instead:

1. Put `supplier_name` / `product_name` into the table.
2. Add the required measures.
3. Use the visual-level **Top N** filter.
4. Select **Top 5** by the relevant risk measure.

For supplier management:

- Filter: `supplier_name`
- Filter type: **Top N**
- Show items: **Top 5**
- By value: `[Supplier Risk Rank]` is not ideal; use a numeric risk measure such as `[Late Shipments]` or a dedicated risk score.

For replenishment:

- Filter: `product_name`
- Filter type: **Top N**
- Show items: **Top 5**
- By value: `[Reorder Gap Units]`

This avoids circular dependencies and keeps the ranking responsive to slicers.

---

## Formatting recommendations

| Measure | Format |
|---|---|
| Revenue / Procurement / Inventory Value | GBP currency, 0–2 decimals |
| Gross Profit Margin % | 2 decimals % |
| On-Time Delivery % | 2 decimals % |
| Average Lead Time | 2 decimals |
| Average Delivery Days | 2 decimals |
| Current Stock Units | Whole number |
| Reorder Gap Units | Whole number |
| Products Requiring Reorder | Whole number |
| Risk / Priority score | Whole number |

## Model design principle

Prefer:

```text
Raw column
   ↓
Base measure
   ↓
Business measure
   ↓
Visual filter / ranking
```

Avoid:

```text
Calculated Column A
   ↓
Calculated Column B
   ↓
Calculated Column A
```

The second pattern is what produces circular-dependency errors.
