-- Orders → Products
SELECT 'orders → products' AS relationship,
       COUNT(*) AS orphan_records
FROM core.orders o
LEFT JOIN core.products p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

-- Inventory → Products
SELECT 'inventory → products',
       COUNT(*)
FROM core.inventory i
LEFT JOIN core.products p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

-- Purchases → Products
SELECT 'purchases → products',
       COUNT(*)
FROM core.purchases pu
LEFT JOIN core.products p
    ON pu.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

-- Purchases → Suppliers
SELECT 'purchases → suppliers',
       COUNT(*)
FROM core.purchases pu
LEFT JOIN core.suppliers s
    ON pu.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL

UNION ALL

-- Shipments → Products
SELECT 'shipments → products',
       COUNT(*)
FROM core.shipments sh
LEFT JOIN core.products p
    ON sh.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

-- Product Supplier → Products
SELECT 'product_supplier → products',
       COUNT(*)
FROM core.product_supplier ps
LEFT JOIN core.products p
    ON ps.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

-- Product Supplier → Suppliers
SELECT 'product_supplier → suppliers',
       COUNT(*)
FROM core.product_supplier ps
LEFT JOIN core.suppliers s
    ON ps.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;