





DROP SCHEMA public CASCADE;
CREATE SCHEMA public;


CREATE TABLE geolocation_draft (
  zip_code_prefix TEXT,
  lat DECIMAL(17, 14),
  lng DECIMAL(17, 14),
  city TEXT,
  state TEXT
);

SELECT * FROM geolocation_draft; -- manually inspecting reveals discrepancies beteween how 'sao paulo' has been written with and without and accent
								 -- but this likely extends beyond that city name

CREATE EXTENSION IF NOT EXISTS unaccent; -- to use postgresql's item to get rid of accents

UPDATE geolocation_draft
SET city = UNACCENT(city);

SELECT DISTINCT(city) 
FROM geolocation_draft
WHERE city LIKE 's_o paulo'; -- this returns a single item, suggesting only 'sao paulo' 

SELECT DISTINCT(city) 
FROM geolocation_draft
WHERE city LIKE ANY (ARRAY[
	'%.%',
	'%,%',
	'%''%'
]); -- outputs 54 rows, with one item having an elipse, some items being similar but with a single space difference


SELECT DISTINCT(city) FROM geolocation_draft
WHERE city LIKE '%arraial%'; -- output suggests repetition, to be cleaned

SELECT DISTINCT(city) FROM geolocation_draft
WHERE city LIKE '%arraial%ajuda';

UPDATE geolocation_draft
SET city = 'arraial do cabo'
WHERE city = '...arraial do cabo';

UPDATE geolocation_draft
SET city = 'arraial d ajuda'
WHERE city LIKE '%arraial%ajuda';

