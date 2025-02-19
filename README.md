# Bookstore Management System (SQL & PL/SQL)


## Features
- **Database Schema** with properly normalized tables
- **Constraints** (Primary Keys, Foreign Keys, Unique, Check, Not Null)
- **Indexes** for faster queries
- **Views** for simplified data access
- **Stored Procedures & Functions** for automating business logic
- **Triggers** to enforce integrity rules and log events
- **Cursors** for advanced operations
- **Error Handling** in PL/SQL
- **Transactions** for data consistency

## Database Schema
The system consists of the following main tables:
- `books` - Stores book details (ID, title, author, price, genre, stock, etc.)
- `authors` - Stores author information
- `customers` - Stores customer details
- `orders` - Stores orders placed by customers
- `order_items` - Stores items within each order
- `deleted_books_log` - Logs deleted books for audit purposes

## SQL & PL/SQL Implementations
### SQL Operations
- **Table Creation** with constraints
- **Indexes** for performance optimization
- **Views** to simplify query access
- **Complex Queries** (JOINs, Aggregate functions, Grouping, Filtering)

### PL/SQL Implementations
- **Procedures**:
  - Update book prices based on publication year
  - Delete customers who haven’t placed orders
- **Functions**:
  - Calculate total books per genre
  - Get average book price for a specific genre
- **Triggers**:
  - Prevent deletion of authors with existing books
  - Log deleted books into `deleted_books_log`
- **Cursors**:
  - Categorize stock levels based on quantity
- **Error Handling**:
  - Handles division by zero errors in calculations
