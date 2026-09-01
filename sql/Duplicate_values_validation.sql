SELECT
    'products' AS table_name,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_count
FROM core.products

UNION ALL

SELECT
    'suppliers',
    COUNT(*) - COUNT(DISTINCT supplier_id)
FROM core.suppliers

UNION ALL

SELECT
    'orders',
    COUNT(*) - COUNT(DISTINCT order_id)
FROM core.orders

UNION ALL

SELECT
    'purchases',
    COUNT(*) - COUNT(DISTINCT po_id)
FROM core.purchases

UNION ALL

SELECT
    'shipments',
    COUNT(*) - COUNT(DISTINCT shipment_id)
FROM core.shipments

UNION ALL

SELECT
    'inventory',
    COUNT(*) - COUNT(DISTINCT product_id)
FROM core.inventory

UNION ALL

SELECT
    'supplier_kpi',
    COUNT(*) - COUNT(DISTINCT supplier_id)
FROM core.supplier_kpi;