UPDATE geolocation_draft
SET city = REPLACE(city, '''', ' '); -- at this point, a lot of repetition has been reduced checking wtih former query extraction

SELECT DISTINCT(city)
FROM geolocation_draft
WHERE city LIKE '4%';

UPDATE geolocation_draft
SET city = '4o centenario'
WHERE city = '4o. centenario';

UPDATE geolocation_draft
SET city = 'campo alegre de lourdes'
WHERE city = 'campo alegre de lourdes, bahia, brasil';

UPDATE geolocation_draft
SET city = 'rio de janeiro'
WHERE city = 'rio de janeiro, rio de janeiro, brasil';


SELECT DISTINCT(city) 
FROM geolocation_draft
WHERE city LIKE ANY (ARRAY[
	'%.%',
	'%,%',
	'%''%'
]); -- now does not have any row output

SELECT DISTINCT(city)
FROM geolocation_draft
ORDER BY city; -- first item outputs suggest oddities, will address manually

UPDATE geolocation_draft
SET city = 'cidade'
WHERE city = '* cidade';

UPDATE geolocation_draft
SET city = 'teresopolis'
WHERE city = '´teresopolis';

SELECT DISTINCT(state)
FROM geolocation_draft; -- all 27 itemse are of length two

SELECT city
FROM geolocation_draft
WHERE city <> lower(city); -- outputs no rows, suggesting lowercase throughout

SELECT city
FROM geolocation_draft
WHERE city <> trim(city); -- outputs no rows

SELECT DISTINCT(city)
FROM geolocation_draft
WHERE city LIKE '% %'; -- outputs 2907 rows

SELECT DISTINCT(city)
FROM geolocation_draft
WHERE city LIKE '%  %'; -- outputs 6, suggesting double space inputs

UPDATE geolocation_draft
SET city = REPLACE(city, '  ', ' ');

SELECT DISTINCT(city)
FROM geolocation_draft
WHERE city LIKE '%  %'; -- now outputs 0 rows

SELECT DISTINCT(city)
FROM geolocation_draft
WHERE city LIKE '%   %'; -- outputs 0 rows for triple-spacing

SELECT * FROM geolocation_draft;

SELECT COUNT(*) = COUNT(DISTINCT zip_code_prefix) AS zip_code_prefix_validity_pk
FROM geolocation_draft; -- false, suggesting repetition

SELECT COUNT(*) = COUNT(zip_code_prefix IS NOT NULL) AS not_null
FROM geolocation_draft; -- all rows of zip_code_prefix have value, though

SELECT * FROM geolocation_draft
WHERE zip_code_prefix IS NULL OR 
      city IS NULL OR 
	  state IS NULL OR 
	  lat IS NULL OR 
	  lng IS NULL; -- table is full throughout, no rows returned

SELECT zip_code_prefix,
AVG(lat) AS average_latitude,
AVG(lng) AS average_longitude,
STDDEV(lat) AS std_dev_latitude,
STDDEV(lng) AS std_dev_longitude
FROM geolocation_draft
GROUP BY zip_code_prefix
HAVING STDDEV(lat) IS NOT NULL AND STDDEV(lng) IS NOT NULL
ORDER BY std_dev_latitude DESC, std_dev_longitude DESC; -- shows zip code coordinate averages and standard deviations, decreasing from highest deviance

SELECT * FROM geolocation_draft
WHERE zip_code_prefix IN ('68379', '57319', '46560', '28165', '28155', 
                          '29654', '83810', '58441', '68275', '47310', 
						  '28333', '28595', '68447', '68985', '57255', 
						  '14915', '39812', '55618', '28510', '45936')
ORDER BY zip_code_prefix; -- some of these suggest parentheses inclusion

SELECT * FROM geolocation_draft
WHERE city LIKE '%(%' OR city LIKE '%)%';

UPDATE geolocation_draft
SET city = 'penedo'
WHERE city = 'penedo (itatiaia)';

UPDATE geolocation_draft
SET city = 'california da barra'
WHERE city = 'california da barra (barra do pirai)';

UPDATE geolocation_draft
SET city = 'tamoios'
WHERE city = 'tamoios (cabo frio)';

UPDATE geolocation_draft
SET city = 'itabatan'
WHERE city = 'itabatan (mucuri)';

UPDATE geolocation_draft
SET city = 'jacare'
WHERE city = 'jacare (cabreuva)';

UPDATE geolocation_draft
SET city = 'bacaxa'
WHERE city = 'bacaxa (saquarema) - distrito';

UPDATE geolocation_draft
SET city = 'antunes'
WHERE city = 'antunes (igaratinga)';

UPDATE geolocation_draft
SET city = 'monte gordo'
WHERE city = 'monte gordo (camacari) - distrito';

UPDATE geolocation_draft
SET city = 'praia grande'
WHERE city = 'praia grande (fundao) - distrito';

UPDATE geolocation_draft
SET city = 'realeza'
WHERE city = 'realeza (manhuacu)';

SELECT zip_code_prefix, 
AVG(lat) AS average_latitude,
AVG(lng) AS average_longitude,
STDDEV(lat) AS std_dev_latitude,
STDDEV(lng) AS std_dev_longitude
FROM geolocation_draft
GROUP BY zip_code_prefix
HAVING STDDEV(lat) >1 OR STDDEV(lng) > 1
ORDER BY std_dev_latitude DESC, std_dev_longitude DESC; -- 143 zip codes where at least 
                                                        -- one coordinate has standard deviation at least a value of 1

SELECT * FROM geolocation_draft 
WHERE zip_code_prefix IN (
	SELECT zip_code_prefix
	FROM geolocation_draft
	GROUP BY zip_code_prefix
	HAVING STDDEV(lat) >1 OR STDDEV(lng) > 1
)
ORDER BY zip_code_prefix DESC, city;

SELECT zip_code_prefix, city, state,
AVG(lat) AS avg_lat,
AVG(lng) AS avg_lng,
STDDEV(lat) AS std_lat,
STDDEV(lng) AS std_lng
FROM geolocation_draft
GROUP BY(zip_code_prefix, city, state)
HAVING STDDEV(lat) > 1 OR STDDEV(lng) > 1
ORDER BY std_lat DESC, std_lng DESC; -- 137 rows where at least one coordinate has standard 
                                     -- deviation at least a value of 1 when grouped by zip code, city, state

SELECT zip_code_prefix, city, state, lat, lng
FROM  geolocation_draft
WHERE (zip_code_prefix, city, state) IN (
	SELECT zip_code_prefix, city, state
	FROM geolocation_draft
	GROUP BY(zip_code_prefix, city, state)
	HAVING STDDEV(lat) > 1 OR STDDEV(lng) > 1
)
ORDER BY zip_code_prefix, city, state, lat ASC, lng ASC;

SELECT zip_code_prefix, city, state,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lat),
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lng)
FROM geolocation_draft
GROUP BY (zip_code_prefix, city, state)
HAVING STDDEV(lat) > 1 OR STDDEV(lng) > 1;

SELECT zip_code_prefix, city, state,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lat) AS median_lat,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lng) AS median_lng
FROM geolocation_draft
GROUP BY (zip_code_prefix, city, state);

SELECT COUNT(DISTINCT(zip_code_prefix, city, state))
FROM geolocation_draft;

SELECT COUNT(*)
FROM geolocation_draft;

CREATE TABLE geolocation AS
	SELECT zip_code_prefix, 
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lat) AS lat, 
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lng) AS lng, 
	city, state
	FROM geolocation_draft
	GROUP BY (zip_code_prefix, city, state);

SELECT * FROM geolocation; -- rows have reduced from 1000163 to 19571

SELECT COUNT(*) = COUNT(DISTINCT(zip_code_prefix, city, state))
FROM geolocation; -- validity of primary key using these three attributes

ALTER TABLE geolocation
ADD CONSTRAINT geo_pk PRIMARY KEY(zip_code_prefix, city, state);



CREATE TABLE customers_draft (
  id TEXT,
  unique_id TEXT,
  zip_code_prefix TEXT,
  city TEXT,
  state TEXT
);

SELECT * FROM customers_draft;

SELECT * FROM customers_draft
WHERE city LIKE ANY (ARRAY[
	'%,%',
	'%(%',
	'%)%',
	'%.%',
	'%%''%%'
]); -- a majority of presented cases suggest presence of apostrophe values

UPDATE customers_draft
SET city = REPLACE(city, '''', ' '); -- upon running former query, 0 rows are output

SELECT zip_code_prefix, city, state FROM customers_draft
WHERE (zip_code_prefix, city, state) NOT IN(
SELECT zip_code_prefix, city, state
FROM geolocation
)
ORDER BY zip_code_prefix DESC, city, state; -- gets zip code, city, state combinations not in geolocation that are in customers
-- 302 rows

SELECT COUNT(DISTINCT(zip_code_prefix, city, state)) FROM customers_draft
WHERE (zip_code_prefix, city, state) NOT IN(
SELECT zip_code_prefix, city, state
FROM geolocation
); -- 169 unique zip code, city, state combinations for what is in customers_draft but not in geolocation

SELECT DISTINCT zip_code_prefix, city, state FROM customers_draft
WHERE (zip_code_prefix, city, state) NOT IN(
SELECT zip_code_prefix, city, state
FROM geolocation
)
ORDER BY zip_code_prefix, city, state; -- shows the 169 unique combinations just mentioned

SELECT COUNT(*) FROM customers_draft
WHERE id IS NULL OR unique_id IS NULL OR city is NULL OR state is NULL or zip_code_prefix is NULL; -- count of 0 null values
-- in customers_draft

SELECT * FROM customers_draft
WHERE city <> trim(city) OR city <> lower(city) OR state <> trim(state); -- zero rows returned
-- indicating standardized data in terms of formatting

SELECT city, state,
       PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lat) AS median_lat,
       PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lng) AS median_lng
