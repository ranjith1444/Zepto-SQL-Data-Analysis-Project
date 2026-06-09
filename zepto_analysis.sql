-- Zepto SQL Data Analysis Project
-- PostgreSQL script for schema setup, data cleaning, exploration, and business insights.

-- ============================================================
-- 1) Database Schema
-- ============================================================
CREATE TABLE IF NOT EXISTS zepto (
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INTEGER,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INTEGER,
    outOfStock BOOLEAN,
    quantity INTEGER
);

-- ============================================================
-- 2) Data Cleaning
-- ============================================================
-- Remove invalid products where MRP is zero or missing.
DELETE FROM zepto
WHERE COALESCE(mrp, 0) = 0;

-- Convert paise to rupees only if values appear to be in paise.
-- This guard avoids repeatedly dividing values already in rupees.
UPDATE zepto
SET
    mrp = ROUND(mrp / 100.0, 2),
    discountedSellingPrice = ROUND(discountedSellingPrice / 100.0, 2)
WHERE mrp > 1000 OR discountedSellingPrice > 1000;

-- ============================================================
-- 3) Data Exploration
-- ============================================================
-- Total number of products
SELECT COUNT(*) AS total_products
FROM zepto;

-- Missing value detection
SELECT
    COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE name IS NULL OR TRIM(name) = '') AS missing_name,
    COUNT(*) FILTER (WHERE mrp IS NULL) AS missing_mrp,
    COUNT(*) FILTER (WHERE discountPercent IS NULL) AS missing_discount_percent,
    COUNT(*) FILTER (WHERE availableQuantity IS NULL) AS missing_available_quantity,
    COUNT(*) FILTER (WHERE discountedSellingPrice IS NULL) AS missing_discounted_selling_price,
    COUNT(*) FILTER (WHERE weightInGms IS NULL) AS missing_weight_in_gms,
    COUNT(*) FILTER (WHERE outOfStock IS NULL) AS missing_out_of_stock,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity
FROM zepto;

-- Category exploration
SELECT
    category,
    COUNT(*) AS product_count
FROM zepto
GROUP BY category
ORDER BY product_count DESC;

-- Stock availability analysis
SELECT
    outOfStock,
    COUNT(*) AS product_count
FROM zepto
GROUP BY outOfStock
ORDER BY product_count DESC;

-- Duplicate product identification (same category + name)
SELECT
    category,
    name,
    COUNT(*) AS duplicate_count
FROM zepto
GROUP BY category, name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, name;

-- ============================================================
-- 4) Business Questions
-- ============================================================

-- Q1. Top 10 Best Value Products (highest discount percentages)
SELECT
    name,
    category,
    mrp,
    discountedSellingPrice,
    discountPercent
FROM zepto
ORDER BY discountPercent DESC NULLS LAST
LIMIT 10;

-- Q2. High MRP Products Currently Out of Stock
SELECT
    name,
    category,
    mrp,
    discountedSellingPrice,
    discountPercent
FROM zepto
WHERE outOfStock = TRUE
ORDER BY mrp DESC NULLS LAST
LIMIT 10;

-- Q3. Estimated Revenue by Category
SELECT
    category,
    ROUND(SUM(COALESCE(discountedSellingPrice, 0) * COALESCE(availableQuantity, 0)), 2) AS estimated_revenue
FROM zepto
GROUP BY category
ORDER BY estimated_revenue DESC;

-- Q4. Premium Products with Low Discounts (MRP > 500 and discount < 10%)
SELECT
    name,
    category,
    mrp,
    discountPercent,
    discountedSellingPrice
FROM zepto
WHERE mrp > 500
  AND COALESCE(discountPercent, 0) < 10
ORDER BY mrp DESC;

-- Q5. Categories with Highest Average Discounts
SELECT
    category,
    ROUND(AVG(discountPercent), 2) AS avg_discount_percent
FROM zepto
GROUP BY category
ORDER BY avg_discount_percent DESC NULLS LAST
LIMIT 10;

-- Q6. Best Value Products by Price Per Gram
SELECT
    name,
    category,
    weightInGms,
    discountedSellingPrice,
    ROUND(discountedSellingPrice / NULLIF(weightInGms, 0), 4) AS price_per_gram
FROM zepto
WHERE weightInGms > 0
  AND discountedSellingPrice IS NOT NULL
ORDER BY price_per_gram ASC
LIMIT 10;

-- Q7. Product Weight Classification (Low, Medium, Bulk)
SELECT
    name,
    category,
    weightInGms,
    CASE
        WHEN weightInGms < 500 THEN 'Low'
        WHEN weightInGms BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_class
FROM zepto
ORDER BY weightInGms ASC NULLS LAST;

-- Q8. Total Inventory Weight Per Category
SELECT
    category,
    SUM(COALESCE(weightInGms, 0) * COALESCE(availableQuantity, 0)) AS total_inventory_weight_gms
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight_gms DESC;
