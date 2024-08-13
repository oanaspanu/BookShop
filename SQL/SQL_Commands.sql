--Create a table to store information about publishers.
CREATE TABLE publishers
(
publisher_id NUMBER(3) CONSTRAINT pk_publisher_id PRIMARY KEY,
 publisher_name VARCHAR2(50) NOT NULL,
 location VARCHAR2(50)
);

 

-- Add 'publisher' column to the 'books' table
ALTER TABLE books
ADD publisher NUMBER(3); 

 

--Establish a foreign key relationship between the books and publishers tables, ensuring that each book is associated with a publisher.
ALTER TABLE books
ADD CONSTRAINT fk_publisher
FOREIGN KEY (publisher) REFERENCES publishers (publisher_id);

 

--Create a table named former_customers with information from customers who have not placed an order in the last 10 years.
CREATE TABLE former_customers AS
SELECT *
FROM customers
WHERE customer_id IN (
 SELECT DISTINCT customer
 FROM orders
 WHERE EXTRACT(YEAR FROM order_date) < EXTRACT(YEAR FROM SYSDATE) - 10
);



--Add a new column 'publication_date' to the books table to store the publication date of each book.
ALTER TABLE books
ADD publication_date DATE;
 


--Drop the table former_customers to remove the historical data about customers who have not placed an order in the last 10 years.
DROP TABLE former_customers;



--Create an index named 'idx_genre' on the genre column of the books table.
CREATE INDEX idx_genre ON books(genre);

  

--Create a view named 'high_stock_books' to display titles and stock quantities of books that have a stock quantity greater than 50.
CREATE VIEW high_stock_books AS
SELECT title, stock_quantity
FROM books
WHERE stock_quantity > 50;



-- Publisher Inserts
INSERT INTO publishers (publisher_id, publisher_name, location)
VALUES (1, 'ABC Publications', 'New York');

INSERT INTO publishers (publisher_id, publisher_name, location)
VALUES (2, 'XYZ Books Ltd', 'London');

INSERT INTO publishers (publisher_id, publisher_name, location)
VALUES (3, 'Sunrise Press', 'Tokyo');

INSERT INTO publishers (publisher_id, publisher_name, location)
VALUES (4, 'City Lights Publishers', 'Paris');

INSERT INTO publishers (publisher_id, publisher_name, location)
VALUES (5, 'Global Publishing House', 'Berlin');

 

-- Increase Price for Fiction Books
UPDATE books
SET price = price * 5
WHERE genre = 'Fiction';

 

-- Delete a Customer
DELETE FROM customers
WHERE customer_id = 102;
 


-- Merge Orders Data
MERGE INTO orders o
USING (
   SELECT customer_id, MAX(order_date) as max_order_date
   FROM orders, customers
   GROUP BY customer_id
) c
ON (o.customer = c.customer_id)
WHEN MATCHED THEN
   UPDATE SET order_date = c.max_order_date;

 

-- Decrease Stock Quantity
UPDATE books b
SET stock_quantity = stock_quantity - 5;

 

-- Delete Order Items Below Average Quantity
DELETE FROM order_items
WHERE quantity <= (SELECT AVG(quantity) FROM order_items);

 

-- Update Customer ID with CASE
UPDATE customers
SET customer_id = CASE WHEN customer_idIS NULL THEN 0 ELSE customer_id END;

 

-- Update a Customer email 
UPDATE customers
SET email = 'new.alice@email.com'
WHERE first_name = 'Alice' AND last_name = 'Smith';

 

-- Delete Order Items for a Customer with JOIN
DELETE FROM order_items
WHERE order_no IN (SELECT order_id FROM orders WHERE customer = 2);

 
-- Select authors with a stock_quantity greater than 40
SELECT author_name, stock_quantity
FROM authors a
JOIN books b ON a.author_id = b.author
WHERE stock_quantity > 40;

 

-- Select orders with order_date after '2022-01-16'
SELECT *
FROM orders
WHERE order_date > TO_DATE('2022-01-16', 'YYYY-MM-DD');

 

-- Select books with a price between 15 and 25
SELECT *
FROM books
WHERE price BETWEEN 15 AND 25;

 

-- Select customers with emails containing 'example'
SELECT *
FROM customers
WHERE email LIKE '%example%';

 


-- Select authors and their books using an outer join
SELECT a.author_name, b.title
FROM authors a
LEFT JOIN books b ON a.author_id = b.author;

 

-- Select the total stock quantity of books by genre
SELECT genre, SUM(stock_quantity) AS total_stock
FROM books
GROUP BY genre;

 

-- Select books and their authors where the author is Spanish or Chinese
SELECT a.author_name, b.title
FROM authors a
JOIN books b ON a.author_id = b.author
WHERE a.nationality IN ('Spanish', 'Chinese');

 

-- Select authors and their book count, ordering by book count descending
SELECT a.author_name, COUNT(b.book_id) AS book_count
FROM authors a
LEFT JOIN books b ON a.author_id = b.author
GROUP BY a.author_name
ORDER BY book_count DESC;

 


-- Select books with a publication date before 2000
SELECT *
FROM books
WHERE EXTRACT(YEAR FROM publication_date) < 2000;

 

-- Select books and their stock quantity, replacing NULL with 0
SELECT title, NVL(stock_quantity, 0) AS stock_quantity
FROM books;

 

-- Select customers and their orders with order dates after '2022-01-16'
SELECT c.first_name, c.last_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer
WHERE o.order_date > TO_DATE('2022-01-16', 'YYYY-MM-DD');

 

-- Categorize books based on their stock quantity
SELECT
  title,
  CASE
    WHEN stock_quantity > 30 THEN 'High Stock'
    WHEN stock_quantity <= 30 AND stock_quantity > 10 THEN 'Medium Stock'
    ELSE 'Low Stock'
  END AS stock_status
FROM books;

 

-- Find books without orders
SELECT title FROM books
MINUS
SELECT DISTINCT b.title FROM books b JOIN order_items oi ON b.book_id = oi.book;

 

-- Find customers who ordered a specific book
SELECT first_name, last_name
FROM customers
WHERE customer_id IN (SELECT customer FROM orders WHERE order_id IN (SELECT order_no FROM order_items WHERE book = 1));

 

-- Update stock_quantity and select updated books
UPDATE books SET stock_quantity = 50 WHERE book_id = 2;
SELECT * FROM books WHERE book_id = 2;

 

-- Replace NULL publication_date with a default date
SELECT
  title,
  NVL(TO_CHAR(publication_date, 'DD-MON-YYYY'), 'Not Available') AS formatted_pub_date
FROM books;

 

-- Hierarchy Query for Customers
SELECT
  customer_id,
  first_name || ' ' || last_name AS customer_name,
  supervisor_id,
  LEVEL AS hierarchy_level
FROM
  customers
START WITH supervisor_id IS NULL
CONNECT BY PRIOR customer_id = supervisor_id
ORDER SIBLINGS BY customer_id;