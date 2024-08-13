-- Problem 1: Update the price of all books published before 2020 to increase by 10%.

DECLARE
    v_increase_percentage CONSTANT NUMBER := 0.1;
    v_author_name VARCHAR2(100);
    v_book_author_name VARCHAR2(100);
BEGIN
    FOR book_rec IN (SELECT * FROM books 
    WHERE publication_date < TO_DATE('2020-01-01', 'YYYY-MM-DD'))
    LOOP
        BEGIN
            SELECT author_name INTO v_book_author_name 
            FROM authors WHERE author_id = book_rec.author;
            
            UPDATE books SET price = price * (1 + v_increase_percentage)
            WHERE book_id = book_rec.book_id;
            DBMS_OUTPUT.PUT_LINE('Price of book with ID ' 
                || book_rec.book_id || ' by ' || v_book_author_name 
                || ' updated successfully.');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error updating price of book with ID ' 
                    || book_rec.book_id || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/
 
 
-- Problem 2: Calculate the total number of books in each genre.

DECLARE
    CURSOR genre_cursor IS
        SELECT DISTINCT genre FROM books;
    v_total_books NUMBER;
BEGIN
    FOR genre_rec IN genre_cursor
    LOOP
        SELECT COUNT(*) INTO v_total_books FROM books WHERE genre = genre_rec.genre;
        DBMS_OUTPUT.PUT_LINE('Genre: ' || genre_rec.genre || 
            ', Total Books: ' || v_total_books);
    END LOOP;
END;
/

?
-- Problem 3: Delete customers who haven't placed any orders.

DECLARE
    TYPE customer_id_list IS TABLE OF customers.customer_id%TYPE;
    v_customer_ids customer_id_list := customer_id_list();
BEGIN
    FOR customer_rec IN (SELECT customer_id FROM customers)
    LOOP
        v_customer_ids.EXTEND;
        v_customer_ids(v_customer_ids.LAST) := customer_rec.customer_id;
    END LOOP;

    FORALL i IN v_customer_ids.FIRST..v_customer_ids.LAST SAVE EXCEPTIONS
        DELETE FROM customers WHERE customer_id = v_customer_ids(i)
        AND customer_id NOT IN (SELECT DISTINCT customer FROM orders);
END;
/
 
 
-- Problem 4: Insert a new author and handle exceptions.

DECLARE
    v_author_name authors.author_name%TYPE := 'New Author';
    v_nationality authors.nationality%TYPE := 'Unknown';
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO authors 
    (author_id, author_name, nationality) VALUES (authors_seq.NEXTVAL, :1, :2)'
    USING v_author_name, v_nationality;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting new author: ' || SQLERRM);
END;
/
 
?
-- Problem 5: Calculate the average price of books in each genre using a cursor.

DECLARE
    CURSOR genre_cursor IS
        SELECT DISTINCT genre FROM books;
    v_total_books NUMBER;
    v_total_price NUMBER;
    v_avg_price NUMBER;
BEGIN
    FOR genre_rec IN genre_cursor
    LOOP
        SELECT COUNT(*), SUM(price) INTO v_total_books, v_total_price 
        FROM books WHERE genre = genre_rec.genre;
        v_avg_price := v_total_price / v_total_books;

    END LOOP;
END;
/

?
-- Problem 6: Develop a function to get the total number of books written by an author.

CREATE OR REPLACE FUNCTION get_total_books_by_author(author_id IN NUMBER)
RETURN NUMBER
IS
    v_total_books NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_books FROM books WHERE author = author_id;
    RETURN v_total_books;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

?
-- Problem 7: Create a procedure to delete a customer along with their orders and order items.

CREATE OR REPLACE PROCEDURE delete_customer_with_orders(customer_id IN NUMBER)
IS
BEGIN
    DELETE FROM order_items WHERE order_no IN 
    (SELECT order_id FROM orders WHERE customer = customer_id);
    DELETE FROM orders WHERE customer = customer_id;
    DELETE FROM customers WHERE customer_id = customer_id;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error deleting customer: ' || SQLERRM);
