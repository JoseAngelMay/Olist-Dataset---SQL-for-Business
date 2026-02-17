


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

CREATE TABLE geolocation AS
	SELECT zip_code_prefix, 
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lat) AS lat, 
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lng) AS lng, 
	city, state
	FROM geolocation_draft
	GROUP BY (zip_code_prefix, city, state);

SELECT * FROM geolocation; -- rows have reduced from 1000163 to 19571

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
); -- 169 unique combinations

SELECT city, state FROM customers_draft
WHERE (zip_code_prefix, city, state) NOT IN(
SELECT zip_code_prefix, city, state
FROM geolocation
)
ORDER BY zip_code_prefix DESC, city, state;

SELECT COUNT(*) FROM customers_draft
WHERE id IS NULL OR unique_id IS NULL OR city is NULL OR state is NULL or zip_code_prefix is NULL; -- count of 0 null values

SELECT * FROM customers_draft
WHERE city <> trim(city) OR city <> lower(city) OR state <> trim(state); -- zero rows returned

SELECT zip_code_prefix, city, state FROM customers_draft
WHERE NOT EXISTS(
	SELECT customers_draft.zip_code_prefix, customers_draft.city, customers_draft.state
	FROM geolocation JOIN customers_draft
	ON customers_draft.zip_code_prefix = geolocation.zip_code_prefix
	AND customers_draft.state = geolocation.state
	AND customers_draft.city = geolocation.city
)