FROM geolocation
WHERE (city, state) IN(
	SELECT city, state FROM customers_draft
	WHERE (zip_code_prefix, city, state) NOT IN(
	SELECT zip_code_prefix, city, state
	FROM geolocation
	)
)
GROUP BY (city, state)
ORDER BY city, state; -- imputes values for missing values in geolocation using median of available city, state combinations
-- however, not all cities in customers are in geolocation, so this is incomplete


SELECT zip_code_prefix, city, state FROM customers_draft
WHERE (zip_code_prefix) NOT IN (
	SELECT DISTINCT zip_code_prefix FROM geolocation
)
ORDER BY zip_code_prefix, city, state; -- 278 rows for zip codes in customers_draft not in geolocation

SELECT DISTINCT zip_code_prefix, city, state FROM customers_draft
WHERE (zip_code_prefix) NOT IN (
	SELECT DISTINCT zip_code_prefix FROM geolocation
)
ORDER BY zip_code_prefix, city, state; -- 157 rows for distinct zip codes in customers_draft not in geolocation

SELECT zip_code_prefix, city, state FROM customers_draft
WHERE (state) NOT IN (
	SELECT DISTINCT state FROM geolocation
)
ORDER BY zip_code_prefix, city, state; -- 0 rows for customers_draft states not in geolocation

SELECT zip_code_prefix, city, state FROM customers_draft
WHERE (city) NOT IN (
	SELECT DISTINCT city FROM geolocation
)
ORDER BY zip_code_prefix, city, state; -- 66 rows for cities in customers_draft not in geolocation

SELECT DISTINCT zip_code_prefix, city, state FROM customers_draft
WHERE (city) NOT IN (
	SELECT DISTINCT city FROM geolocation
)
ORDER BY zip_code_prefix, city, state; -- 50 rows for distinct zip code, city, state combinations in customers_draft not in geolocation

SELECT * FROM customers_draft
WHERE zip_code_prefix NOT IN (
	SELECT zip_code_prefix
	FROM geolocation) 
