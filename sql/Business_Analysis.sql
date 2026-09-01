--SQL Analysis 1 — Product Profitability

SELECT
    product_id,
    product_name,
    category,
    unit_cost_gbp,
    selling_price_gbp,
    selling_price_gbp - unit_cost_gbp AS gross_profit_per_unit_gbp,
    ROUND(
        ((selling_price_gbp - unit_cost_gbp) / selling_price_gbp) * 100,
        2
    ) AS gross_margin_pct
FROM core.products
ORDER BY gross_profit_per_unit_gbp DESC;



--SQL Analysis 2 — Demand & Sales Performance

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(o.quantity) AS total_units_sold,
    SUM(o.revenue_gbp) AS total_revenue_gbp,
    SUM(o.gross_profit_gbp) AS total_gross_profit_gbp
FROM core.orders o
JOIN core.products p
    ON o.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_units_sold DESC;


-- SQL Analysis 3 — Highest Gross Profit Products
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(o.quantity) AS total_units_sold,
    SUM(o.revenue_gbp) AS total_revenue_gbp,
    SUM(o.gross_profit_gbp) AS total_gross_profit_gbp
FROM core.orders o
JOIN core.products p
    ON o.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_gross_profit_gbp DESC
LIMIT 5;


-- SQL Analysis 4 — Inventory Replenishment
SELECT
    i.product_id,
    p.product_name,
    p.category,
    i.current_stock_units,
    i.reorder_point_units,
    i.reorder_point_units - i.current_stock_units AS inventory_gap_units,
    i.safety_stock_units,
    i.inventory_value_gbp,
    i.stock_status
FROM core.inventory i
JOIN core.products p
    ON i.product_id = p.product_id
WHERE i.current_stock_units < i.reorder_point_units
ORDER BY inventory_gap_units DESC;


-- SQL Analysis 5 — Inventory Risk + Potential Gross Profit Exposure
SELECT
    i.product_id,
    p.product_name,
    i.current_stock_units,
    i.reorder_point_units,
    
    i.reorder_point_units - i.current_stock_units 
        AS inventory_gap_units,
    
    p.selling_price_gbp - p.unit_cost_gbp 
        AS gross_profit_per_unit_gbp,
    
    (i.reorder_point_units - i.current_stock_units)
    *
    (p.selling_price_gbp - p.unit_cost_gbp)
        AS potential_gp_exposure_gbp

FROM core.inventory i
JOIN core.products p
    ON i.product_id = p.product_id

WHERE i.current_stock_units < i.reorder_point_units

ORDER BY potential_gp_exposure_gbp DESC;


-- SQL Analysis 6 — Create a Procurement Priority Score
SELECT
    i.product_id,
    p.product_name,
    i.current_stock_units,
    i.reorder_point_units,
    i.reorder_point_units - i.current_stock_units AS inventory_gap_units,
    ps.supplier_id,
    s.supplier_name,
    ps.lead_time_days
FROM core.inventory i
JOIN core.products p
    ON i.product_id = p.product_id
JOIN core.product_supplier ps
    ON i.product_id = ps.product_id
JOIN core.suppliers s
    ON ps.supplier_id = s.supplier_id
WHERE i.current_stock_units < i.reorder_point_units
ORDER BY inventory_gap_units DESC;


-- SQL Analysis 6B — Procurement Priority Score
WITH priority_data AS (

    SELECT
        i.product_id,
        p.product_name,
        i.current_stock_units,
        i.reorder_point_units,
        i.reorder_point_units - i.current_stock_units AS inventory_gap,
        ps.supplier_id,
        s.supplier_name,
        ps.lead_time_days,

        (p.selling_price_gbp - p.unit_cost_gbp)
            AS gross_profit_per_unit,

        (i.reorder_point_units - i.current_stock_units)
        * (p.selling_price_gbp - p.unit_cost_gbp)
            AS potential_gp_exposure

    FROM core.inventory i

    JOIN core.products p
        ON i.product_id = p.product_id

    JOIN core.product_supplier ps
        ON i.product_id = ps.product_id

    JOIN core.suppliers s
        ON ps.supplier_id = s.supplier_id

    WHERE i.current_stock_units < i.reorder_point_units
),

