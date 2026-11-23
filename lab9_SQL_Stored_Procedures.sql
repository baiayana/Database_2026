DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;
-- Create table: stations
CREATE TABLE stations (
station_id INT PRIMARY KEY,
station_name VARCHAR(50) NOT NULL,
city VARCHAR(40) NOT NULL,
capacity INT NOT NULL
);
-- Create table: bikes
CREATE TABLE bikes (
bike_id INT PRIMARY KEY,
model VARCHAR(50) NOT NULL,
station_id INT REFERENCES stations(station_id),
daily_rate NUMERIC(8,2) NOT NULL
);

-- Create table: members
CREATE TABLE members (
member_id INT PRIMARY KEY,
full_name VARCHAR(60) NOT NULL,
city VARCHAR(40) NOT NULL,
joined_on DATE NOT NULL
);
-- Create table: rentals
CREATE TABLE rentals (
rental_id INT PRIMARY KEY,
member_id INT REFERENCES members(member_id),
bike_id INT REFERENCES bikes(bike_id),
start_date DATE NOT NULL,
end_date DATE,
fee NUMERIC(8,2)
);


INSERT INTO stations VALUES
(10, 'Central Park', 'Almaty', 4),
(20, 'Riverside', 'Almaty', 3),
(30, 'Expo Gate', 'Astana', 5),
(40, 'Old Town', 'Shymkent', 2),
(50, 'Depot', 'Astana', 0);
INSERT INTO bikes VALUES
(101, 'City Cruiser', 10, 4.50),
(102, 'City Cruiser', 10, 4.50),
(103, 'Mountain X', 20, 7.00),
(104, 'Mountain X', 30, 7.00),
(105, 'Road Sprint', 30, 9.25),
(106, 'Folding Mini', 40, 3.75),
(107, 'Cargo Hauler', 20, 12.00),
(108, 'Road Sprint', 10, 9.25);
INSERT INTO members VALUES
(1, 'Aisha Nurlanova', 'Almaty', DATE '2023-03-14'),
(2, 'Daniyar Serik', 'Almaty', DATE '2023-07-02'),
(3, 'Marta Kowalski', 'Astana', DATE '2024-01-20'),
(4, 'Chen Wei', 'Astana', DATE '2024-05-11'),
(5, 'Omar Haddad', 'Shymkent', DATE '2024-09-30'),
(6, 'Elena Petrova', 'Almaty', DATE '2025-02-05');


