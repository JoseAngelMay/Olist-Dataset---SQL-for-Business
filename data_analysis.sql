
SELECT * FROM products;

SELECT DISTINCT product_category_name 
FROM products 
ORDER BY product_category_name;

SELECT *
FROM products
WHERE product_category_name IS NULL;

SELECT product_category_name, COUNT(*) AS product_count
FROM products
GROUP BY product_category_name
ORDER BY product_count;

SELECT * FROM order_items;

SELECT p.product_category_name, COUNT(p.product_category_name) AS purchase_count
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
GROUP BY product_category_name
ORDER BY 2;

SELECT oi.order_id, oi.product_id, p.product_category_name
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id;

SELECT PERCENTILE_CONT(ARRAY[0.25, 0.50, 0.75, 1.00])
	   WITHIN GROUP (ORDER BY price) AS quartiles
FROM order_items;

SELECT *
FROM order_items
WHERE price >= (SELECT PERCENTILE_CONT(0.00) WITHIN GROUP (ORDER BY price) FROM order_items)
   AND price < (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) FROM order_items)
ORDER BY price DESC;

SELECT * FROM orders;      -- order_id, customer_id
SELECT * FROM products;    -- product_id
SELECT * FROM order_items; -- order_id, product_id


SELECT o.order_id, p.product_category_name, oi.order_id
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE CAST(o.order_purchase_timestamp AS TEXT) LIKE '____-01-__ __:__:__';

SELECT p.product_category_name, COUNT(p.product_category_name) AS category_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE CAST(o.order_purchase_timestamp AS TEXT) LIKE '____-01-__ __:__:__'
GROUP BY (product_category_name)
ORDER BY category_sales DESC;

SELECT p.product_category_name, SUBSTR(CAST(o.order_purchase_timestamp AS TEXT), 6, 2) AS month, COUNT(p.product_category_name) AS category_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY (product_category_name, SUBSTR(CAST(o.order_purchase_timestamp AS TEXT), 6, 2))
ORDER BY month ASC, category_sales DESC;

SELECT SUBSTR(CAST(o.order_purchase_timestamp AS TEXT), 6, 2) AS month, COUNT(*) AS sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY (SUBSTR(CAST(o.order_purchase_timestamp AS TEXT), 6, 2))
ORDER BY month ASC;