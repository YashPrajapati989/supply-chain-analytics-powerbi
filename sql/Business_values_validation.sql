-- Products
SELECT 'products' AS table_name, COUNT(*) AS invalid_records
FROM core.products
WHERE unit_cost_gbp <= 0
   OR selling_price_gbp <= 0
   OR selling_price_gbp < unit_cost_gbp

UNION ALL

-- Orders
SELECT 'orders', COUNT(*)
FROM core.orders
WHERE quantity <= 0
   OR revenue_gbp < 0
   OR cogs_gbp < 0

UNION ALL

-- Inventory
SELECT 'inventory', COUNT(*)
FROM core.inventory
WHERE average_daily_demand < 0
   OR lead_time_days < 0
   OR safety_stock_units < 0
   OR current_stock_units < 0
   OR reorder_point_units < 0
   OR inventory_value_gbp < 0

UNION ALL

-- Purchases
SELECT 'purchases', COUNT(*)
FROM core.purchases
WHERE quantity <= 0
   OR unit_cost_gbp <= 0
   OR po_value_gbp < 0

UNION ALL

-- Shipments
SELECT 'shipments', COUNT(*)
FROM core.shipments
WHERE quantity <= 0
   OR promised_days < 0
   OR actual_days < 0
   OR transport_cost_gbp < 0;