INSERT INTO rentals VALUES
( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02', 4.50),
( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
(10, 3, 104, DATE '2025-01-09', DATE '2025-01-10', 7.00),
(11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
(12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
(13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
(14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
(15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
(16, 5, 106, DATE '2025-01-18', DATE '2025-01-20', 7.50),
(17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
(18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
(19, 1, 101, DATE '2025-10-10', NULL, NULL),
(20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
(21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
(22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);


SELECT (SELECT COUNT(*) FROM stations) AS stations,
(SELECT COUNT(*) FROM bikes) AS bikes,
(SELECT COUNT(*) FROM members) AS members,
(SELECT COUNT(*) FROM rentals) AS rentals;


-- Part 2
-- Exercise 2.1: A function over one row
-- Rental duration
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    days INT;
BEGIN
    SELECT end_date - start_date
    INTO days
    FROM rentals
    WHERE rental_id = p_rental_id;

    RETURN days;
END;
$$ LANGUAGE plpgsql;


SELECT rental_days(2);
SELECT rental_days(11);
SELECT rental_days(19); -- Rental 19 returns NULL because its end date is NULL.
SELECT rental_days(999); -- Rental 999 returns NULL because no matching record exists.
-- The results are identical, but the reasons are different.



-- Exercise 2.2: A function over many rows
-- Count member rentals
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE
    total INT;
BEGIN
    SELECT COUNT(*) INTO total
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN total;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1);
SELECT member_rental_count(5);
SELECT member_rental_count(6);
SELECT member_rental_count(99);
-- COUNT(*) returns zero when no rows match the condition.
-- It does not return NULL, regardless of whether the member exists.


-- Exercise 2.3: Returning text
-- function that returns the city of a station.
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    result VARCHAR;
BEGIN
    SELECT city INTO result
    FROM stations
    WHERE station_id = p_station_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30);
SELECT station_city(77);


-- Exercise 2.4: Using a function inside a query
-- Find all rentals that lasted more than four days and sort them by duration.
SELECT rental_id,
       member_id,
       rental_days(rental_id) AS duration
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration DESC;



-- Part 3: Parameter Modes
-- Exercise 3.1: IN parameters
-- Calculate the rental fee after a percentage discount.
CREATE OR REPLACE FUNCTION fee_with_discount(
    p_fee NUMERIC,
    p_percent NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15);
-- IN is the default mode, so we do not need to write it explicitly.



-- Exercise 3.2: OUT parameters
-- Return three statistics about a member: Number of rentals, Total fees, Latest rental date.
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
)
AS $$
BEGIN
    SELECT COUNT(*),
           COALESCE(SUM(fee), 0), -- If SUM(fee) is NULL, PostgreSQL returns zero instead.
           MAX(start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals
    WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;
-- we do not write RETURNS or RETURN here because the output variables are already declared.

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);



-- Exercise 3.3: INOUT parameters
-- Receive a fee and increase it by 5.
CREATE OR REPLACE FUNCTION apply_late_fee(
    INOUT p_fee NUMERIC
)
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee)
FROM rentals
WHERE rental_id = 1;

-- An INOUT parameter acts as both an input and an output, so its final value is automatically returned.



-- Exercise 3.4: VARIADIC parameters
-- Create a function that accepts any number of fees.
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
)
AS $$
BEGIN
    SELECT SUM(p_fees[i]),
           ROUND(AVG(p_fees[i]), 2),
           MAX(p_fees[i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);

SELECT fee_summary();
-- Normally produces a function resolution error because a variadic call requires at least one variadic argument.

-- To explicitly pass an empty array:
SELECT * FROM fee_summary(VARIADIC ARRAY[]::NUMERIC[]);

-- The variadic parameter must be the last input parameter because it collects the remaining input arguments.
-- OUT parameters can follow it.




-- Exercise 3.5: Choosing a mode
-- a) ID of a row
-- IN, Only provides input
-- b) Running balance
-- INOUT, Receives and returns an updated balance
-- c) Unknown number of station IDs
-- VARIADIC, Accepts a variable number of arguments
-- d) Two statistics
-- OUT, Returns multiple values



-- Part 4: Default Values and Function Overloading
-- Exercise 4.1: A function with one parameter
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(fee), 0)
        FROM rentals
        WHERE member_id = p_member_id
    );
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1);
SELECT total_fees(6);




-- Exercise 4.2: Overloading the name
-- Create another function with the same name but two parameters.
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(fee), 0)
        FROM rentals
        WHERE member_id = p_member_id
          AND start_date >= p_from_date
    );
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01');
SELECT total_fees(1, DATE '2025-01-01');

-- To display both functions:
SELECT proname, pg_get_function_identity_arguments(oid)
FROM pg_proc
WHERE proname = 'total_fees';




-- Exercise 4.3: Giving a parameter a default value
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(fee), 0)
        FROM rentals
        WHERE member_id = p_member_id
          AND start_date >= p_from_date
    );
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1);
-- ОШИБКА: функция total_fees(integer) не уникальна
-- Подсказка: Не удалось выбрать лучшую кандидатуру функции. Возможно, вам следует добавить явные приведения типов.
-- Both functions can now accept one argument:
-- total_fees(INT)
-- total_fees(INT, DATE DEFAULT ...)
-- PostgreSQL does not know which function to execute.




-- Exercise 4.4: Resolving the ambiguity

DROP FUNCTION total_fees(INTEGER);

SELECT total_fees(1);

-- Only the two-parameter function remains, and its default date is used.
-- Dropping the other version would instead return 98.50.




-- Exercise 4.5: Overloading on type, not just on count
CREATE OR REPLACE FUNCTION total_fees(p_name VARCHAR)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(r.fee), 0)
        FROM rentals r
        JOIN members m
          ON r.member_id = m.member_id
        WHERE m.full_name = p_name
    );
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova');
SELECT total_fees(1);

-- The first function calculates fees across all dates. The second calculates fees starting from 2025.
-- There is no ambiguity because the input types are different.



-- Part 5: Functions That Return a Table
-- Exercise 5.1: Search by pattern
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model, b.daily_rate
    FROM bikes b
    WHERE b.model ILIKE p_pattern
    ORDER BY b.bike_id;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');

SELECT find_bikes('%road%');
-- Each matching row is returned as one composite value instead of three separate columns.


-- Exercise 5.2: A table from a join
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE (
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration INT,
    fee NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id,
           b.model,
           s.station_name,
           r.end_date - r.start_date,
           r.fee
    FROM rentals r
    JOIN bikes b ON r.bike_id = b.bike_id
    JOIN stations s ON b.station_id = s.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);



