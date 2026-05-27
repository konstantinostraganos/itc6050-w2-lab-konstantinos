SET search_path TO shop;

-- ============================================================
-- Q1: Find customer by email
-- ============================================================
EXPLAIN ANALYZE
SELECT *
FROM customer
WHERE email = 'cust5000@example.com';

-- ============================================================
-- Q2: Orders for one customer, newest first
-- ============================================================
EXPLAIN ANALYZE
SELECT order_id, order_date, total_amount
FROM orders
WHERE customer_id = 5000
ORDER BY order_date DESC;

-- ============================================================
-- Q3: Top 10 products by revenue in last 90 days
-- ============================================================
EXPLAIN ANALYZE
SELECT p.name,
SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_item oi
JOIN orders o USING (order_id)
JOIN product p USING (product_id)
WHERE o.order_date >= NOW() - INTERVAL '90 days'
GROUP BY p.name
ORDER BY revenue DESC
LIMIT 10;

-- ============================================================
-- INDEXES
-- ============================================================

-- customer email lookup
CREATE INDEX idx_customer_email
ON customer (email);

-- customer orders by date
CREATE INDEX idx_orders_customer_date
ON orders (customer_id, order_date DESC);

-- order date filter
CREATE INDEX idx_orders_date
ON orders (order_date);

-- joins
CREATE INDEX idx_order_item_order
ON order_item (order_id);

CREATE INDEX idx_order_item_product
ON order_item (product_id);

ANALYZE;