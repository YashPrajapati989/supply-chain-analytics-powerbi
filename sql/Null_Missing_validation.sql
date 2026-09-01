SELECT
    'products' AS table_name,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
    COUNT(*) FILTER (WHERE product_name IS NULL) AS product_name_nulls,
    COUNT(*) FILTER (WHERE unit_cost_gbp IS NULL) AS unit_cost_nulls,
    COUNT(*) FILTER (WHERE selling_price_gbp IS NULL) AS selling_price_nulls
FROM core.products

UNION ALL

SELECT
    'suppliers',
    COUNT(*) FILTER (WHERE supplier_id IS NULL),
    COUNT(*) FILTER (WHERE supplier_name IS NULL),
    0,
    0
FROM core.suppliers

UNION ALL

SELECT
    'inventory',
    COUNT(*) FILTER (WHERE product_id IS NULL),
    COUNT(*) FILTER (WHERE current_stock_units IS NULL),
    COUNT(*) FILTER (WHERE reorder_point_units IS NULL),
    COUNT(*) FILTER (WHERE inventory_value_gbp IS NULL)
FROM core.inventory

UNION ALL

SELECT
    'orders',
    COUNT(*) FILTER (WHERE order_id IS NULL),
    COUNT(*) FILTER (WHERE order_date IS NULL),
    COUNT(*) FILTER (WHERE product_id IS NULL),
    COUNT(*) FILTER (WHERE quantity IS NULL)
FROM core.orders

UNION ALL

SELECT
    'purchases',
    COUNT(*) FILTER (WHERE po_id IS NULL),
    COUNT(*) FILTER (WHERE po_date IS NULL),
    COUNT(*) FILTER (WHERE product_id IS NULL),
    COUNT(*) FILTER (WHERE supplier_id IS NULL)
FROM core.purchases

UNION ALL

SELECT
    'shipments',
    COUNT(*) FILTER (WHERE shipment_id IS NULL),
    COUNT(*) FILTER (WHERE shipment_date IS NULL),
    COUNT(*) FILTER (WHERE product_id IS NULL),
    COUNT(*) FILTER (WHERE quantity IS NULL)
FROM core.shipments;