risk_scores AS (

    SELECT
        *,

        ROUND(
            100.0 * inventory_gap
            / MAX(inventory_gap) OVER (),
            2
        ) AS gap_risk_score,

        ROUND(
            100.0 * lead_time_days
            / MAX(lead_time_days) OVER (),
            2
        ) AS lead_time_risk_score,

        ROUND(
            100.0 * potential_gp_exposure
            / MAX(potential_gp_exposure) OVER (),
            2
        ) AS financial_risk_score

    FROM priority_data
)

SELECT
    product_id,
    product_name,
    inventory_gap,
    supplier_id,
    supplier_name,
    lead_time_days,
    potential_gp_exposure,

    gap_risk_score,
    lead_time_risk_score,
    financial_risk_score,

    ROUND(
        (
            gap_risk_score * 0.50
            + lead_time_risk_score * 0.20
            + financial_risk_score * 0.30
        ),
        2
    ) AS procurement_priority_score,

    CASE
        WHEN (
            gap_risk_score * 0.50
            + lead_time_risk_score * 0.20
            + financial_risk_score * 0.30
        ) >= 70
            THEN 'High'

        WHEN (
            gap_risk_score * 0.50
            + lead_time_risk_score * 0.20
            + financial_risk_score * 0.30
        ) >= 40
            THEN 'Medium'

        ELSE 'Low'
    END AS procurement_priority

FROM risk_scores

ORDER BY procurement_priority_score DESC;



-- SQL Analysis 7 — Procurement Spend & Supplier Dependency
WITH supplier_spend AS (
    SELECT
        supplier_id,
        COUNT(DISTINCT po_id) AS total_purchase_orders,
        SUM(po_value_gbp) AS total_procurement_spend
    FROM core.purchases
    GROUP BY supplier_id
),

total_spend AS (
    SELECT SUM(total_procurement_spend) AS company_total_spend
    FROM supplier_spend
)

SELECT
    ss.supplier_id,
    s.supplier_name,
    ss.total_purchase_orders,
    ROUND(ss.total_procurement_spend, 2) AS total_procurement_spend_gbp,

    ROUND(
        100.0 * ss.total_procurement_spend
        / ts.company_total_spend,
        2
    ) AS spend_percentage,

    CASE
        WHEN 100.0 * ss.total_procurement_spend
             / ts.company_total_spend >= 25
            THEN 'High Dependency Risk'

        WHEN 100.0 * ss.total_procurement_spend
             / ts.company_total_spend >= 15
            THEN 'Moderate Dependency Risk'

        ELSE 'Low Dependency Risk'
    END AS supplier_dependency_risk

FROM supplier_spend ss
JOIN core.suppliers s
    ON ss.supplier_id = s.supplier_id
CROSS JOIN total_spend ts
ORDER BY total_procurement_spend_gbp DESC;


-- SQL Analysis 8 — Supplier Performance
SELECT
    s.supplier_id,
    s.supplier_name,

    COUNT(DISTINCT p.po_id) AS total_purchase_orders,

    ROUND(SUM(p.po_value_gbp), 2) AS total_procurement_spend_gbp,

    ROUND(
        AVG(
            CASE
                WHEN p.received_date IS NOT NULL
                THEN p.received_date - p.po_date
            END
        ),
        2
    ) AS average_procurement_lead_time_days

FROM core.suppliers s

LEFT JOIN core.purchases p
    ON s.supplier_id = p.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    average_procurement_lead_time_days DESC;



