-- ============================================================
-- 01_CREATE_CORE_TABLES.SQL
-- Supply Chain Analytics & Inventory Optimisation
-- ============================================================

-- ============================================================
-- 1. PRODUCTS
-- ============================================================

CREATE TABLE IF NOT EXISTS core.products (
    product_id          VARCHAR(10) PRIMARY KEY,
    product_name        VARCHAR(100) NOT NULL,
    category            VARCHAR(100),
    unit_cost_gbp       NUMERIC(12,2) NOT NULL,
    selling_price_gbp   NUMERIC(12,2) NOT NULL,

    CONSTRAINT chk_products_unit_cost
        CHECK (unit_cost_gbp >= 0),

    CONSTRAINT chk_products_selling_price
        CHECK (selling_price_gbp >= 0)
);


-- ============================================================
-- 2. SUPPLIERS
-- ============================================================

CREATE TABLE IF NOT EXISTS core.suppliers (
    supplier_id      VARCHAR(10) PRIMARY KEY,
    supplier_name    VARCHAR(150) NOT NULL,
    country          VARCHAR(100),
    payment_terms    VARCHAR(100)
);


-- ============================================================
-- 3. PRODUCT_SUPPLIER
-- ============================================================

CREATE TABLE IF NOT EXISTS core.product_supplier (
    product_id       VARCHAR(10) NOT NULL,
    supplier_id      VARCHAR(10) NOT NULL,
    lead_time_days   INTEGER NOT NULL,

    PRIMARY KEY (product_id, supplier_id),

    CONSTRAINT fk_product_supplier_product
        FOREIGN KEY (product_id)
        REFERENCES core.products(product_id),

    CONSTRAINT fk_product_supplier_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES core.suppliers(supplier_id),

    CONSTRAINT chk_product_supplier_lead_time
        CHECK (lead_time_days >= 0)
);

-- ============================================================
-- 4. ORDERS
-- ============================================================

CREATE TABLE IF NOT EXISTS core.orders (
    order_id          VARCHAR(20) PRIMARY KEY,
    order_date        DATE NOT NULL,
    product_id        VARCHAR(10) NOT NULL,
    quantity          INTEGER NOT NULL,
    customer_type     VARCHAR(50),
    sales_channel     VARCHAR(50),
    revenue_gbp       NUMERIC(14,2),
    cogs_gbp          NUMERIC(14,2),
    gross_profit_gbp  NUMERIC(14,2),

    CONSTRAINT fk_orders_product
        FOREIGN KEY (product_id)
        REFERENCES core.products(product_id),

    CONSTRAINT chk_orders_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_orders_revenue
        CHECK (revenue_gbp >= 0),

    CONSTRAINT chk_orders_cogs
        CHECK (cogs_gbp >= 0)
);


-- ============================================================
-- 5. INVENTORY
-- ============================================================

CREATE TABLE IF NOT EXISTS core.inventory (
    product_id              VARCHAR(10) PRIMARY KEY,
    average_daily_demand    NUMERIC(12,2),
    lead_time_days          INTEGER,
    safety_stock_units      INTEGER,
    current_stock_units     INTEGER,
    reorder_point_units     INTEGER,
    inventory_value_gbp     NUMERIC(14,2),
    stock_status            VARCHAR(50),

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES core.products(product_id),

    CONSTRAINT chk_inventory_demand
        CHECK (average_daily_demand >= 0),

    CONSTRAINT chk_inventory_lead_time
        CHECK (lead_time_days >= 0),

    CONSTRAINT chk_inventory_safety_stock
        CHECK (safety_stock_units >= 0),

    CONSTRAINT chk_inventory_current_stock
        CHECK (current_stock_units >= 0),

    CONSTRAINT chk_inventory_rop
        CHECK (reorder_point_units >= 0),

    CONSTRAINT chk_inventory_value
        CHECK (inventory_value_gbp >= 0)
);


-- ============================================================
-- 6. PURCHASES
-- ============================================================

CREATE TABLE IF NOT EXISTS core.purchases (
    po_id              VARCHAR(20) PRIMARY KEY,
    po_date             DATE NOT NULL,
    product_id          VARCHAR(10) NOT NULL,
    supplier_id         VARCHAR(10) NOT NULL,
    quantity            INTEGER NOT NULL,
    unit_cost_gbp       NUMERIC(12,2) NOT NULL,
    po_value_gbp        NUMERIC(14,2),
    received_date       DATE,
    status              VARCHAR(50),

    CONSTRAINT fk_purchases_product
        FOREIGN KEY (product_id)
        REFERENCES core.products(product_id),

    CONSTRAINT fk_purchases_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES core.suppliers(supplier_id),

    CONSTRAINT chk_purchases_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_purchases_unit_cost
        CHECK (unit_cost_gbp >= 0),

    CONSTRAINT chk_purchases_po_value
        CHECK (po_value_gbp >= 0)
);


-- ============================================================
-- 7. SHIPMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS core.shipments (
    shipment_id          VARCHAR(20) PRIMARY KEY,
    shipment_date        DATE NOT NULL,
    product_id           VARCHAR(10) NOT NULL,
    quantity              INTEGER NOT NULL,
    warehouse             VARCHAR(100),
    carrier               VARCHAR(100),
    promised_days         INTEGER,
    actual_days           INTEGER,
    on_time              BOOLEAN,
    transport_cost_gbp   NUMERIC(14,2),
    month                 VARCHAR(20),

    CONSTRAINT fk_shipments_product
        FOREIGN KEY (product_id)
        REFERENCES core.products(product_id),

    CONSTRAINT chk_shipments_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_shipments_promised_days
        CHECK (promised_days >= 0),

    CONSTRAINT chk_shipments_actual_days
        CHECK (actual_days >= 0),

    CONSTRAINT chk_shipments_transport_cost
        CHECK (transport_cost_gbp >= 0)
);


-- ============================================================
-- 8. SUPPLIER_KPI
-- ============================================================
DROP TABLE IF EXISTS core.supplier_kpi;

CREATE TABLE core.supplier_kpi (
    supplier_id VARCHAR(20) PRIMARY KEY,
    total_po INTEGER,
    total_spend_gbp NUMERIC(12,2),
    average_order_value_gbp NUMERIC(12,2)
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_orders_product
    ON core.orders(product_id);

CREATE INDEX IF NOT EXISTS idx_orders_date
    ON core.orders(order_date);

CREATE INDEX IF NOT EXISTS idx_purchases_product
    ON core.purchases(product_id);

CREATE INDEX IF NOT EXISTS idx_purchases_supplier
    ON core.purchases(supplier_id);

CREATE INDEX IF NOT EXISTS idx_purchases_date
    ON core.purchases(po_date);

CREATE INDEX IF NOT EXISTS idx_shipments_product
    ON core.shipments(product_id);

CREATE INDEX IF NOT EXISTS idx_shipments_date
    ON core.shipments(shipment_date);

CREATE INDEX IF NOT EXISTS idx_shipments_carrier
    ON core.shipments(carrier);

CREATE INDEX IF NOT EXISTS idx_product_supplier_supplier
    ON core.product_supplier(supplier_id);