AND city NOT IN (	
	SELECT city
	FROM geolocation); -- 49 rows
-- meaning for 49 entries both the zip code and city
-- are in customers_draft but not in geolocation

SELECT zip_code_prefix, city, state,
CASE
	WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.city = c.city AND g.state = c.state) THEN 'full'
	WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.city = c.city AND g.state = c.state) THEN 'not_zip_code'
	WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.state = c.state) THEN 'not_city'
	WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.city = c.city) THEN 'not_state'
	WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix) THEN 'zip_code'
	WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.city = c.city) THEN 'city'
	WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.state = c.state) THEN 'state'
	ELSE 'none'
END AS geo_count
FROM customers_draft c
ORDER BY geo_count;

CREATE TEMP TABLE customers_location AS
	SELECT DISTINCT c.zip_code_prefix, c.city, c.state, 
	CASE
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.city = c.city AND g.state = c.state)
	    	THEN g.lat
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.city = c.city AND g.state = c.state)
	    	THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lat) AS median_lat FROM geolocation g WHERE c.city = g.city AND c.state = g.state)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.state = c.state)
  		  	THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lat) AS median_lat FROM geolocation g WHERE c.zip_code_prefix = g.zip_code_prefix AND c.state = g.state)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.city = c.city)
    		THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lat) AS median_lat FROM geolocation g WHERE c.zip_code_prefix = g.zip_code_prefix AND c.city = g.city)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix) 
    		THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lat) AS median_lat FROM geolocation g WHERE c.zip_code_prefix = g.zip_code_prefix)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.city = c.city)
    		THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lat) AS median_lat FROM geolocation g WHERE c.city = g.city)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.state = c.state)
    		THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lat) AS median_lat FROM geolocation g WHERE c.state = g.state)
		ELSE NULL
	END AS lat,
	CASE
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.city = c.city AND g.state = c.state)
	    	THEN g.lng
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.city = c.city AND g.state = c.state)
	    	THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lng) AS median_lng FROM geolocation g WHERE c.city = g.city AND c.state = g.state)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.state = c.state)
   		 	THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lng) AS median_lng FROM geolocation g WHERE c.zip_code_prefix = g.zip_code_prefix AND c.state = g.state)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix AND g.city = c.city)
    		THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lng) AS median_lng FROM geolocation g WHERE c.zip_code_prefix = g.zip_code_prefix AND c.city = g.city)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.zip_code_prefix = c.zip_code_prefix) 
    		THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lng) AS median_lng FROM geolocation g WHERE c.zip_code_prefix = g.zip_code_prefix)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.city = c.city)
    		THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lng) AS median_lng FROM geolocation g WHERE c.city = g.city)
		WHEN EXISTS (SELECT 1 FROM geolocation g WHERE g.state = c.state)
    		THEN (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY lng) AS median_lng FROM geolocation g WHERE c.state = g.state)
		ELSE NULL
	END AS lng
	FROM customers_draft c
	LEFT JOIN geolocation g ON g.zip_code_prefix = c.zip_code_prefix AND g.city = c.city AND g.state = c.state
	WHERE (c.zip_code_prefix, c.city, c.state) NOT IN (SELECT zip_code_prefix, city, state FROM geolocation);

ALTER TABLE geolocation ADD COLUMN origin TEXT;
UPDATE geolocation
SET origin = 'original';

INSERT INTO geolocation (zip_code_prefix, city, state, lat, lng, origin)
SELECT zip_code_prefix, city, state, lat, lng, 'synthetic'
FROM customers_location;

DROP TABLE customers_location;

ALTER TABLE customers_draft RENAME TO customers;

SELECT COUNT(DISTINCT id) AS id_count, COUNT(DISTINCT unique_id) AS unique_id_count, COUNT(*) AS row_count
FROM customers; -- id column is the only viable option for a primary key between the two id type columns

ALTER TABLE customers
ADD CONSTRAINT customers_pk PRIMARY KEY(id);

CREATE TABLE order_items_draft (
	order_id TEXT,
	order_item_id BIGINT,
	product_id TEXT,
	seller_id TEXT,
	shipping_limit_date DATE,
	price DECIMAL(50, 2),
	freight_value DECIMAL(25, 2)
);

SELECT * FROM order_items_draft;

SELECT COUNT(*) AS row_count, COUNT(DISTINCT order_id) AS order_id_count
FROM order_items_draft; -- uniqueness constraint not satisfied with solely using order_id column

