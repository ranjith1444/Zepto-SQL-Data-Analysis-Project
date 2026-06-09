# 🛒 Zepto SQL Data Analysis Project

## 📌 Overview

This project performs Exploratory Data Analysis (EDA) and business intelligence reporting on Zepto's inventory dataset using PostgreSQL.

The objective is to demonstrate SQL skills including:

* Database Creation
* Data Cleaning
* Data Exploration
* Business Analysis
* Aggregations
* CASE Statements
* Revenue Estimation

---

## 🛠 Tech Stack

* PostgreSQL
* SQL
* CSV Dataset
* pgAdmin

---

## 📂 Dataset

The dataset contains product inventory information such as:

* Product Name
* Category
* MRP
* Discount Percentage
* Available Quantity
* Product Weight
* Stock Availability

---

## Database Schema

```sql
CREATE TABLE zepto (
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
```

---

## Data Exploration

* Total number of products
* Missing value detection
* Category exploration
* Stock availability analysis
* Duplicate product identification

---

## Data Cleaning

* Removed invalid products with MRP = 0
* Converted pricing values from paise to rupees
* Validated dataset consistency

---

## Business Questions Solved

### Q1. Top 10 Best Value Products

Products offering the highest discount percentages.

### Q2. High MRP Products Currently Out of Stock

Identified premium products unavailable for purchase.

### Q3. Estimated Revenue by Category

Calculated potential revenue based on inventory and selling price.

### Q4. Premium Products with Low Discounts

Products priced above ₹500 with discounts below 10%.

### Q5. Categories with Highest Average Discounts

Top categories providing maximum discounts.

### Q6. Best Value Products by Price Per Gram

Compared products based on unit pricing.

### Q7. Product Weight Classification

Classified products into:

* Low
* Medium
* Bulk

### Q8. Total Inventory Weight Per Category

Calculated total inventory weight across categories.

---

## SQL Concepts Used

* SELECT
* WHERE
* GROUP BY
* ORDER BY
* HAVING
* Aggregate Functions
* CASE Statements
* Data Cleaning Queries

---

## Key Learnings

* Practical SQL Query Writing
* Data Cleaning Techniques
* Exploratory Data Analysis
* Business Insight Generation
* Inventory Analytics

---


