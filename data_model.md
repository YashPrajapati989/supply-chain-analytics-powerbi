# Data Model

## Core entities

The report is organised around five analytical areas:

```text
                    ┌────────────────────┐
                    │   core products    │
                    │ product_id         │
                    │ product_name       │
                    │ category           │
                    └─────────┬──────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
      ┌────────────────┐ ┌──────────────┐ ┌─────────────────┐
      │ core inventory  │ │ core shipments│ │ product_supplier│
      │ stock / reorder │ │ delivery     │ │ supplier master │
      └────────────────┘ └──────────────┘ └────────┬────────┘
                                                     │
                                                     ▼
                                           ┌──────────────────┐
                                           │ purchase orders  │
                                           │ procurement      │
                                           └──────────────────┘
```

## Main analytical grain

- **Inventory:** product-level stock position
- **Purchase orders:** purchase-order line / PO-level procurement activity
- **Shipments:** shipment-level delivery event
- **Product-supplier:** product/supplier relationship
- **Products:** product/category dimension

## Key fields

### Purchase orders

`po_id`, `po_date`, `product_id`, `supplier_id`, `quantity`, `unit_cost_gbp`, `po_value_gbp`, `received_date`, `status`

### Shipments

`shipment_id`, `shipment_date`, `product_id`, `quantity`, `warehouse`, `carrier`, `promised_days`, `actual_days`, `on_time`, `transport_cost_gbp`, `month`

### Inventory

The inventory table contains stock position, reorder point, safety-stock and value fields used to calculate replenishment gaps and inventory risk.

## Relationship principle

Use stable IDs for relationships:

```text
products.product_id
      ↕
inventory.product_id

products.product_id
      ↕
shipments.product_id

products.product_id
      ↕
product_supplier.product_id
```

Supplier analysis should use the supplier dimension / product-supplier bridge rather than duplicating supplier attributes across fact tables.

## Important modelling rule

Keep measures separate from calculated columns when possible. Dynamic rankings and Top-N management tables should be driven by measures and visual-level filters so that Year / Month / Category slicers continue to work correctly.