SELECT COUNT(*) AS row_count, COUNT(DISTINCT (order_id, order_item_id)) AS order_id_order_item_id
FROM order_items_draft; -- equal count of overall rows and combinations of order_id and order_item_id

ALTER TABLE order_items_draft
ADD CONSTRAINT order_items_pk PRIMARY KEY(order_id, order_item_id);

ALTER TABLE order_items_draft RENAME TO order_items;

CREATE TABLE order_payments_draft (
	order_id TEXT,
	payment_sequential BIGINT,
	payment_type TEXT,
	payment_installments DECIMAL(20, 2),
	payment_value DECIMAL(20, 2)
);

SELECT * FROM order_payments_draft;

SELECT COUNT(*) AS row_count, COUNT(DISTINCT order_id) AS distinct_order_id
FROM order_payments_draft; -- not same, suggesting need for additional/alternative columns

SELECT COUNT(*) AS row_count, COUNT(DISTINCT(order_id, payment_sequential)) AS order_id_pay_seq
FROM order_payments_draft; -- equality, suggesting validity as a primary key

ALTER TABLE order_payments_draft RENAME TO order_payments;

ALTER TABLE order_payments
ADD CONSTRAINT order_payments_pk PRIMARY KEY(order_id, payment_sequential);

SELECT * FROM order_payments;

CREATE TABLE order_reviews_draft (
	review_id TEXT,
	order_id TEXT,
	review_score BIGINT,
	review_comment_title TEXT,
	review_comment_message TEXT,
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP
);

SELECT * FROM order_reviews_draft;

SELECT COUNT(DISTINCT review_id) AS review_count, COUNT(*) AS row_count
FROM order_reviews_draft; -- not viable as a primary key due to inequality

SELECT COUNT(DISTINCT(review_id, order_id)) AS review_count, COUNT(*) AS row_count
FROM order_reviews_draft; -- viable as a primary key

ALTER TABLE order_reviews_draft RENAME TO order_reviews;

ALTER TABLE order_reviews
ADD CONSTRAINT order_reviews_pk PRIMARY KEY(review_id, order_id);

CREATE TABLE orders_draft (
	order_id TEXT,
	customer_id TEXT,
	order_status TEXT,
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP
);

SELECT * FROM orders_draft;

SELECT COUNT(*) AS row_count, COUNT(DISTINCT order_id) AS unique_order
FROM orders_draft; -- equivalence, suggesting viability as a primary key

ALTER TABLE orders_draft RENAME TO orders;

ALTER TABLE orders
ADD CONSTRAINT orders_pk PRIMARY KEY(order_id);

SELECT * FROM orders;

CREATE TABLE products_draft (
	product_id TEXT,
	product_category_name TEXT,
	product_name_lenght BIGINT,
	product_description_lenght BIGINT,
	product_photos_qty BIGINT,
	product_weight_g BIGINT,
	product_length_cm BIGINT,
	product_height_cm BIGINT,
	product_width_cm BIGINT
);

SELECT * FROM products_draft;

SELECT COUNT(*) AS row_count, COUNT(DISTINCT product_id) AS unique_product_id
FROM products_draft; -- equivalent counts, suggesting viability as a primary key

ALTER TABLE products_draft RENAME TO products;

ALTER TABLE products
ADD CONSTRAINT products_pk PRIMARY KEY(product_id);

SELECT * FROM products;

CREATE TABLE sellers_draft (
	seller_id TEXT,
	seller_zip_code_prefix TEXT,
	seller_city TEXT,
	seller_state TEXT
);

SELECT * FROM sellers_draft;

SELECT COUNT(*) AS row_count, COUNT(DISTINCT seller_id) AS unique_seller_id
FROM sellers_draft; -- equivalent counts for each, suggesting viability as a primary key

ALTER TABLE sellers_draft RENAME TO sellers;

ALTER TABLE sellers
ADD CONSTRAINT sellers_pk PRIMARY KEY(seller_id);

SELECT * FROM sellers;

CREATE TABLE product_category_name_translation_draft (
	product_category_name TEXT,
	product_category_name_english TEXT
);

SELECT * FROM product_category_name_translation_draft;

SELECT COUNT(*) AS row_count, COUNT(DISTINCT product_category_name) AS unique_prod_cat_name
FROM product_category_name_translation_draft; -- both of same count, validating primary key viability

ALTER TABLE product_category_name_translation_draft RENAME TO product_category_name_translation;

ALTER TABLE product_category_name_translation
ADD CONSTRAINT prod_cat_name_pk PRIMARY KEY(product_category_name);

SELECT * FROM product_category_name_translation;

