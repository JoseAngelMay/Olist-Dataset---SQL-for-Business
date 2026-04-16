
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

SELECT * FROM product_category_name_translation;

SELECT pcnt.category_name_en, SUBSTR(CAST(o.order_purchase_timestamp AS TEXT), 6, 2) AS month,
	   SUBSTR(CAST(o.order_purchase_timestamp AS TEXT), 1, 4) AS year, COUNT(p.product_category_name) AS category_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN product_category_name_translation pcnt ON p.product_category_name = pcnt.category_name
GROUP BY (pcnt.category_name_en, SUBSTR(CAST(o.order_purchase_timestamp AS TEXT), 6, 2), SUBSTR(CAST(o.order_purchase_timestamp AS TEXT), 1, 4))
ORDER BY year ASC, month ASC, category_sales DESC;

SELECT * FROM geolocation; -- zip_code_prefix, lat, lng, city, state
SELECT * FROM customers; -- id, zip_code_prefix, city, state
SELECT * FROM products; --product_id
SELECT * FROM order_items; -- order_id, product_id
SELECT * FROM orders; -- order_id, customer_id


SELECT c.id AS customer_id, COUNT(o.customer_id) customer_purchases, g.lat AS latitude, g.lng AS longitude
FROM geolocation g
JOIN customers c ON g.zip_code_prefix = c.zip_code_prefix AND g.state = c.state AND g.city = c.city
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY c.id, g.lat, g.lng
ORDER BY COUNT(o.customer_id) DESC;


SELECT * 
FROM orders
WHERE customer_id = 'fc3d1daec319d62d49bfb5e1f83123e9'; -- fc3d1daec319d62d49bfb5e1f83123e9
