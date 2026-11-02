-- ============================================================
-- SESSION 1: SQL BASICS (PostgreSQL) - shop database
-- Tables: customers, products, orders
-- ============================================================

-- Drop tables if they exist (child "orders" listed too; CASCADE removes dependents) so script is re-runnable
DROP TABLE IF EXISTS orders, products, customers CASCADE;


-- DDL (Data Definition Language): define table structure
CREATE TABLE customers(
	customer_id  SERIAL PRIMARY KEY,		-- auto-increment unique id
	name 		 VARCHAR(50) NOT NULL,		-- required text, max 50 chars
	city		 VARCHAR(30),				-- optional (may be NULL)
	signup_date  DATE						-- date only
);

CREATE TABLE products(
product_id		SERIAL PRIMARY KEY,				-- auto-increment id
product_name	VARCHAR(50) NOT NULL UNIQUE,	-- required and no duplicates
category		VARCHAR(30),
price			NUMERIC(10, 2) CHECK (price > 0)	-- exact decimal, must be positive
);

CREATE TABLE orders(
order_id		SERIAL PRIMARY KEY,
customer_id		INT REFERENCES customers(customer_id),	-- foreign key: must be an existing customer
product_id		INT REFERENCES products(product_id),	-- foreign key: must be an existing product
quantity		INT DEFAULT 1 CHECK (quantity > 0),		-- defaults to 1 if omitted; must be > 0
order_date		DATE NOT NULL,
status			VARCHAR(20)									 -- 'Delivered','Cancelled', 'Returned'
);



-- ALTER : change a table that already exists (commented out = reference examples)

-- ALTER TABLE customers ADD COLUMN email VARCHAR(100);			-- ADD A COLUMN
-- ALTER TABLE customers RENAME COLUMN email TO email_id;			-- rename it
-- ALTER TABLE customers ALTER COLUMN email_id TYPE VARCHAR(150);	-- CHANGE ITS TYPE
-- ALTER TABLE customers ADD CONSTRAINT uq_email UNIQUE (email_id) -- add a rule
-- ALTER TABLE customers DROP COLUMN email_id						-- remove it (the rule goes too)





-- Schemas are folders for tables: create one, put a table in it, then drop the whole schema
-- CREATE SCHEMA IF NOT EXISTS reports;
-- CREATE TABLE IF NOT EXISTS reports.demo  (id INT);
-- DROP SCHEMA reports CASCADE;



-- DROP TABLE deletes the whole table.
-- TRUNCATE keeps the table but empties all rows instantly.
-- DELETE removes chosen rows


-- DML: INSERT adds rows; column list on top, one tuple per row
INSERT INTO customers (name, city, signup_date) VALUES
('Aarav Mehta',    'Gurugram',  '2025-01-05'),
('Priya Sharma',   'Delhi',     '2025-01-18'),
('Rohit Verma',    'Noida',     '2025-02-02'),
('Sneha Kapoor',   'Gurugram',  '2025-02-20'),
('Vikram Singh',   'Delhi',     '2025-03-11'),
('Ananya Gupta',   ' mumbai ',  '2025-03-25'),   -- messy on purpose (cleaned in Section 21)
('Karan Malhotra', NULL,        '2025-04-08'),   -- missing city on purpose
('Isha Reddy',     'Bengaluru', '2025-04-22');






INSERT INTO products (product_name, category, price) VALUES
('Laptop',       'Electronics', 55000),
('Headphones',   'Electronics',  2500),
('Office Chair', 'Furniture',    8000),
('Desk Lamp',    'Furniture',    1200),
('Python Book',  'Books',         650),
('SQL Book',     'Books',         550);


-- customer_id and product_id values point to rows inserted above (foreign keys)
INSERT INTO orders (customer_id, product_id, quantity , order_date, status) VALUES
(4 , 5, 10 , '2026-01-19' , 'Delivered' ),
(1, 2, 2, '2025-02-14', 'Delivered'),
(2, 5, 3, '2025-01-25', 'Delivered'),
(2, 3, 1, '2025-03-02', 'Cancelled'),
(3, 2, 1, '2025-02-10', 'Delivered'),
(3, 6, 2, '2025-03-15', 'Delivered'),
(4, 4, 2, '2025-03-01', 'Delivered'),
(4, 1, 1, '2025-04-05', 'Returned'),
(5, 3, 2, '2025-03-20', 'Delivered'),
(5, 5, 1, '2025-04-12', 'Delivered'),
(6, 2, 1, '2025-04-02', 'Delivered'),
(6, 6, 4, '2025-05-06', 'Delivered'),
(1, 4, 1, '2025-05-10', 'Delivered'),
(8, 1, 1, '2025-05-18', 'Delivered'),
(2, 2, 1, '2025-05-21', 'Delivered');



-- ---------- reading data (SELECT) ----------
SELECT * FROM orders;						-- * means "all columns"

SELECT  order_date, status FROM orders;		-- only the columns you need