-- Exercise 5.3: When the column names collide
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR)
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model
    FROM bikes
    WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);
-- ОШИБКА: неоднозначная ссылка на столбец "bike_id"
-- PostgreSQL cannot distinguish between the output variable bike_id and the table column bike_id.

-- Solution 1 — Rename output columns
DROP FUNCTION bike_list(INT);

CREATE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (found_id INT, found_model VARCHAR)
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model
    FROM bikes
    WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;


-- Solution 2 — Use aliases
DROP FUNCTION bike_list(INT);

CREATE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR)
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model
    FROM bikes b
    WHERE b.station_id = p_station_id;

END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);



-- Exercise 5.4: Casting the output
-- Calculate the number of bikes and free docks at every station in a city.

CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name,
           COUNT(b.bike_id),
           s.capacity - COUNT(b.bike_id)
    FROM stations s
    LEFT JOIN bikes b
        ON s.station_id = b.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Astana');

-- ОШИБКА: structure of query does not match function result type
-- Подробности: Возвращаемый тип bigint не соответствует ожидаемому типу integer в столбце "s_bikes" (позиция 2).

CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name,
           COUNT(b.bike_id)::INT,
           s.capacity - COUNT(b.bike_id)::INT
    FROM stations s
    LEFT JOIN bikes b
      ON s.station_id = b.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Astana');


-- Part 6: Block Structure, DO Blocks and Subblocks
-- Exercise 6.1: An anonymous block
DO $$
<<rental_report>>
DECLARE
    total_rentals INT := 0;
BEGIN
    SELECT COUNT(*) INTO total_rentals
    FROM rentals;

    RAISE NOTICE 'The rentals table holds % rows.',
        total_rentals;
END rental_report;
$$;
-- If the closing label does not match the opening label, PostgreSQL produces an error.




-- Exercise 6.2: A subblock and a hidden variable
DO $$
<<outer_block>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT SUM(fee) INTO fee_total
    FROM rentals;

    RAISE NOTICE 'Outer before: %', fee_total;

    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT SUM(fee) INTO fee_total
        FROM rentals
        WHERE start_date >= DATE '2025-01-01';

        RAISE NOTICE 'Inner: %', fee_total;

        RAISE NOTICE 'Outer inside: %',
            outer_block.fee_total;
    END;

    RAISE NOTICE 'Outer after: %', fee_total;
END outer_block;
$$;

-- Expected output:
-- Outer before: 621.50
-- Inner: 369.50
-- Outer inside: 621.50
-- Outer after: 621.50
--
-- The inner variable does not modify the outer variable. They are two separate variables that have the same name.




-- Exercise 6.3: Declarations are local
-- Incorrect example:
DO $$
BEGIN
    DECLARE
        x INT := 10;
    BEGIN
        RAISE NOTICE '%', x;
    END;

    BEGIN
        RAISE NOTICE '%', x;
    END;
END;
$$;

-- Correct solution:
DO $$
DECLARE
    x INT := 10;
BEGIN
    BEGIN
        RAISE NOTICE '%', x;
    END;

    BEGIN
        RAISE NOTICE '%', x;
    END;
END;
$$;




-- Exercise 6.4: From a block to a function
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
)
AS $$
BEGIN
    SELECT
        COALESCE(SUM(fee) FILTER (
            WHERE start_date < p_from_date
        ), 0),
        COALESCE(SUM(fee) FILTER (
            WHERE start_date >= p_from_date
        ), 0)
    INTO before_total, after_total
    FROM rentals;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_split(DATE '2025-01-01');

-- Verify
SELECT before_total + after_total AS combined
FROM fee_split(DATE '2025-01-01');

SELECT SUM(fee) FROM rentals;




-- Part 7: Practical Scenarios
-- Exercise 7.1: Station occupancy
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
)
AS $$
BEGIN
    SELECT COUNT(b.bike_id),
           ROUND(
               COUNT(b.bike_id) * 100.0 /
               NULLIF(s.capacity, 0), 1
           )
    INTO bikes_parked, capacity_pct
    FROM stations s
    LEFT JOIN bikes b
      ON s.station_id = b.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.capacity;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s,
LATERAL station_load(s.station_id) l;

-- NULLIF(s.capacity, 0) prevents division by zero.
-- I chose NULL for station 50 because its occupancy percentage is mathematically undefined.




-- Exercise 7.2: Top members, with a default
CREATE OR REPLACE FUNCTION top_members(
    p_limit INT DEFAULT 3
)
RETURNS TABLE (
    member_name VARCHAR,
    rental_count INT,
    total_spent NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r
      ON m.member_id = r.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY COALESCE(SUM(r.fee), 0) DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);

