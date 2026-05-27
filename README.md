# ITC 6050 — Week 2 Lab

This project demonstrates the full lifecycle of relational database design:
- Conceptual modelling
- Logical schema design (DBML)
- Physical implementation in PostgreSQL
- Normalisation to 3NF
- Data loading with synthetic datasets
- Performance optimisation using indexes and EXPLAIN ANALYZE

---

## Step 1 — Conceptual Model

The system models a simple e-commerce platform with the following entities:

- Customer
- Address
- Category
- Product
- Orders
- OrderItem

### Key relationships:
- A customer can have multiple addresses
- A customer can place many orders
- Each order contains multiple order items
- Each order item references one product
- Each product belongs to one category

### Design justification:
OrderItem exists as a separate entity to represent the many-to-many relationship between Orders and Products and to store quantity and unit price at the time of purchase.

---

## Step 2 — Logical Model (DBML)

The logical model was designed using dbdiagram.io with generic SQL types.

Key design decisions:
- All entities use surrogate primary keys
- Relationships are expressed using foreign keys
- Only generic types (int, varchar, decimal, datetime) are used
- No DB-specific types (e.g. BIGINT, JSONB)

This ensures portability across database systems.

---

## Step 3 — Physical Schema (PostgreSQL)

The schema was implemented in PostgreSQL using the following structure:

- customer
- address
- category
- product
- orders
- order_item

### Key features:
- Surrogate keys using `BIGINT GENERATED ALWAYS AS IDENTITY`
- Foreign key constraints with referential integrity
- CHECK constraints for data validation
- ON DELETE CASCADE for dependent entities (e.g. order items)
- ON DELETE RESTRICT for lookup entities (e.g. category, product)

### Example constraints:
- email format validation using regex
- price >= 0
- quantity > 0
- stock_quantity >= 0

---

## Step 4 — Normalisation (3NF)

### 1NF Violation
The column `customer_phones` contains multiple values in a single field (comma-separated list), violating atomicity.

### Functional Dependency 1
product_name → product_category, product_price  
This violates 3NF because product attributes depend on a non-key attribute.

### Functional Dependency 2
customer_email → customer_name, customer_city, customer_country  
This violates 3NF due to transitive dependency.

### Update anomaly example
If a product price changes, multiple rows must be updated, leading to inconsistency risk.

---

### Decomposed 3NF Schema

- customer(customer_id, email, first_name, last_name, city, country)
- customer_phone(customer_id, phone)
- product(product_id, name, category_id, unit_price)
- sale(sale_id, customer_id, sale_date)
- sale_item(sale_id, product_id, quantity, unit_price_at_sale, line_total)

### Design justification:
unit_price_at_sale is required to preserve historical accuracy of transactions.

---

## Step 5 — Data Loading

Synthetic data was generated using `generate_series` in PostgreSQL:

- 50 categories
- 1,000 products
- 10,000 customers
- 100,000 orders
- 500,000 order items

This dataset simulates a realistic workload for performance testing.

---

## Step 6 — Indexing & Performance Analysis

### Indexes created:
- idx_customer_email (customer.email)
- idx_orders_customer_date (customer_id, order_date DESC)
- idx_orders_date (order_date)
- idx_order_item_order (order_id)
- idx_order_item_product (product_id)

---

### Q1 — Customer lookup by email

**Before indexing:** Sequential Scan  
**After indexing:** Index Scan

- PostgreSQL used Index Scan on idx_customer_email
- Execution Time: 12.300 ms (significantly improved from full scan)

---

### Q2 — Orders per customer

**Before indexing:** Sequential Scan (~519 ms)  
**After indexing:** Bitmap Index Scan (~36 ms)

- Index used for filtering by customer_id
- Sorting still required for order_date DESC (visible Sort step in plan)

---

### Q3 — Revenue per product (last 90 days)

- Uses Hash Join and parallel workers
- Uses Partial HashAggregate for grouping
- Final sorting for top 10 results

Execution Time: ~1544 ms

Despite indexes, performance improvement is limited because:
- Large-scale joins
- Aggregation over large dataset
- Full table scans still required for computation

---

## Reflection (Step 6c)

### 1. Biggest speed-up
Q1 saw the biggest speed-up because it changed from a full sequential scan to an index scan on email, enabling direct lookup instead of scanning all rows.

---

### 2. Index usage in Q2 ordering
PostgreSQL used the index for filtering rows by customer_id, but not for ordering. This is visible because the execution plan includes a separate Sort step after the Bitmap Index Scan.

---

### 3. Index on product_id usefulness
The index on order_item.product_id is useful for join operations between order_item and product tables, even if it was not directly used in the sample queries.

---

### 4. Trade-offs of indexes
The main trade-off is improved read performance at the cost of slower writes. Insert, update, and delete operations become slower because indexes must also be maintained.

---

## Conclusion

This lab demonstrates:
- Proper relational schema design
- Normalisation up to 3NF
- Realistic data generation
- Performance tuning using indexes
- Analysis of query execution plans

Indexes significantly improve point lookup queries but have limited effect on large aggregation workloads.