SELECT DISTINCT city FROM customers;		-- UNIQUE VALUES, NO REPEAT


-- Calculated columns with aliases (AS) - first draft, unrounded
-- SELECT
-- 	product_name,
-- 	price ,
-- 	price * 0.18  AS  gst ,
-- 	price * 1.18 AS price_with_gst
-- from products;


-- Same, rounded to 2 decimals using the :: cast operator
-- SELECT
-- 	product_name,
-- 	price ,
-- 	(price * 0.18)::NUMERIC(10,2)  AS  gst ,
-- 	(price * 1.18)::NUMERIC(10,2) AS price_with_gst
-- from products;


-- Final version: :: and CAST(... AS type) are two equal ways to convert a type
SELECT
	product_name,
	price ,
	(price * 0.18)::NUMERIC(10,2)  AS  gst ,
	CAST(price * 1.18 AS NUMERIC(10,2)) AS price_with_gst
from products;



-- ---------- filtering rows (WHERE) ----------
SELECT * FROM products WHERE price > 2000;		-- comparison operator

SELECT * FROM customers WHERE city = 'Delhi' OR city = 'Noida';	-- OR: either condition
SELECT * FROM customers WHERE city IN ('Delhi' , 'Noida');		-- IN: shorter form of the OR above
SELECT * FROM customers WHERE city NOT IN ('Delhi' , 'Noida');	-- NOT IN: excludes the list (NULL cities are also dropped)


-- BETWEEN is inclusive of both ends; AND needs both conditions true
SELECT * FROM orders
WHERE order_date BETWEEN '2025-03-01' AND '2025-05-31'  AND status = 'Delivered';


-- Brackets control precedence: AND binds tighter than OR, so group the OR explicitly
SELECT * FROM orders
WHERE status = 'Delivered' AND ( quantity >= 3 OR order_date >= '2025-03-01' );


-- Pattern matching: % = any number of characters. LIKE is case-sensitive, ILIKE ignores case
SELECT * FROM customers WHERE name LIKE 'A%'; -- starts with A
SELECT * FROM customers WHERE name LIKE '%A'; -- ends with A
SELECT * FROM customers WHERE name ILIKE '%A'; -- ends with A / a
SELECT * FROM customers WHERE name ILIKE '%A%'; -- contains a / A
SELECT * FROM customers WHERE name ILIKE '%k%'; -- contains k / K



-- ---------- sorting and limiting ----------
SELECT product_name, price FROM products ORDER BY price; -- ascending (default)

SELECT product_name, price FROM products ORDER BY price DESC; -- descending


SELECT name, city FROM customers
ORDER BY city ASC NULLS LAST , name DESC; -- sort by city, then name, blank at the end

-- top 2 most expensive products (LIMIT caps the number of rows returned)

SELECT product_name, price FROM products
ORDER BY price DESC
LIMIT 2;

-- SKIP 1 AND  take next 2 (OFFSET skips rows first; used for pagination)

SELECT product_name, price FROM products
ORDER BY price DESC
LIMIT 2 OFFSET 1;



-- ---------- UPDATE: change existing rows (always use WHERE!) ----------
SELECT * FROM products WHERE product_name = 'SQL Book';	-- before

UPDATE  products SET price = 599 WHERE product_name = 'SQL Book';
SELECT * FROM products WHERE product_name = 'SQL Book';	-- after


UPDATE  products SET price = 550 WHERE product_name = 'SQL Book';	-- restore the original price
SELECT * FROM products WHERE product_name = 'SQL Book';


-- ---------- Transactions: group statements, then keep or undo them ----------
BEGIN;
	DELETE FROM orders WHERE status = 'Delivered'; -- temp delete
	SELECT COUNT(*) FROM orders; -- check remaining row count
ROLLBACK; -- undo everything since BEGIN



BEGIN;
	DELETE FROM orders WHERE status = 'Returned'; -- temp delete
	SELECT COUNT(*) FROM orders; -- check remaining row count
COMMIT; -- make the changes permanent (Returned orders are now really gone)


SELECT COUNT(*) FROM orders WHERE status = 'Delivered';	-- still there thanks to the ROLLBACK


SELECT * FROM orders;









-- ---------- Aggregate functions: collapse many rows into one ----------
SELECT
	COUNT(*) 						AS total_orders,	-- number of rows
	COUNT(DISTINCT customer_id) 	AS unique_buyers,	-- distinct customers
	SUM(quantity)					AS units_sold,		-- total
	ROUND(AVG(quantity) , 2)		AS avg_qty,			-- average rounded to 2 decimals
	MIN(order_date)					AS first_order,		-- earliest
	MAX(order_date)					AS last_order		-- latest
FROM orders;




-- ---------- GROUP BY: one result row per group ----------
--  customers per city
SELECT city, COUNT(*) AS customers_count
FROM customers
GROUP BY city
ORDER BY customers_count DESC;




-- Orders and units per status
SELECT status, COUNT(*) as orders, SUM(quantity) AS units
FROM orders
GROUP BY status;


