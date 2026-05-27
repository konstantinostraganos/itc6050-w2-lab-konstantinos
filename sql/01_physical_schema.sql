-- ============================================================
-- Schema Setup
-- ============================================================

DROP SCHEMA IF EXISTS shop CASCADE;
CREATE SCHEMA shop;
SET search_path TO shop;

-- ============================================================
-- Customer
-- ============================================================

CREATE TABLE customer (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (email ~ '^[^@]+@[^@]+\.[^@]+$')
);

-- ============================================================
-- Address
-- ============================================================

CREATE TABLE address (
    address_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer ON DELETE CASCADE,
    line1 VARCHAR(120) NOT NULL,
    city VARCHAR(80) NOT NULL,
    postcode VARCHAR(20) NOT NULL,
    country CHAR(2) NOT NULL CHECK (country ~ '^[A-Z]{2}$'),
    is_default BOOLEAN NOT NULL DEFAULT FALSE
);

-- ============================================================
-- Category
-- ============================================================

CREATE TABLE category (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- Product
-- ============================================================

CREATE TABLE product (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id BIGINT NOT NULL REFERENCES category ON DELETE RESTRICT,
    name VARCHAR(150) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

-- ============================================================
-- Orders
-- ============================================================

CREATE TABLE orders (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer ON DELETE RESTRICT,
    order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(30) NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0)
);

-- ============================================================
-- Order Item
-- ============================================================

CREATE TABLE order_item (
    order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES product ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- ============================================================
-- Index (Stretch requirement)
-- ============================================================

CREATE INDEX idx_default_address
ON address(customer_id)
WHERE is_default = TRUE;