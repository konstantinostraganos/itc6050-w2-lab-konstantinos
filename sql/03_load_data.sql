SET search_path TO shop;

-- ============================================================
-- 50 categories
-- ============================================================
INSERT INTO category (name)
SELECT 'Category ' || g
FROM generate_series(1, 50) g;

-- ============================================================
-- 1,000 products (FIXED: price instead of unit_price)
-- ============================================================
INSERT INTO product (category_id, name, price)
SELECT
((g - 1) % 50) + 1,
'Product ' || g,
ROUND((random() * 200 + 5)::numeric, 2)
FROM generate_series(1, 1000) g;

-- ============================================================
-- 10,000 customers
-- ============================================================
INSERT INTO customer (email, first_name, last_name)
SELECT
'cust' || g || '@example.com',
'First' || g,
'Last' || g
FROM generate_series(1, 10000) g;

-- ============================================================
-- 100,000 orders
-- (IMPORTANT: column names must match your Step 3 schema)
-- ============================================================
INSERT INTO orders (customer_id, order_date, status, total_amount)
SELECT
((g - 1) % 10000) + 1,
NOW() - (random() * INTERVAL '730 days'),
(ARRAY['new','paid','shipped','delivered','cancelled'])[ceil(random()*5)],
ROUND((random() * 500 + 10)::numeric, 2)
FROM generate_series(1, 100000) g;

-- ============================================================
-- 500,000 order items
-- ============================================================
INSERT INTO order_item (order_id, product_id, quantity, unit_price)
SELECT
((g - 1) % 100000) + 1,
((g - 1) % 1000) + 1,
ceil(random() * 5)::int,
ROUND((random() * 200 + 5)::numeric, 2)
FROM generate_series(1, 500000) g;

-- ============================================================
-- Refresh planner statistics
-- ============================================================
ANALYZE;