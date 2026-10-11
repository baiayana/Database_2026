-- AYANA
-- ID: 25B031142

-- Part 1: CHECK Constraints
DROP TABLE IF EXISTS employees CASCADE;
-- Task 1.1
CREATE TABLE employees(
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK(age BETWEEN 18 AND 65),  -- ensures that the age is between these numbers
    salary NUMERIC CHECK (salary > 0) -- same here ensures salary higher than 0
);

-- Task 1.2
CREATE TABLE products_catalog(
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount  -- names the CHECK constraint
    CHECK(
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- Task 1.3
CREATE TABLE bookings(
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,
    CHECK(num_guests BETWEEN 1 AND 10), -- ensures that number of guests between these numbers
    CHECK(check_out_date > check_in_date)  -- ensures that checkout date is later that the check in date
);

-- Task 1.4


-- employees table, valid inserts
INSERT INTO employees(employee_id, first_name, last_name, age, salary)
VALUES (1, 'Sara', 'Smith', 30, 100000),
       (2, 'Millie', 'Brown', 45, 200000);

-- Invalid insert, violates the age constraint
INSERT INTO employees
VALUES(3, 'Mike', 'Jones', 16, 4000);
--violates the salary constraint
INSERT INTO employees
VALUES(3, 'Mike', 'Jones', 28, 0);





-- products_catalog table
-- Valid insert
INSERT INTO products_catalog(product_id, product_name, regular_price, discount_price)
VALUES (1, 'Laptop', 1000, 800),
       (2, 'Headphones', 500, 300);

-- Invalid insert
-- violates the regular_price
INSERT INTO products_catalog
VALUES (3, 'Keyboard', 0, 100);
-- violates the discount_price
INSERT INTO products_catalog
VALUES (4, 'Mouse', 50, 0);
-- violates discount_price < regular_price
INSERT INTO products_catalog
VALUES (5, 'Charger', 10, 20);




-- bookings table
-- Valid insert
INSERT INTO bookings(booking_id, check_in_date, check_out_date, num_guests)
VALUES (1, '2026-10-10', '2026-10-15', 2),
       (2,'2026-12-01', '2026-12-02', 6);

-- Invalid insert
-- violates num_guests
INSERT INTO bookings
VALUES(3, '2026-11-20', '2026-11-22', 12);

-- violates date
INSERT INTO bookings
VALUES(3, '2026-11-22', '2026-11-20', 2);


-- Part 2: NOT NULL Constraints
-- Task 2.1
CREATE TABLE customers(
    customer_id INTEGER NOT NULL,    -- ID cannot be NULL
    email TEXT NOT NULL,      -- email is required
    phone TEXT,   -- can have NULL phone
    registration_date DATE NOT NULL    -- requires date
);

-- Task 2.2
CREATE TABLE inventory(
    item_id INTEGER NOT NULL,   --cannot be NULL
    item_name TEXT NOT NULL,      -- name is required
    quantity INTEGER NOT NULL CHECK(quantity >= 0),   -- must be more or equal 0
    unit_price NUMERIC NOT NULL CHECK(unit_price > 0),  -- must be greater 0
    last_updated TIMESTAMP NOT NULL -- last update is required
);

-- Task 2.3
-- CUSTOMERS TABLE
INSERT INTO customers(customer_id, email, phone, registration_date)
VALUES(1, 'john@example.com', '123456789', '2024-12-03'),
      (2, 'alice@example.com', '982432821', '2020-01-25');

-- attempt to insert NULL into NOT NULL columns
INSERT INTO customers
VALUES (NULL, 'mike@example.com', '123214678', '2025-03-10');

INSERT INTO customers
VALUES (3, NULL, '123214678', '2025-03-10');

INSERT INTO customers
VALUES (4, 'mike@example.com', '123214678', NULL);

INSERT INTO customers
VALUES (5, 'mike@example.com', NULL, '2025-03-10');




-- INVENTORY TABLE
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (1, 'Laptop', 10, 750.00, '2026-10-09 10:00:00'),
       (2, 'Keyboard', 25, 35.50, '2026-10-09 11:30:00');

INSERT INTO inventory
VALUES(NULL, 'Mouse', 15, 20.00, '2026-10-09 12:00:00');

INSERT INTO inventory
VALUES(3, NULL, 15, 20.00, '2026-10-09 12:00:00');

INSERT INTO inventory
VALUES(4, 'Mouse', NULL, 20.00, '2026-10-09 12:00:00');

INSERT INTO inventory
VALUES(5, 'Mouse', 15, NULL, '2026-10-09 12:00:00');

INSERT INTO inventory
VALUES(6, 'Mouse', 15, 20.00, NULL);
-- THERE ARE NO NULLABLE COLUMNS

-- Part 3: UNIQUE Constraints
-- Task 3.1
CREATE TABLE users(
    user_id INTEGER,
    username TEXT UNIQUE,  -- MUST be UNIQUE
    email TEXT UNIQUE,  -- MUST be UNIQUE
    created_at TIMESTAMP   -- stores date and time when user was created
);

-- Task 3.2
CREATE TABLE course_enrollments(
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT combination
        UNIQUE (student_id, course_code,
semester)   -- UNIQUE prevents duplicate combinations of these given cause student cannot enroll the same course twice
);

-- Task 3.3
-- Adds a named constraint to prevent duplicate usernames
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);
-- Adds a named constraint to prevent duplicate emails
ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users(user_id, username, email, created_at)
VALUES (1, 'john123', 'john@example.com', CURRENT_TIMESTAMP),
    (2, 'alice456', 'alice@example.com', CURRENT_TIMESTAMP);

INSERT INTO users(user_id, username, email, created_at)
VALUES (3, 'john123', 'mike@example.com', CURRENT_TIMESTAMP);

INSERT INTO users(user_id, username, email, created_at)
VALUES (4, 'mike789', 'john@example.com', CURRENT_TIMESTAMP);


-- Part 4: PRIMARY KEY Constraints
-- Task 4.1
DROP TABLE IF EXISTS departments;

CREATE TABLE departments(
    dept_id INTEGER PRIMARY KEY,   --uniquely identifies each dep and cannot be NULL
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments(dept_id, dept_name, location)
VALUES (1, 'IT', 'Almaty'),
       (2, 'HR', 'Astana'),
       (3, 'PR', 'Aktobe');

INSERT INTO departments
VALUES (1, 'Finance', 'Almaty');

INSERT INTO departments
VALUES (NULL, 'Security', 'Shymkent');

-- Task 4.2
CREATE TABLE student_courses(
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY(student_id, course_id)
);
--Composite PRIMARY KEY ensures each student-course combination is unique and prevents duplicate enrollments.




-- Task 4.3

-- 1. Difference between UNIQUE and PRIMARY KEY:
-- PRIMARY KEY uniquely identifies each row.
-- It does not allow NULL or duplicate values.
-- UNIQUE prevents duplicate values but allows NULL.

-- 2. Single-column vs Composite PRIMARY KEY:
-- Single-column PRIMARY KEY uses one column to identify a row.
-- Example: student_id.
-- Composite PRIMARY KEY uses two or more columns.
-- Example: (student_id, course_id).

-- 3. Why one PRIMARY KEY but multiple UNIQUE constraints?
-- A table has one PRIMARY KEY because it is the main identifier.
-- It can have multiple UNIQUE constraints because different
-- columns may need unique values, such as email and username.


-- Part 5: FOREIGN KEY Constraints
-- Task 5.1
CREATE TABLE employees_dept(
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);
-- REFERENCES creates a FOREIGN KEY.
-- It ensures that dept_id exists in the departments table.
-- This prevents assigning employees to non-existent departments.

INSERT INTO employees_dept(emp_id, emp_name, dept_id, hire_date)
VALUES (101, 'John Smith', 1, '2025-03-15'),
    (102, 'Alice Brown', 2, '2025-06-20'),
    (103, 'Mike Jones', 3, '2026-01-10');

INSERT INTO employees_dept
VALUES (104, 'Emma Davis', 95, '2026-02-01');

-- Task 5.2, Multiple FOREIGN KEYS
CREATE TABLE authors(
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers(
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books(
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors(author_id, author_name, country)
VALUES (1, 'George Orwell', 'United Kingdom'),
    (2, 'J.K. Rowling', 'United Kingdom'),
    (3, 'Harper Lee', 'United States'),
    (4, 'Leo Tolstoy', 'Russia'),
    (5, 'Paulo Coelho', 'Brazil');

INSERT INTO publishers(publisher_id, publisher_name, city)
VALUES  (1, 'Penguin Books', 'London'),
    (2, 'Bloomsbury Publishing', 'London'),
    (3, 'J.B. Lippincott & Co.', 'Philadelphia'),
    (4, 'The Russian Messenger', 'Moscow'),
    (5, 'HarperCollins', 'New York');

INSERT INTO books(book_id, title, author_id, publisher_id, publication_year, isbn)
VALUES  (1, '1984', 1, 1, 1949, '9780451524935'),
    (2, 'Animal Farm', 1, 1, 1945, '9780451526342'),
    (3, 'Harry Potter and the Philosopher''s Stone',
        2, 2, 1997, '9780747532699'),
    (4, 'To Kill a Mockingbird', 3, 3, 1960, '9780061120084'),
    (5, 'War and Peace', 4, 4, 1869, '9781400079988');

SELECT * FROM authors;
SELECT * FROM publishers;
SELECT * FROM books;


-- Task 5.3: ON DELETE Options
CREATE TABLE categories(
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk(
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT -- IT PROTECTS FROM BEING DELETED
);

CREATE TABLE orders(
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items(
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE, -- CASCADE deletes related order items when an order is deleted.
    product_id INTEGER REFERENCES products_fk(product_id),  -- REFERENCES connects order_items to orders and products.
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories(category_id, category_name)
VALUES (1, 'Electronics'),
(2, 'Clothing');

INSERT INTO products_fk(product_id, product_name, category_id)
VALUES (1, 'Laptop', 1),
(2, 'T-Shirt', 2);

INSERT INTO orders(order_id, order_date)
VALUES (1, '2026-10-09'),
(2, '2026-10-10');

INSERT INTO order_items(item_id, order_id, product_id, quantity)
VALUES (1, 1, 1, 2),
(2, 1, 2, 3),
(3, 2, 1, 1);

DELETE FROM categories
WHERE category_id = 1; -- SO AS YOU CAN SEE THERE WILL BE AN ERROR BECAUSE RESTRICTED TO DELETE

SELECT * FROM order_items;

DELETE FROM orders
WHERE order_id = 1;  -- BECAUSE OF CASCADE IT DELETED RELATED ORDER ITEMS AUTO

SELECT * FROM order_items;

-- Part 6: Practical Application
-- Task 6.1: E-commerce Database Design

CREATE SCHEMA IF NOT EXISTS ecommerce;

CREATE TABLE ecommerce.customers(
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecommerce.products(
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK(price >= 0),
    stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0)
);

CREATE TABLE ecommerce.orders(
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES ecommerce.customers(customer_id) ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK(total_amount >= 0),
    status TEXT NOT NULL CHECK(status IN('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);
-- RESTRICT prevents deleting customers who have orders

CREATE TABLE ecommerce.order_details(
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES ecommerce.orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES ecommerce.products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);
-- CASCADE automatically deletes order details when an order is deleted.
-- RESTRICT prevents deleting products referenced in order details.

INSERT INTO ecommerce.customers VALUES
(1, 'John', 'john@gmail.com', '123456789', '2026-01-10'),
(2, 'Mike', 'mike@gmail.com', '987654321', '2026-02-15'),
(3, 'Anna', 'anna@gmail.com', '456789123', '2026-03-20'),
(4, 'David', 'david@gmail.com', '789123456', '2026-04-12'),
(5, 'Sara', 'sara@gmail.com', '321654987', '2026-05-25');

INSERT INTO ecommerce.products VALUES
(1, 'Laptop', 'Gaming laptop', 750.00, 10),
(2, 'Keyboard', 'Mechanical keyboard', 35.50, 25),
(3, 'Mouse', 'Wireless mouse', 20.00, 50),
(4, 'Monitor', 'Gaming monitor', 200.00, 15),
(5, 'Headphones', 'Wireless headphones', 50.00, 30);

INSERT INTO ecommerce.orders VALUES
(1, 1, '2026-10-01', 785.50, 'delivered'),
(2, 2, '2026-10-02', 40.00, 'pending'),
(3, 3, '2026-10-03', 200.00, 'shipped'),
(4, 4, '2026-10-04', 100.00, 'processing'),
(5, 5, '2026-10-05', 750.00, 'cancelled');

INSERT INTO ecommerce.order_details VALUES
(1, 1, 1, 1, 750.00),
(2, 1, 2, 1, 35.50),
(3, 2, 3, 2, 20.00),
(4, 3, 4, 1, 200.00),
(5, 4, 5, 2, 50.00),
(6, 5, 1, 1, 750.00);

SELECT * FROM ecommerce.customers;

SELECT * FROM ecommerce.products;

SELECT * FROM ecommerce.orders;

SELECT * FROM ecommerce.order_details;

-- FROM CUSTOMERS TABLE
INSERT INTO ecommerce.customers VALUES
(1, 'Alex', 'alex@gmail.com', '123456789', '2026-10-10');
-- THIS INSERT CAUSES ERROR CAUSE customer_id=1 is already exists

INSERT INTO ecommerce.customers VALUES
(6, 'Alex', 'john@gmail.com', '123456789', '2026-10-10');
-- THIS CAUSES ERROR CAUSE same email exists, UNIQUE prevents from it

INSERT INTO ecommerce.customers VALUES
(6, NULL, 'alex@gmail.com', '123456789', '2026-10-10');
-- ERROR CAUSE name declared as NOT NULL

DELETE FROM ecommerce.customers
WHERE customer_id = 1;
-- ERROR CAUSE WE USED ON DELETE RESTRICT which means no deleting



-- FROM PRODUCTS TABLE
INSERT INTO ecommerce.products VALUES
(6, 'Tablet', 'New tablet', -100, 10);
-- PRICE CANNOT BE NEGATIVE

INSERT INTO ecommerce.products VALUES
(6, 'Tablet', 'New tablet', 100, -10);
-- STOCK_QUANTITY CANNOT BE NEGATIVE


-- FROM ORDERS TABLE
INSERT INTO ecommerce.orders VALUES
(6, 1, '2026-10-10', 100, 'unknown');
-- ERROR CAUSE status is not allowed

INSERT INTO ecommerce.orders VALUES
(6, 100, '2026-10-10', 500, 'pending');
-- ERROR CAUSE there is NO customer with id 100


-- FROM ORDER_DETAILS TABLE
INSERT INTO ecommerce.order_details VALUES
(7, 1, 1, 0, 750);
-- ERROR CAUSE quantity must be positive


SELECT * FROM ecommerce.order_details;

DELETE FROM ecommerce.orders
WHERE order_id = 1;

SELECT * FROM ecommerce.order_details;

-- because of ON DELETE CASCADE Order 1 is deleted and two related records auto deleted