-- SQL Analysis 9 — Supplier Delivery Performance
SELECT
    s.supplier_id,
    s.supplier_name,

    COUNT(sh.shipment_id) AS total_shipments,

    ROUND(
        100.0 * AVG(
            CASE
                WHEN sh.on_time = TRUE THEN 1
                ELSE 0
            END
        ),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        AVG(sh.actual_days - sh.promised_days),
        2
    ) AS average_delivery_delay_days,

    ROUND(
        AVG(sh.transport_cost_gbp),
        2
    ) AS average_transport_cost_gbp

FROM core.suppliers s

JOIN core.product_supplier ps
    ON s.supplier_id = ps.supplier_id

JOIN core.shipments sh
    ON ps.product_id = sh.product_id

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    on_time_delivery_pct ASC;



-- SQL Analysis 10 — Supplier Performance Scorecard
WITH procurement AS (
    SELECT
        supplier_id,
        COUNT(DISTINCT po_id) AS total_purchase_orders,
        SUM(po_value_gbp) AS total_spend,
        AVG(
            CASE
                WHEN received_date IS NOT NULL
                THEN received_date - po_date
            END
        ) AS avg_procurement_lead_time
    FROM core.purchases
    GROUP BY supplier_id
),

delivery AS (
    SELECT
        ps.supplier_id,

        COUNT(sh.shipment_id) AS total_shipments,

        100.0 * AVG(
            CASE
                WHEN sh.on_time = TRUE THEN 1
                ELSE 0
            END
        ) AS otd_pct,

        AVG(sh.actual_days - sh.promised_days) AS avg_delivery_delay

    FROM core.product_supplier ps

    JOIN core.shipments sh
        ON ps.product_id = sh.product_id

    GROUP BY ps.supplier_id
)

SELECT
    s.supplier_id,
    s.supplier_name,

    p.total_purchase_orders,

    ROUND(p.total_spend, 2) AS total_spend_gbp,

    ROUND(p.avg_procurement_lead_time, 2)
        AS avg_procurement_lead_time_days,

    d.total_shipments,

    ROUND(d.otd_pct, 2)
        AS on_time_delivery_pct,

    ROUND(d.avg_delivery_delay, 2)
        AS avg_delivery_delay_days

FROM core.suppliers s

LEFT JOIN procurement p
    ON s.supplier_id = p.supplier_id

LEFT JOIN delivery d
    ON s.supplier_id = d.supplier_id

ORDER BY
    d.otd_pct ASC;



-- SQL Analysis 11 — Inventory + Procurement Prioritisation.
SELECT
    i.product_id,
    p.product_name,
    p.category,

    i.current_stock_units,
    i.reorder_point_units,

    (i.reorder_point_units - i.current_stock_units)
        AS inventory_gap_units,

    ROUND(
        p.selling_price_gbp - p.unit_cost_gbp,
        2
    ) AS gross_profit_per_unit_gbp,

    ROUND(
        (i.reorder_point_units - i.current_stock_units)
        * (p.selling_price_gbp - p.unit_cost_gbp),
        2
    ) AS potential_gross_profit_exposure_gbp,

    i.lead_time_days,
    i.stock_status

FROM core.inventory i

JOIN core.products p
    ON i.product_id = p.product_id

WHERE i.current_stock_units < i.reorder_point_units

ORDER BY
    potential_gross_profit_exposure_gbp DESC;



-- SQL Analysis 12 — Replenishment Priority Classification
SELECT
    i.product_id,
    p.product_name,
    p.category,

    i.current_stock_units,
    i.reorder_point_units,

    (i.reorder_point_units - i.current_stock_units)
        AS inventory_gap_units,

    ROUND(
        p.selling_price_gbp - p.unit_cost_gbp,
        2
    ) AS gross_profit_per_unit_gbp,

    ROUND(
        (i.reorder_point_units - i.current_stock_units)
        * (p.selling_price_gbp - p.unit_cost_gbp),
        2
    ) AS potential_gross_profit_exposure_gbp,

    i.lead_time_days,

    CASE
        WHEN
            (i.reorder_point_units - i.current_stock_units)
            * (p.selling_price_gbp - p.unit_cost_gbp) >= 5000
        THEN 'High Priority'

        WHEN
            (i.reorder_point_units - i.current_stock_units)
            * (p.selling_price_gbp - p.unit_cost_gbp) >= 1000
        THEN 'Medium Priority'

        ELSE 'Low Priority'
    END AS replenishment_priority

