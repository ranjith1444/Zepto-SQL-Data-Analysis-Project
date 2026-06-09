-- Zepto SQL Data Analysis Project
-- PostgreSQL script for schema setup, cleaning, EDA, and business insights

-- =========================================================
-- 1) DATABASE SCHEMA
-- =========================================================
DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id SERIAL PRIMARY KEY,
    -- Column names intentionally mirror source dataset headers.
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INTEGER, -- current stock units available
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INTEGER,
    outOfStock BOOLEAN,
    quantity INTEGER -- additional dataset quantity field (kept separately from stock count)
);

-- =========================================================
-- 2) DATA EXPLORATION
-- =========================================================

-- Total number of products
SELECT COUNT(*) AS total_products
FROM zepto;

-- Missing value detection
SELECT
    COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE name IS NULL) AS missing_name,
    COUNT(*) FILTER (WHERE mrp IS NULL) AS missing_mrp,
    COUNT(*) FILTER (WHERE discountPercent IS NULL) AS missing_discountpercent,
    COUNT(*) FILTER (WHERE availableQuantity IS NULL) AS missing_availablequantity,
    COUNT(*) FILTER (WHERE discountedSellingPrice IS NULL) AS missing_discountedsellingprice,
    COUNT(*) FILTER (WHERE weightInGms IS NULL) AS missing_weightingms,
    COUNT(*) FILTER (WHERE outOfStock IS NULL) AS missing_outofstock,
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

-- Duplicate product identification by name + category
SELECT
    category,
    name,
    COUNT(*) AS duplicate_count
FROM zepto
GROUP BY category, name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, category, name;

-- =========================================================
-- 3) DATA CLEANING
-- =========================================================

-- Remove invalid products where MRP is 0 or null
DELETE FROM zepto
WHERE mrp IS NULL OR mrp = 0;

-- Convert pricing values from paise to rupees.
-- Threshold note: values > 1000 are treated as likely paisa-era imports.
-- If your source already stores rupees (including premium items > ₹1000), skip this update.
-- Conversion threshold for paisa detection: 1000.
UPDATE zepto
SET
    mrp = ROUND(mrp / 100.0, 2),
    discountedSellingPrice = ROUND(discountedSellingPrice / 100.0, 2)
WHERE mrp > 1000 OR discountedSellingPrice > 1000;

-- Validate discountedSellingPrice <= MRP after conversion
SELECT
    sku_id,
    name,
    mrp,
    discountedSellingPrice
FROM zepto
WHERE discountedSellingPrice > mrp;

-- =========================================================
-- 4) BUSINESS QUESTIONS
-- =========================================================

-- Q1. Top 10 Best Value Products (highest discount percentage)
SELECT
    sku_id,
    category,
    name,
    mrp,
    discountPercent,
    discountedSellingPrice
FROM zepto
ORDER BY discountPercent DESC NULLS LAST
LIMIT 10;

-- Q2. High MRP Products Currently Out of Stock
-- Business definition: premium products have MRP >= ₹500.
SELECT
    sku_id,
    category,
    name,
    mrp,
    outOfStock
FROM zepto
WHERE outOfStock = TRUE
  AND mrp >= 500
ORDER BY mrp DESC;

-- Q3. Estimated Revenue by Category
SELECT
    category,
    ROUND(SUM(COALESCE(discountedSellingPrice, 0) * COALESCE(availableQuantity, 0)), 2) AS estimated_revenue
FROM zepto
GROUP BY category
ORDER BY estimated_revenue DESC;

-- Q4. Premium Products with Low Discounts
SELECT
    sku_id,
    category,
    name,
    mrp,
    discountPercent,
    discountedSellingPrice
FROM zepto
WHERE mrp >= 500
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
    sku_id,
    category,
    name,
    discountedSellingPrice,
    weightInGms,
    ROUND(discountedSellingPrice / weightInGms, 4) AS price_per_gram
FROM zepto
WHERE weightInGms IS NOT NULL
  AND weightInGms > 0
  AND discountedSellingPrice IS NOT NULL
ORDER BY price_per_gram ASC
LIMIT 10;

-- Q7. Product Weight Classification (Low / Medium / Bulk)
SELECT
    sku_id,
    category,
    name,
    weightInGms,
    CASE
        WHEN weightInGms IS NULL THEN 'Unknown'
        WHEN weightInGms < 500 THEN 'Low'
        WHEN weightInGms BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_class
FROM zepto
ORDER BY weightInGms NULLS LAST;

-- Q8. Total Inventory Weight Per Category
SELECT
    category,
    ROUND(SUM(COALESCE(weightInGms, 0) * COALESCE(availableQuantity, 0)) / 1000.0, 2) AS total_inventory_weight_kg
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight_kg DESC;