END;
/

?
-- Problem 8: Implement a package with a function to calculate total revenue and a procedure to update stock quantity.

CREATE OR REPLACE PACKAGE bookstore_mgmt AS
    FUNCTION calculate_total_revenue RETURN NUMBER;
    PROCEDURE update_stock_quantity(book_id IN NUMBER, new_quantity IN NUMBER);
END bookstore_mgmt;
/

CREATE OR REPLACE PACKAGE BODY bookstore_mgmt AS
    FUNCTION calculate_total_revenue RETURN NUMBER
    IS
        v_total_revenue NUMBER := 0;
    BEGIN
        SELECT SUM(quantity * price) INTO v_total_revenue 
        FROM order_items JOIN books ON order_items.book = books.book_id;
        RETURN v_total_revenue;
    END calculate_total_revenue;

    PROCEDURE update_stock_quantity(book_id IN NUMBER, new_quantity IN NUMBER)
    IS
    BEGIN
        UPDATE books SET stock_quantity = new_quantity WHERE book_id = book_id;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error updating stock quantity: ' || SQLERRM);
    END update_stock_quantity;
END bookstore_mgmt;
/

?
-- Problem 9: Implement a function to calculate the average stock quantity of books.

CREATE OR REPLACE FUNCTION calculate_avg_stock_quantity RETURN NUMBER IS
    v_avg_stock_quantity NUMBER;
BEGIN
    SELECT AVG(stock_quantity) INTO v_avg_stock_quantity FROM books;
    RETURN v_avg_stock_quantity;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

?
-- Problem 10: Write a trigger at row level that prevents the deletion of authors if they have any associated books.

CREATE OR REPLACE TRIGGER prevent_author_deletion
BEFORE DELETE ON authors
FOR EACH ROW
DECLARE
    v_book_count NUMBER;
    v_author VARCHAR2(20);
BEGIN
    SELECT COUNT(*) INTO v_book_count FROM books WHERE author = v_author;
    IF v_book_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot delete author with associated books.');
    END IF;
END;
/

?
-- Problem 11: Implement a trigger at statement level that logs the details of deleted books.

CREATE OR REPLACE TRIGGER log_deleted_books
AFTER DELETE ON books
FOR EACH ROW
DECLARE
    v_deleted_date DATE;
BEGIN
    v_deleted_date := SYSDATE;
    
    INSERT INTO deleted_books_log (book_id, title, deleted_date) 
    VALUES (:OLD.book_id, :OLD.title, v_deleted_date);
END;
/

?
-- Problem 12: Create a varray to store the names of authors with more than 5 books. Write a function to populate this varray and return it.

CREATE OR REPLACE FUNCTION get_authors_with_many_books RETURN author_name_varray
IS
    v_authors author_name_varray := author_name_varray();
BEGIN
    FOR author_rec IN (SELECT b.author, COUNT(*) AS book_count 
                       FROM books b
                       GROUP BY b.author)
    LOOP
        IF author_rec.book_count > 5 THEN
            SELECT author_name INTO v_authors(v_authors.COUNT + 1) 
            FROM authors a
            WHERE a.author_id = author_rec.author;
        END IF;
    END LOOP;
    
    RETURN v_authors;
END;
/

?
-- Problem 13: Create a procedure to handle division by zero errors when calculating the average stock quantity of books.

CREATE OR REPLACE PROCEDURE calculate_avg_stock_quantity_with_error_handling
IS
    v_avg_stock_quantity NUMBER;
BEGIN
    SELECT AVG(stock_quantity) INTO v_avg_stock_quantity FROM books;
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Error: Division by zero occurred.');
END;
/

?
-- Problem 14: Implement an explicit cursor to update the stock quantity of books in a specified genre.

DECLARE
    CURSOR book_cursor IS
        SELECT * FROM books WHERE genre = 'Fantasy' FOR UPDATE;
BEGIN
    FOR book_rec IN book_cursor
    LOOP
        UPDATE books SET stock_quantity = stock_quantity + 10 
        WHERE CURRENT OF book_cursor;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating stock quantity: ' || SQLERRM);
