-- ============================================================
-- BRIGHT COFFEE SHOP PROJECT
-- ============================================================
-- 0. CHECK IF THE DATA IS LOADED PROPERLY
-- ============================================================

SELECT *
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP
LIMIT 10;


-- ============================================================
-- 1. CHECKING DATE RANGE
-- ============================================================

-- WHEN WAS THE FIRST TRANSACTION COLLECTED?
SELECT
    MIN(transaction_date) AS start_date
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;


-- WHEN WAS THE LAST TRANSACTION COLLECTED?
SELECT
    MAX(transaction_date) AS latest_date
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;


-- ============================================================
-- 2. CHECKING DIFFERENT STORE LOCATIONS
-- ============================================================

-- CHECK THE DIFFERENT STORE LOCATIONS
SELECT DISTINCT
    store_location
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;


-- ============================================================
-- 3. CHECKING PRODUCTS SOLD ACROSS ALL STORES
-- ============================================================

-- CHECK THE DIFFERENT PRODUCT CATEGORIES, PRODUCT TYPES AND PRODUCT DETAILS
SELECT DISTINCT
    product_category AS Category,
    product_type AS product_type,
    product_detail AS product_name
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;


-- CHECK ALL PRODUCT TYPES
SELECT DISTINCT
    product_type
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;


-- ============================================================
-- 4. BASIC DATASET SIZE
-- ============================================================

SELECT
    COUNT(*) AS number_of_rows,
    COUNT(DISTINCT transaction_id) AS number_of_sales,
    COUNT(DISTINCT product_id) AS number_of_products,
    COUNT(DISTINCT store_id) AS number_of_stores
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;


-- ============================================================
-- 5. CHECKING FOR DUPLICATE TRANSACTIONS
-- ============================================================
-- CHECK WHETHER THE SAME TRANSACTION_ID APPEARS MORE THAN ONCE

SELECT
    transaction_id,
    COUNT(*) AS transaction_count
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY transaction_count DESC;


-- ============================================================
-- 6. CHECKING FOR MISSING VALUES
-- ============================================================
-- CHECK IMPORTANT COLUMNS FOR NULL / MISSING VALUES

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END)
        AS missing_transaction_id,

    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END)
        AS missing_transaction_date,

    SUM(CASE WHEN transaction_time IS NULL THEN 1 ELSE 0 END)
        AS missing_transaction_time,

    SUM(CASE WHEN transaction_qty IS NULL THEN 1 ELSE 0 END)
        AS missing_transaction_qty,

    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END)
        AS missing_unit_price,

    SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END)
        AS missing_product_category,

    SUM(CASE WHEN product_type IS NULL THEN 1 ELSE 0 END)
        AS missing_product_type,

    SUM(CASE WHEN product_detail IS NULL THEN 1 ELSE 0 END)
        AS missing_product_detail,

    SUM(CASE WHEN store_location IS NULL THEN 1 ELSE 0 END)
        AS missing_store_location

FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;


-- ============================================================
-- 7. CHECKING FOR INVALID QUANTITIES
-- ============================================================
-- CHECK WHETHER THERE ARE ZERO OR NEGATIVE QUANTITIES

SELECT *
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP
WHERE transaction_qty <= 0;


-- ============================================================
-- 8. CHECKING FOR INVALID PRICES
-- ============================================================
-- CHECK WHETHER THERE ARE ZERO OR NEGATIVE UNIT PRICES

SELECT *
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP
WHERE unit_price <= 0;


-- ============================================================
-- 9. CHECKING THE ORIGINAL DATA TYPES
-- ============================================================

-- THIS HELPS CONFIRM THAT DATE, TIME AND NUMERIC COLUMNS ARE STORED USING THE CORRECT DATA TYPES

DESCRIBE WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;


-- ============================================================
-- 10. CREATE THE CLEAN / ANALYTICAL DATASET
-- ============================================================

