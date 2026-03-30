---This is to check if the data is loaded properly
SELECT *
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP
LIMIT 10 ;

----------------------------------------
---1.CHECKING DATE RANGE
----------------------------------------
---WHEN FIRST WAS THE DATA COLLECTED : 2023-01-01
SELECT MIN(transaction_date)AS start_date
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;

---WHEN DATA WAS LAST COLLECTED: 2023-06-30
SELECT MAX(transaction_date)AS latest_date
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;

--------------------------------------
---2.CHECKING DIFFERENT STORE LOCATTIONS
--------------------------------------
--WE HAVE 3 , LOWER MANHATTAN ,HELL'S KITCHEN AND ASTORIA
SELECT DISTINCT store_location
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;

---------------------------------------
---3.CHECKING PRODUCTS SOLD ACROSS ALL STORES
----------------------------------------
SELECT DISTINCT product_category AS Category,
                product_type AS product_type,
                product_detail AS product_name
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;

SELECT product_type
FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP;

------------------------------------------
SELECT 
      COUNT(*) AS number_of_rows,
      COUNT(DISTINCT transaction_id) AS number_of_sales,
      COUNT(DISTINCT product_id) AS number_of_product,
      COUNT(DISTINCT store_id) AS number_of_stores
    FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP ;

-------------------------------------------
SELECT * ,
---Adding new columns for insights
---New column added 1
      Dayname(transaction_date)AS Day_name,
--- 2nd column
     Monthname(transaction_date)AS Month_name,
---3rd column
    Dayofmonth(transaction_date)AS Day_of_month,
--- Determining weekday/weekend
  CASE 
     WHEN Dayname(transaction_date) IN ('Sun','Sat') THEN 'Weekend'
     ELSE 'Weekday'
     END AS Day_classification,
---5th column - Time Buckets
   CASE
      WHEN date_format(transaction_time,'HH:mm:ss') BETWEEN '05:00:00' AND '08:59:59' THEN 'Morning Rush Hour'
      WHEN date_format(transaction_time,'HH:mm:ss') BETWEEN '09:00:00' AND '11:59:59' THEN 'Mid Morning'
      WHEN date_format(transaction_time,'HH:mm:ss') BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
      WHEN date_format(transaction_time,'HH:mm:ss') BETWEEN '16:00:00' AND '18:00:00' THEN 'Evening Rush Hour'
      ELSE 'Night'
      END AS Time_classification,
--- column 6 - Spend Buckets
  CASE
     WHEN(transaction_qty*unit_price) <=50 THEN 'Low Spender'
     WHEN(transaction_qty*unit_price) BETWEEN 51 AND 200 THEN 'Medium Spender'
     WHEN(transaction_qty*unit_price) BETWEEN 201 AND 300 THEN 'High Medium Spender'
     ELSE 'High Spender'
     END AS spend_bucket,
----column 7 - Revenue
transaction_qty*unit_price AS Revenue
 FROM WORKSPACE.DEFAULT.BRIGHT_COFFEE_SHOP ;





      