END;
/

?
-- Problem 15: Implement a loop that iterates over the stock quantity of books and categorizes them as low, medium, or high based on predefined thresholds.

DECLARE
    v_stock_threshold_low NUMBER := 10;
    v_stock_threshold_medium NUMBER := 50;
BEGIN
    FOR book_rec IN (SELECT * FROM books)
    LOOP
        CASE
            WHEN book_rec.stock_quantity <= v_stock_threshold_low THEN
                DBMS_OUTPUT.PUT_LINE('Book ' || book_rec.title || ' has low stock.');
            WHEN book_rec.stock_quantity > v_stock_threshold_low 
            AND book_rec.stock_quantity <= v_stock_threshold_medium THEN
                DBMS_OUTPUT.PUT_LINE('Book ' || book_rec.title || ' has medium stock.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Book ' || book_rec.title || ' has high stock.');
        END CASE;
    END LOOP;
END;
/

?
-- Problem 16: Create a function to calculate the discount percentage based on the total purchase amount and customer type.

CREATE OR REPLACE FUNCTION calculate_discount_percentage(
    p_total_purchase_amount IN NUMBER,
    p_customer_type IN VARCHAR2
) RETURN NUMBER
IS
    v_discount_percentage NUMBER;
BEGIN
    IF p_customer_type = 'Regular' THEN
        v_discount_percentage := CASE
                                    WHEN p_total_purchase_amount >= 100 THEN 10
                                    ELSE 5
                                 END;
    ELSIF p_customer_type = 'VIP' THEN
        v_discount_percentage := 15;
    ELSE
        v_discount_percentage := 0;
    END IF;
    
    RETURN v_discount_percentage;
END;
/

?
-- Problem 17: Create a procedure to update the publication date of a book based on the author's nationality.

CREATE OR REPLACE PROCEDURE update_publication_date_by_nationality(
    p_nationality IN VARCHAR2,
    p_new_publication_date IN DATE
)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE books SET publication_date = :1 
    WHERE author IN (SELECT author_id FROM authors WHERE nationality = :2)'
    USING p_new_publication_date, p_nationality;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating publication dates: ' || SQLERRM);
END;
/
 
?
-- Problem 18: Develop a function to get the total revenue generated by an author based on their books.

CREATE OR REPLACE FUNCTION get_total_revenue_by_author(author_id IN NUMBER)
RETURN NUMBER
IS
    v_total_revenue NUMBER;
BEGIN
    SELECT SUM(order_items.quantity * books.price)
    INTO v_total_revenue
    FROM order_items
    JOIN books ON order_items.book = books.book_id
    WHERE books.author = author_id;
    
    RETURN v_total_revenue;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

?
--Problem 19: Store and display the number of orders for each customer using an index-by table.

DECLARE
    TYPE order_count_type IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    v_order_count order_count_type;
BEGIN
    FOR order_rec IN (SELECT customer, COUNT(*) AS order_count FROM orders GROUP BY customer)
    LOOP
        v_order_count(order_rec.customer) := order_rec.order_count;
    END LOOP;

    FOR customer_id IN v_order_count.FIRST..v_order_count.LAST
    LOOP
        DBMS_OUTPUT.PUT_LINE('Customer ID: ' || customer_id || 
            ', Order Count: ' || v_order_count(customer_id));
    END LOOP;
END;
/

?
-- Problem 20: Implement a row-level trigger to enforce a constraint that prevents the insertion of orders for books with zero stock.

CREATE OR REPLACE TRIGGER prevent_zero_stock_orders
BEFORE INSERT ON orders
FOR EACH ROW
DECLARE
    v_stock_quantity NUMBER;
    v_book_id NUMBER;
BEGIN
    FOR stock_cursor IN (SELECT stock_quantity FROM books WHERE book_id = v_book_id) LOOP
        v_stock_quantity := stock_cursor.stock_quantity;
    END LOOP;

    IF v_stock_quantity = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot place an order for a book with zero stock.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid book ID specified.');
END;
/