FROM core.inventory i

JOIN core.products p
    ON i.product_id = p.product_id

WHERE i.current_stock_units < i.reorder_point_units

ORDER BY
    potential_gross_profit_exposure_gbp DESC;



-- SQL Analysis 13 — Connect Products to Suppliers
SELECT
    p.product_id,
    p.product_name,
    p.category,

    i.current_stock_units,
    i.reorder_point_units,

    (i.reorder_point_units - i.current_stock_units)
        AS inventory_gap_units,

    ps.supplier_id,
    s.supplier_name,
    s.country,

    ps.lead_time_days

FROM core.inventory i

JOIN core.products p
    ON i.product_id = p.product_id

JOIN core.product_supplier ps
    ON p.product_id = ps.product_id

JOIN core.suppliers s
    ON ps.supplier_id = s.supplier_id

WHERE i.current_stock_units < i.reorder_point_units

ORDER BY
    inventory_gap_units DESC,
    ps.lead_time_days ASC;



-- SQL Analysis 14 — Procurement Priority Report
SELECT
    p.product_id,
    p.product_name,
    p.category,

    i.current_stock_units,
    i.reorder_point_units,

    (i.reorder_point_units - i.current_stock_units)
        AS inventory_gap_units,

    ROUND(
        p.selling_price_gbp - p.unit_cost_gbp,
        2
    ) AS gross_profit_per_unit_gbp,

    ROUND(
        (i.reorder_point_units - i.current_stock_units)
        * (p.selling_price_gbp - p.unit_cost_gbp),
        2
    ) AS potential_gross_profit_exposure_gbp,

    ps.supplier_id,
    s.supplier_name,
    s.country,
    ps.lead_time_days,

    CASE
        WHEN
            (i.reorder_point_units - i.current_stock_units)
            * (p.selling_price_gbp - p.unit_cost_gbp) >= 5000
        THEN 'High Priority'

        WHEN
            (i.reorder_point_units - i.current_stock_units)
            * (p.selling_price_gbp - p.unit_cost_gbp) >= 1000
        THEN 'Medium Priority'

        ELSE 'Low Priority'
    END AS replenishment_priority

FROM core.inventory i

JOIN core.products p
    ON i.product_id = p.product_id

JOIN core.product_supplier ps
    ON p.product_id = ps.product_id

JOIN core.suppliers s
    ON ps.supplier_id = s.supplier_id

WHERE i.current_stock_units < i.reorder_point_units

ORDER BY
    CASE
        WHEN
            (i.reorder_point_units - i.current_stock_units)
            * (p.selling_price_gbp - p.unit_cost_gbp) >= 5000
        THEN 1

        WHEN
            (i.reorder_point_units - i.current_stock_units)
            * (p.selling_price_gbp - p.unit_cost_gbp) >= 1000
        THEN 2

        ELSE 3
    END,

    potential_gross_profit_exposure_gbp DESC;



-- SQL Analysis 15 — Total Procurement Spend
SELECT
    COUNT(*) AS total_purchase_orders,
    SUM(quantity) AS total_units_purchased,
    ROUND(SUM(po_value_gbp), 2) AS total_procurement_spend_gbp,
    ROUND(AVG(po_value_gbp), 2) AS average_po_value_gbp
FROM core.purchases;



-- Analysis 16 — Procurement Spend by Supplier
SELECT
    s.supplier_id,
    s.supplier_name,
    s.country,

    COUNT(p.po_id) AS total_purchase_orders,

    SUM(p.quantity) AS total_units_purchased,

    ROUND(SUM(p.po_value_gbp), 2) AS total_procurement_spend_gbp,

    ROUND(
        100.0 * SUM(p.po_value_gbp)
        / SUM(SUM(p.po_value_gbp)) OVER (),
        2
    ) AS spend_share_pct

