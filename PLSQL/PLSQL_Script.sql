CREATE TABLE authors
(
 author_id NUMBER(3) CONSTRAINT pk_author_id PRIMARY KEY,
 author_name VARCHAR2(20) NOT NULL,
 nationality VARCHAR2(10) 
);

CREATE TABLE publishers
(
 publisher_id NUMBER(3) CONSTRAINT pk_publisher_id PRIMARY KEY,
 publisher_name VARCHAR2(50) NOT NULL,
 publisher_location VARCHAR2(50)
);

CREATE TABLE books
(
 book_id NUMBER(3) CONSTRAINT pk_book_id PRIMARY KEY,
 author NUMBER(3) REFERENCES authors (author_id),
 publisher NUMBER(3) REFERENCES publishers (publisher_id),
 title VARCHAR2(30) NOT NULL,
 genre VARCHAR2(20),
 stock_quantity NUMBER(3),
 price NUMBER(3),
 publication_date DATE
 );

CREATE TABLE customers
(
 customer_id NUMBER(3) CONSTRAINT pk_customer_id PRIMARY KEY,
 supervisor_id NUMBER(3) REFERENCES customers (customer_id),
 first_name VARCHAR2(20) NOT NULL,
 last_name VARCHAR2(20) NOT NULL,
 email VARCHAR2(30) CONSTRAINT email UNIQUE,
 phone VARCHAR2(12) CONSTRAINT phone UNIQUE,
 address VARCHAR2(30)
);

CREATE TABLE orders
(
 order_id NUMBER(3) CONSTRAINT pk_order_id PRIMARY KEY,
 customer NUMBER(3) REFERENCES customers (customer_id),
 order_date DATE
);

CREATE TABLE order_items
(
 order_item_id NUMBER(3) CONSTRAINT pk_order_item_id PRIMARY KEY,
 order_no NUMBER(3) REFERENCES orders (order_id),
 book NUMBER(3) REFERENCES books (book_id),
 quantity NUMBER(3)
);
