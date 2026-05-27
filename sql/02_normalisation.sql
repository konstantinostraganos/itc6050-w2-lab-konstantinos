-- ============================================================
-- Step 4a: Identify Violations
-- ============================================================

-- 1NF violation:
-- customer_phones contains multiple values in a single column (comma-separated list)
-- Example: '555-1212, 555-3434'
-- This violates First Normal Form because attributes must be atomic.

-- Functional Dependency 1:
-- product_name → product_category, product_price
-- This violates 3NF because product attributes depend on a non-key attribute,
-- causing redundancy and update anomalies.

-- Functional Dependency 2:
-- customer_email → customer_name, customer_city, customer_country
-- This violates 3NF because non-key attributes depend on another non-key attribute,
-- creating transitive dependency.

-- Update anomaly example:
-- If a product price changes, every row containing that product must be updated,
-- leading to inconsistent data if some rows are missed.

-- ============================================================
-- Step 4b: Decomposed 3NF Schema
-- ============================================================

-- CUSTOMER
CREATE TABLE customer (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(160) NOT NULL,
    city VARCHAR(80),
    country VARCHAR(60)
);

-- CUSTOMER PHONE (1-to-many)
CREATE TABLE customer_phone (
    customer_id BIGINT NOT NULL REFERENCES customer ON DELETE CASCADE,
    phone VARCHAR(30) NOT NULL,
    PRIMARY KEY (customer_id, phone)
);

-- PRODUCT
CREATE TABLE product (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    category VARCHAR(60) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

-- SALE (header table)
CREATE TABLE sale (
    sale_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT REFERENCES customer,
    sale_date DATE NOT NULL
);

-- SALE ITEM (line items)
CREATE TABLE sale_item (
    sale_id BIGINT NOT NULL REFERENCES sale ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES product,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price_at_sale NUMERIC(10,2) NOT NULL,
    line_total NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (sale_id, product_id)
);

-- ============================================================
-- Concept Check Answer
-- ============================================================

-- unit_price_at_sale is NOT incorrect denormalisation.
-- It is intentional denormalisation for historical accuracy,
-- because product prices change over time and must be preserved per transaction.