FROM core.purchases p

JOIN core.suppliers s
    ON p.supplier_id = s.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.country

ORDER BY
    total_procurement_spend_gbp DESC;


-- SQL Analysis 17 — Supplier Lead Time
SELECT
    s.supplier_id,
    s.supplier_name,
    s.country,

    COUNT(ps.product_id) AS products_supplied,

    ROUND(AVG(ps.lead_time_days), 2) AS average_lead_time_days,

    MIN(ps.lead_time_days) AS minimum_lead_time_days,

    MAX(ps.lead_time_days) AS maximum_lead_time_days

FROM core.product_supplier ps

JOIN core.suppliers s
    ON ps.supplier_id = s.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.country

ORDER BY
    average_lead_time_days DESC;



-- SQL Analysis 18 — Supplier Procurement Efficiency
SELECT
    s.supplier_id,
    s.supplier_name,
    s.country,

    COUNT(p.po_id) AS total_purchase_orders,

    ROUND(SUM(p.po_value_gbp), 2) AS total_procurement_spend_gbp,

    ROUND(
        AVG(p.po_value_gbp),
        2
    ) AS average_po_value_gbp,

    ROUND(
        AVG(p.quantity),
        2
    ) AS average_units_per_po

FROM core.purchases p

JOIN core.suppliers s
    ON p.supplier_id = s.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.country

ORDER BY
    average_po_value_gbp DESC;



-- SQL Analysis 19 — Supplier Delivery Performance
SELECT
    s.supplier_id,
    s.supplier_name,

    COUNT(sh.shipment_id) AS total_shipments,

    SUM(
        CASE
            WHEN sh.on_time = TRUE THEN 1
            ELSE 0
        END
    ) AS on_time_shipments,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN sh.on_time = TRUE THEN 1
                ELSE 0
            END
        )
        / COUNT(sh.shipment_id),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        AVG(sh.actual_days),
        2
    ) AS average_actual_delivery_days,

    ROUND(
        AVG(sh.actual_days - sh.promised_days),
        2
    ) AS average_delivery_delay_days

FROM core.shipments sh

JOIN core.product_supplier ps
    ON sh.product_id = ps.product_id

JOIN core.suppliers s
    ON ps.supplier_id = s.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    on_time_delivery_pct DESC;




-- SQL Analysis 20 — Overall Carrier Performance
SELECT
    carrier,

    COUNT(shipment_id) AS total_shipments,

    SUM(
        CASE
            WHEN on_time = TRUE THEN 1
            ELSE 0
        END
    ) AS on_time_shipments,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN on_time = TRUE THEN 1
                ELSE 0
            END
        )
        / COUNT(shipment_id),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        AVG(actual_days),
        2
    ) AS average_delivery_days,

    ROUND(
        AVG(actual_days - promised_days),
        2
    ) AS average_delay_days,

    ROUND(
        AVG(transport_cost_gbp),
        2
    ) AS average_transport_cost_gbp,

    ROUND(
        SUM(transport_cost_gbp),
        2
    ) AS total_transport_cost_gbp

FROM core.shipments

GROUP BY
    carrier

ORDER BY
    on_time_delivery_pct DESC;



-- SQL Analysis 21 — Warehouse Transport Cost
SELECT
    warehouse,

    COUNT(shipment_id) AS total_shipments,

    SUM(quantity) AS total_units_shipped,

    ROUND(
        SUM(transport_cost_gbp),
        2
    ) AS total_transport_cost_gbp,

    ROUND(
        AVG(transport_cost_gbp),
        2
    ) AS average_transport_cost_gbp,

    ROUND(
        SUM(transport_cost_gbp)
        / NULLIF(SUM(quantity), 0),
        2
    ) AS transport_cost_per_unit_gbp,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN on_time = TRUE THEN 1
                ELSE 0
            END
        )
        / COUNT(shipment_id),
        2
    ) AS on_time_delivery_pct

