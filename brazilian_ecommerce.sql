CREATE TABLE customers (
  customer_id TEXT,
  customer_unique_id TEXT,
  customer_zip_code_prefix CHAR(5),
  customer_city TEXT,
  customer_state CHAR(2)
)

CREATE TABLE geolocation (
  geolocation_zip_code_prefix CHAR(5),
  geolocation_lat DECIMAL(17, 14),
  geolocation_lng DECIMAL(16, 14),
  geolocation_city TEXT,
  geolocation_state CHAR(2)
)

CREATE TABLE order_items (
  order_id TEXT,
  order_item_id TEXT,
  product_id TEXT,
  seller_id TEXT,
  shipping_limit_date TIMESTAMP,
  price DECIMAL(9, 2),
  freight_value DECIMAL(9, 2)
)

CREATE TABLE order_payments (
  order_id TEXT,
  payment_sequential TEXT,
  payment_type VARCHAR(50),
  payment_installments INT,
  payment_value DECIMAL(9, 2)
)

CREATE TABLE order_reviews (
  review_id TEXT,
  order_id TEXT,
  review_score SMALLINT,
  review_comment_title TEXT,
  review_comment_message TEXT,
  review_creation_date TIMESTAMP,
  review_answer_timestamp TIMESTAMP
)

CREATE TABLE orders (
  order_id TEXT,
  customer_id TEXT,
  order_status TEXT,
  order_purchase_timestamp TIMESTAMP,
  order_approved_at TIMESTAMP,
  order_delivered_carrier_date TIMESTAMP,
  order_delivered_customer_date TIMESTAMP,
  order_estimated_delivery_date TIMESTAMP
)

CREATE TABLE products (
  product_id TEXT,
  product_category_name TEXT,
  product_name_lenght SMALLINT,
  product_description_lenght SMALLINT,
  product_photos_qty SMALLINT,
  product_weight_g SMALLINT,
  product_length_cm SMALLINT,
  product_height_cm SMALLINT,
  product_width_cm SMALLINT
)

CREATE TABLE sellers (
  seller_id TEXT,
  seller_zip_code_prefix CHAR(5),
  seller_city TEXT,
  seller_state CHAR(2)
)

CREATE TABLE category_name_translation (
  product_category_name TEXT,
  product_category_name_english TEXT
)