-- group by two columns; order per customer per status


SELECT customer_id, status, count(*) as orders
from orders
GROUP BY customer_id, status
order by customer_id;


-- HAVING filters groups after aggregation (WHERE filters rows before it): customers with 2+ orders

select customer_id, count(*) as orders_count
from orders
group by customer_id
having count(*) >= 2
order by orders_count desc;



-- ---------- JOINS: combine tables using a matching column ----------
-- inner join : only rows that match on both side
SELECT * FROM orders;






SELECT
c.customer_id,
c.name,
o.order_id,
o.quantity
FROM orders as o -- left
JOIN customers as c -- right
	ON c.customer_id = o.customer_id	-- the matching rule (FK = PK)
order by c.customer_id;



-- each order with customer name, product and revenue (3-table join)
SELECT
	o.order_id,
	c.name,
	p.product_name,
	o.quantity,
	o.quantity * p.price AS revenue		-- computed from two tables
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = o.product_id
ORDER BY o.order_id;


-- revenue by category (DELIVERED ONLY): join, filter, then group + sum

SELECT
	p.category,
	SUM(o.quantity * p.price)  AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY revenue DESC;



 -- left join : all rows of left table , and matching from right ( if doesnt match shows null)

SELECT
	c.customer_id,
	c.name,
	o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id;

select * from customers;

-- every customer and their order count( 0 if none)
-- COUNT(o.order_id) ignores NULLs, so customers without orders get 0 (COUNT(*) would give 1)

SELECT
	c.name,
	count(o.order_id) AS orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY  c.name
ORDER BY orders DESC;

-- anti-join: LEFT JOIN + IS NULL finds customers who never ordered

SELECT
	c.name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- DELETE FROM customers
-- where customer_id = 5;
-- select * from orders

-- self join : join a table to itself (two aliases). pairs of customers in the same city
-- a.customer_id < b.customer_id avoids pairing someone with themselves and duplicate mirrored pairs

SELECT
	a.name as customer_1,
	b.name as customer_2 ,
	a.city
from customers a
join customers b on a.city = b.city
AND a.customer_id < b.customer_id;


-- self join on orders: pairs of order rows that share the same product
-- (includes each row paired with itself, since there is no < filter)
select
	o1.customer_id as customer_1,
	o2.customer_id as customer_2,
	o1.product_id
from orders o1
join orders o2 on o1.product_id = o2.product_id



-- ---------- SET OPERATIONS: combine results of two queries (same column count/types) ----------
-- UNION: customers who bought Books OR Electronics
SELECT
	customer_id
from orders
join products using (product_id)	-- USING: join on a same-named column
where category = 'Books'
union -- removes duplicates
SELECT
	customer_id
from orders
join products using (product_id)
where category = 'Electronics';



SELECT
	customer_id
from orders
join products using (product_id)
where category = 'Books'
union all -- keeps duplicates
SELECT
	customer_id
from orders
join products using (product_id)
where category = 'Electronics'
order by customer_id;



-- bought books and electronics
-- INTERSECT: only rows present in both results
SELECT
	customer_id
from orders
join products using (product_id)
where category = 'Books'
intersect
SELECT
	customer_id
from orders
join products using (product_id)
where category = 'Electronics';



-- bought electronics but never books
-- EXCEPT: rows in the first result that are missing from the second
SELECT
	customer_id
from orders
join products using (product_id)
where category = 'Electronics'
except
SELECT
	customer_id
from orders
join products using (product_id)
where category = 'Books';



-- ---------- CASE: if / else logic inside SQL ----------
-- searched CASE: conditions checked top to bottom, first match wins
select product_name, price,
	case
		when price >= 10000 then 'Premium'
		when price >= 1000 then 'Mid Range'
		else 'Budget'
	end as price_range
from products;


-- simple CASE: compares one column against exact values
select
	order_id,
	status,
	case status
		when 'Delivered' then 'Done'
		When 'Returned' then 'Came Back'
		when 'Cancelled' then  'XXXXX'
		else 'Unknown'
	end  as  status_label
from orders;


-- CASE inside GROUP BY: first attempt grouping by the alias
-- select
-- 	case when quantity >= 2 then 'Bulk (2+)' else 'Single item' end as order_type,
-- 	count(*) as orders
-- from orders
-- group by order_type;
-- Same query; GROUP BY 1 means "group by the 1st selected column"
select
	case when quantity >= 2 then 'Bulk (2+)' else 'Single item' end as order_type,
	count(*) as orders
from orders
group by 1;



-- CASE in ORDER BY: custom sort order (Delivered, then Returned, then everything else)
select order_id, status
from orders
order by
	case status
		when 'Delivered' then 1
		when 'Returned' then 2
		else 3 end,
order_id;	-- tie-breaker


-- Same custom sort, but the rank is also shown as a column and sorted by its alias
select
	order_id,
	status,
	case status
		when  'Delivered' then 1
		when 'Returned' then 2
		else 3 end as status_no
from orders
order by status_no;