FROM core.shipments

GROUP BY
    warehouse

ORDER BY
    total_transport_cost_gbp DESC;



-- SQL Analysis 22 — Carrier Cost vs Delivery Performance
SELECT
    carrier,

    COUNT(shipment_id) AS total_shipments,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN on_time = TRUE THEN 1
                ELSE 0
            END
        )
        / COUNT(shipment_id),
        2
    ) AS on_time_delivery_pct,

    ROUND(
        AVG(transport_cost_gbp),
        2
    ) AS average_transport_cost_gbp,

    ROUND(
        SUM(transport_cost_gbp),
        2
    ) AS total_transport_cost_gbp,

    ROUND(
        SUM(transport_cost_gbp)
        / NULLIF(SUM(quantity), 0),
        2
    ) AS transport_cost_per_unit_gbp

FROM core.shipments

GROUP BY
    carrier

ORDER BY
    on_time_delivery_pct DESC;



-- SQL Analysis 23 — Product Profitability
SELECT
    p.product_id,
    p.product_name,
    p.category,

    SUM(o.quantity) AS units_sold,

    ROUND(SUM(o.revenue_gbp), 2) AS total_revenue_gbp,

    ROUND(SUM(o.cogs_gbp), 2) AS total_cogs_gbp,

    ROUND(SUM(o.gross_profit_gbp), 2) AS gross_profit_gbp,

    ROUND(
        100.0 * SUM(o.gross_profit_gbp)
        / NULLIF(SUM(o.revenue_gbp), 0),
        2
    ) AS gross_margin_pct

FROM core.orders o

JOIN core.products p
    ON o.product_id = p.product_id

GROUP BY
    p.product_id,
    p.product_name,
    p.category

ORDER BY
    gross_profit_gbp DESC;



-- SQL Analysis 24 — Category Profitability
SELECT
    p.category,

    SUM(o.quantity) AS units_sold,

    ROUND(SUM(o.revenue_gbp), 2) AS total_revenue_gbp,

    ROUND(SUM(o.cogs_gbp), 2) AS total_cogs_gbp,

    ROUND(SUM(o.gross_profit_gbp), 2) AS gross_profit_gbp,

    ROUND(
        100.0 * SUM(o.gross_profit_gbp)
        / NULLIF(SUM(o.revenue_gbp), 0),
        2
    ) AS gross_margin_pct

FROM core.orders o

JOIN core.products p
    ON o.product_id = p.product_id

GROUP BY
    p.category

ORDER BY
    gross_profit_gbp DESC;




-- SQL Analysis 25 — Revenue & Profit Contribution
SELECT
    p.category,

    ROUND(SUM(o.revenue_gbp), 2) AS revenue_gbp,

    ROUND(SUM(o.gross_profit_gbp), 2) AS gross_profit_gbp,

    ROUND(
        100.0 * SUM(o.revenue_gbp)
        / SUM(SUM(o.revenue_gbp)) OVER (),
        2
    ) AS revenue_contribution_pct,

    ROUND(
        100.0 * SUM(o.gross_profit_gbp)
        / SUM(SUM(o.gross_profit_gbp)) OVER (),
        2
    ) AS profit_contribution_pct

FROM core.orders o

JOIN core.products p
    ON o.product_id = p.product_id

GROUP BY
    p.category

ORDER BY
    gross_profit_gbp DESC;




-- SQL Analysis 26 — Inventory vs Profitability
SELECT
    p.product_id,
    p.product_name,
    p.category,

    i.current_stock_units,
    i.reorder_point_units,
    i.stock_status,

    ROUND(SUM(o.gross_profit_gbp), 2) AS gross_profit_gbp,

    ROUND(
        100.0 * SUM(o.gross_profit_gbp)
        / NULLIF(SUM(o.revenue_gbp), 0),
        2
    ) AS gross_margin_pct