SELECT

    -- ORIGINAL TRANSACTION INFORMATION
    transaction_id,
    transaction_date,
    transaction_time,

    -- ORIGINAL QUANTITY AND PRICE
    transaction_qty,
    unit_price,

    -- STORE INFORMATION
    store_id,
    store_location,

    -- PRODUCT INFORMATION
    product_id,
    product_category,
    product_type,
    product_detail,


    -- ========================================================
    -- NEW COLUMN 1: TOTAL AMOUNT / REVENUE
    -- ========================================================
    -- CALCULATES THE TOTAL MONEY GENERATED BY EACH TRANSACTION


    transaction_qty * unit_price AS total_amount,


    -- ========================================================
    -- NEW COLUMN 2: DAY NAME
    -- ========================================================
    -- IDENTIFIES THE DAY OF THE WEEK

    dayname(transaction_date) AS Day_name,


    -- ========================================================
    -- NEW COLUMN 3: DAY OF WEEK NUMBER
    -- ========================================================
    -- USED TO CORRECTLY ORDER DAYS FROM MONDAY TO SUNDAY

    dayofweek(transaction_date) AS Day_of_week_num,


    -- ========================================================
    -- NEW COLUMN 4: MONTH NAME
    -- ========================================================
    -- IDENTIFIES THE MONTH OF EACH TRANSACTION

    monthname(transaction_date) AS Month_name,


    -- ========================================================
    -- NEW COLUMN 5: MONTH NUMBER
    -- ========================================================

    month(transaction_date) AS Month_number,


    -- ========================================================
    -- NEW COLUMN 6: YEAR-MONTH
    -- ========================================================
    

    date_format(transaction_date, 'yyyy-MM') AS Year_month,


    -- ========================================================
    -- NEW COLUMN 7: DAY OF MONTH
    -- ========================================================
    -- IDENTIFIES THE NUMBER OF THE DAY WITHIN THE MONTH

    dayofmonth(transaction_date) AS Day_of_month,


    -- ========================================================
    -- NEW COLUMN 8: DAY CLASSIFICATION
    -- ========================================================
    -- IDENTIFIES WHETHER THE TRANSACTION OCCURRED ON A
    -- WEEKDAY OR WEEKEND.

    CASE
        WHEN dayofweek(transaction_date) IN (1, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_classification,


    -- ========================================================
    -- NEW COLUMN 9: IS WEEKEND
    -- ========================================================

    CASE
        WHEN dayofweek(transaction_date) IN (1, 7)
            THEN 'Yes'
        ELSE 'No'
    END AS Is_weekend,


    -- ========================================================
    -- NEW COLUMN 10: TRANSACTION HOUR
    -- ========================================================
    -- EXTRACTS THE HOUR FROM THE TRANSACTION TIME

    hour(transaction_time) AS Transaction_hour,


    -- ========================================================
    -- NEW COLUMN 11: TIME CLASSIFICATION
    -- ========================================================
    -- GROUPS TRANSACTIONS INTO BROAD PERIODS OF THE DAY.
    

    CASE
        WHEN hour(transaction_time) BETWEEN 5 AND 8
            THEN 'Morning Rush Hour'

        WHEN hour(transaction_time) BETWEEN 9 AND 11
            THEN 'Mid Morning'

        WHEN hour(transaction_time) BETWEEN 12 AND 15
            THEN 'Afternoon'

        WHEN hour(transaction_time) BETWEEN 16 AND 18
            THEN 'Evening Rush Hour'

        ELSE 'Night'
    END AS Time_classification,


    -- ========================================================
    -- NEW COLUMN 12: 30-MINUTE TIME BUCKET
    -- ========================================================

    -- THIS CREATES 30-MINUTE INTERVALS.
    

    date_format(
        from_unixtime(
            floor(unix_timestamp(transaction_time) / 1800) * 1800
        ),
        'HH:mm'
    ) AS Time_30_minute_bucket,


    -- ========================================================
    -- NEW COLUMN 13: QUARTER
    -- ========================================================


    quarter(transaction_date) AS Quarter


FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;
