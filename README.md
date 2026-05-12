# Olist-Dataset---SQL-for-Business

## Overview
The Olist dataset (which can be found at https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) is a dataset that involves several tables that relate to data from Brazilian sales, including the tables (and corresponding features) in:

- customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
- geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
- order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
- order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
- order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
- orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
- products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
- sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
- product_category_name_translation_draft (category_name, category_name_en)

This data went through two processes:
- an initial preprocessing stage involving data cleaning, standardizing, and imputing
- an analytical side that allows for visualizations and insights

## Goal
There is a heap of information that can be queried, and the endeavor of this project is to extract insights that would help stakeholders make decisions. My goals include to find trends, such as what time of year is best and worst for each product, are there areas that make more orders or purchase more items based on coordinates, and other insights. 

## Preprocessing
There were several types of issues with the tables, including inconsistent names, duplicates, or just being completely missing. Each issue had a distinct way of being addressed. Some methods include using:
- the UNACCENT extension to use only typical alphanumerical characters
- UPDATE ... WHERE ... or UPDATE ... WHERE ... LIKE ... to find similar strings to standardize inconsistent spellings
- median values where missing or where there where duplicates, using foreign tables when necessary
- temporary tables in case of mass imputation
- constraints, including NOT NULL and UNIQUE, to ensure foreign key validity

## Tableau
Link to Tableau visuals are in the https://public.tableau.com/app/profile/jose.hernandez3784/viz/CategorySalesByMonthOlist/Sheet1#1 link.