FROM core.products p

JOIN core.inventory i
    ON p.product_id = i.product_id

JOIN core.orders o
    ON p.product_id = o.product_id

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    i.current_stock_units,
    i.reorder_point_units,
    i.stock_status

ORDER BY
    gross_profit_gbp DESC;




-- Analysis 27 — High-Profit Products at Inventory Risk
SELECT
    p.product_id,
    p.product_name,
    p.category,

    i.current_stock_units,
    i.reorder_point_units,

    (i.reorder_point_units - i.current_stock_units)
        AS units_below_reorder_point,

    ROUND(SUM(o.gross_profit_gbp), 2)
        AS gross_profit_gbp,

    ROUND(
        100.0 * SUM(o.gross_profit_gbp)
        / NULLIF(SUM(o.revenue_gbp), 0),
        2
    ) AS gross_margin_pct

FROM core.products p

JOIN core.inventory i
    ON p.product_id = i.product_id

JOIN core.orders o
    ON p.product_id = o.product_id

WHERE
    i.current_stock_units < i.reorder_point_units

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    i.current_stock_units,
    i.reorder_point_units

ORDER BY
    gross_profit_gbp DESC;


--Analysis 28 — Sales Demand Trend
SELECT
    DATE_TRUNC('month', order_date)::date AS month,

    SUM(quantity) AS units_sold,

    ROUND(SUM(revenue_gbp), 2) AS revenue_gbp,

    ROUND(SUM(gross_profit_gbp), 2) AS gross_profit_gbp

FROM core.orders

GROUP BY
    DATE_TRUNC('month', order_date)

ORDER BY
    month;



-- Analysis 29 — Inventory Turnover
SELECT
    p.product_id,
    p.product_name,
    p.category,

    SUM(o.quantity) AS units_sold,

    i.current_stock_units,

    ROUND(
        SUM(o.quantity)::numeric
        / NULLIF(i.current_stock_units, 0),
        2
    ) AS inventory_turnover_ratio

FROM core.products p

JOIN core.orders o
    ON p.product_id = o.product_id

JOIN core.inventory i
    ON p.product_id = i.product_id

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    i.current_stock_units

ORDER BY
    inventory_turnover_ratio DESC;



-- Analysis 30 — ABC Product Classification
WITH product_profit AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        ROUND(SUM(o.gross_profit_gbp), 2) AS gross_profit_gbp
    FROM core.products p
    JOIN core.orders o
        ON p.product_id = o.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),

