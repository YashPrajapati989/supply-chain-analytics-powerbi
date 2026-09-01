SELECT 'products' AS table_name, COUNT(*) AS row_count
FROM core.products

UNION ALL

SELECT 'suppliers', COUNT(*)
FROM core.suppliers

UNION ALL

SELECT 'product_supplier', COUNT(*)
FROM core.product_supplier

UNION ALL

SELECT 'orders', COUNT(*)
FROM core.orders

UNION ALL

SELECT 'inventory', COUNT(*)
FROM core.inventory

UNION ALL

SELECT 'purchases', COUNT(*)
FROM core.purchases

UNION ALL

SELECT 'shipments', COUNT(*)
FROM core.shipments

UNION ALL

SELECT 'supplier_kpi', COUNT(*)
FROM core.supplier_kpi

ORDER BY table_name;