-- Aisha has more rentals than some members ranked above her.
-- This is not a mistake because the ranking is based on total spending, not rental count.

-- LEFT JOIN ensures Elena appears even though she has no rentals.






-- Exercise 7.3: An invoice for an open rental
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (
    member_name VARCHAR,
    bike_model VARCHAR,
    days INT,
    amount NUMERIC,
    status TEXT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,
           b.model,
           COALESCE(r.end_date, CURRENT_DATE) - r.start_date,
           ROUND(
               (COALESCE(r.end_date, CURRENT_DATE)
                - r.start_date) * b.daily_rate, 2
           ),
           CASE
               WHEN r.end_date IS NULL THEN 'OPEN'
               ELSE 'CLOSED'
           END
    FROM rentals r
    JOIN members m ON r.member_id = m.member_id
    JOIN bikes b ON r.bike_id = b.bike_id
    WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);

-- Rental 19 changes every day because it uses CURRENT_DATE.
-- Such a function cannot correctly be declared IMMUTABLE because its result can change even when the input remains the same.






-- Exercise 7.4: A report per city
CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    OUT member_count INT,
    OUT rental_count INT,
    OUT revenue NUMERIC
)
AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id),
           COUNT(r.rental_id),
           COALESCE(SUM(r.fee), 0)
    INTO member_count, rental_count, revenue
    FROM members m
    LEFT JOIN rentals r
      ON m.member_id = r.member_id
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;



-- Overloaded function:
CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    p_from_date DATE,
    OUT member_count INT,
    OUT rental_count INT,
    OUT revenue NUMERIC
)
AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id),
           COUNT(r.rental_id),
           COALESCE(SUM(r.fee), 0)
    INTO member_count, rental_count, revenue
    FROM members m
    LEFT JOIN rentals r
      ON m.member_id = r.member_id
      AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM city_report('Almaty');

SELECT * FROM city_report(
    'Almaty', DATE '2025-01-01'
);
-- The date condition belongs in the ON clause.
-- If you move the date condition into WHERE, members without rentals will be excluded.



-- LAB Questions
-- 1. Name vs signature

-- A function's name is the identifier used to call the function.
-- A function's signature consists of its name and the data types of its input parameters.

-- 2. Dollar quoting

-- Dollar quoting ($$) is used to mark the beginning and the end of a function body.
-- It allows us to use single quotes inside the function without escaping them.

-- 3. OUT vs RETURNS TABLE
-- Several OUT parameters are useful when a function needs to return multiple values as a single record,
-- such as the number of rentals, total fees and average fee.
-- RETURNS TABLE is useful when a function needs to return multiple rows and columns,
-- such as a list of bicycles or a member's rental history.
-- The main difference is that ordinary OUT parameters return a single record,
-- while RETURNS TABLE allows the function to return a set of records.

-- 4. VARIADIC
-- A VARIADIC parameter accepts an unknown number of arguments and collects them into an array.
-- It must be the last input parameter because it consumes the remaining input arguments.

-- 5. RETURN vs RETURN QUERY
-- RETURN is used to return a single value and terminate the execution of a regular scalar function.
-- RETURN QUERY is used to add the results of an SQL query to a function's returned set of rows.
-- Unlike RETURN, RETURN QUERY does not immediately terminate the function.
-- The function can continue executing and add more rows to its result.

-- 6. DEFAULT ambiguity
-- A default parameter allows a function to be called without providing all its arguments.
-- This can create ambiguity between overloaded functions.

-- 7. Subblock variables
-- A variable declared inside a subblock is local to that subblock. When the subblock ends, the variable goes out of scope and cannot be accessed from outside.
-- If an inner variable has the same name as an outer variable, it temporarily hides the outer variable.
-- This is called variable shadowing.

-- 8. Advantages and disadvantages
-- Advantage — Reusability and consistency.
-- A business rule can be defined once inside the database and reused by multiple applications.
-- For example, every application can use the same fee_with_discount() function to calculate discounts consistently.

-- Disadvantage — Increased database server workload.
-- Executing complex business logic inside stored functions increases the CPU workload on the database server.
-- This can reduce performance and make the database system more difficult to scale.

-- 9. Trusted languages
-- 	Ordinary users with appropriate privileges can create trusted-language functions.
-- 	Untrusted languages require superuser privileges.

-- 10. Changing argument types
-- PostgreSQL creates a new overloaded function instead of replacing the old one.