abc AS (
    SELECT
        *,
        ROUND(
            100.0 * gross_profit_gbp
            / SUM(gross_profit_gbp) OVER (),
            2
        ) AS profit_contribution_pct,

        ROUND(
            100.0 * SUM(gross_profit_gbp) OVER (
                ORDER BY gross_profit_gbp DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
            / SUM(gross_profit_gbp) OVER (),
            2
        ) AS cumulative_profit_pct

    FROM product_profit
)

SELECT
    product_id,
    product_name,
    category,
    gross_profit_gbp,
    profit_contribution_pct,
    cumulative_profit_pct,

    CASE
        WHEN cumulative_profit_pct <= 80 THEN 'A'
        WHEN cumulative_profit_pct <= 95 THEN 'B'
        ELSE 'C'
    END AS abc_class

FROM abc

ORDER BY
    gross_profit_gbp DESC;



-- Analysis 31 — Supplier Spend vs Supplier Performance
SELECT
    s.supplier_id,
    s.supplier_name,
    s.country,

    COUNT(DISTINCT pu.po_id) AS purchase_orders,

    ROUND(SUM(pu.po_value_gbp), 2) AS procurement_spend_gbp,

    ROUND(
        AVG(pu.received_date - pu.po_date),
        2
    ) AS avg_lead_time_days,

    ROUND(
        100.0 * AVG(
            CASE
                WHEN pu.received_date <= pu.po_date + INTERVAL '7 days'
                THEN 1.0
                ELSE 0.0
            END
        ),
        2
    ) AS on_time_delivery_pct

FROM core.suppliers s

JOIN core.purchases pu
    ON s.supplier_id = pu.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.country

ORDER BY
    procurement_spend_gbp DESC;




-- Analysis 32 — Supplier Spend vs Overall Supplier Performance
WITH supplier_perf AS (
    SELECT
        s.supplier_id,
        s.supplier_name,
        s.country,

        COUNT(DISTINCT p.po_id) AS purchase_orders,

        ROUND(SUM(p.po_value_gbp), 2) AS procurement_spend_gbp,

        ROUND(
            AVG(p.received_date - p.po_date),
            2
        ) AS avg_lead_time_days,

        ROUND(
            100.0 * AVG(
                CASE
                    WHEN p.received_date <= p.po_date + INTERVAL '7 days'
                    THEN 1.0
                    ELSE 0.0
                END
            ),
            2
        ) AS on_time_pct

    FROM core.suppliers s
    JOIN core.purchases p
        ON s.supplier_id = p.supplier_id

    GROUP BY
        s.supplier_id,
        s.supplier_name,
        s.country
),

scored AS (
    SELECT
        *,
        ROUND(
            (
                (on_time_pct / NULLIF(MAX(on_time_pct) OVER (), 0)) * 50
                +
                (
                    (MAX(avg_lead_time_days) OVER () - avg_lead_time_days)
                    /
                    NULLIF(
                        MAX(avg_lead_time_days) OVER ()
                        - MIN(avg_lead_time_days) OVER (),
                        0
                    )
                ) * 50
            ),
            2
        ) AS supplier_performance_score
    FROM supplier_perf
)

SELECT
    supplier_id,
    supplier_name,
    country,
    purchase_orders,
    procurement_spend_gbp,
    avg_lead_time_days,
    on_time_pct,
    supplier_performance_score,

    CASE
        WHEN supplier_performance_score >= 75
            THEN 'Strong'
        WHEN supplier_performance_score >= 50
            THEN 'Moderate'
        ELSE 'Needs Improvement'
    END AS supplier_performance_category

FROM scored

ORDER BY
    supplier_performance_score DESC;



-- Analysis 33 — Carrier Performance & Transport Costt
SELECT
    carrier,

    COUNT(*) AS shipment_count,

    ROUND(AVG(promised_days), 2) AS avg_promised_days,

    ROUND(AVG(actual_days), 2) AS avg_actual_days,

    ROUND(
        100.0 * AVG(
            CASE
                WHEN on_time = TRUE THEN 1.0
                ELSE 0.0
            END
        ),
        2
    ) AS on_time_pct,

    ROUND(AVG(transport_cost_gbp), 2) AS avg_transport_cost_gbp,

    ROUND(SUM(transport_cost_gbp), 2) AS total_transport_cost_gbp

FROM core.shipments

GROUP BY carrier

ORDER BY on_time_pct DESC;




-- Executive KPI Summary
SELECT
    COUNT(*) AS total_products,
    (SELECT COUNT(*) FROM core.orders) AS total_orders,
    (SELECT COUNT(*) FROM core.purchases) AS total_purchase_orders,
    (SELECT COUNT(*) FROM core.shipments) AS total_shipments,
    (SELECT COUNT(*) FROM core.suppliers) AS total_suppliers,

    ROUND(
        (SELECT SUM(po_value_gbp) FROM core.purchases),
        2
    ) AS total_procurement_spend_gbp,

    ROUND(
        (SELECT SUM(gross_profit_gbp) FROM core.orders),
        2
    ) AS total_gross_profit_gbp,

    ROUND(
        (SELECT AVG(gross_profit_gbp) FROM core.orders),
        2
    ) AS average_order_gross_profit_gbp

FROM core.products;