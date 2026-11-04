-- Part 1 Database Setup
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
-- Create table: employees
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

-- Insert Sample Data
-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);



-- Part 2: CROSS JOIN Exercises
-- CROSS JOIN combines every row from the first table with every row from the second row


-- Exercise 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

-- To calculate the actual number in db: emp_name * dept_name
SELECT COUNT(*)
FROM employees
CROSS JOIN departments;

-- Exercise 2.2: Alternative CROSS JOIN Syntax
-- 1. Comma notation
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- 2. INNER JOIN with TRUE condition
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

-- Exercise 2.3: Practical CROSS JOIN
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;



-- Part 3: INNER JOIN Exercises

-- Exercise 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;


SELECT COUNT(*)
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id;
-- If Tom Brown has NULL or a department ID that doesn't exist in departments, he won't appear in the result.

-- Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name
FROM employees
INNER JOIN departments
USING (dept_id);

SELECT *
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id;
-- Use ON when joining columns with different names.

SELECT *
FROM employees
INNER JOIN departments
USING (dept_id);
-- Use USING When you need to avoid duplicate columns.



-- Exercise 3.3: NATURAL INNER JOIN

SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- NATURAL INNER JOIN automatically finds columns that have the same name in both tables.
/* Important: NATURAL JOIN uses all columns that share the same name, not only dept_id.

For example, if both tables have location, SQL will also try to match location.
 */



-- Exercise 3.4: Multi-table INNER JOIN

SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id
INNER JOIN projects p
ON d.dept_id = p.dept_id;




-- Part 4: LEFT JOIN Exercises

-- Exercise 4.1: Basic LEFT JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- INNER JOIN → Only matching rows.
-- LEFT JOIN → All left table rows + matching right table rows.
-- Tom Brown appears in the result even though he has no department. His department information is displayed as NULL.


-- Exercise 4.2: LEFT JOIN with USING
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d
USING (dept_id);


-- Exercise 4.3: Find Unmatched Records
SELECT e.emp_name, d.dept_id
FROM employees e
LEFT JOIN departments d ON e.emp_id = d.dept_id
WHERE d.dept_id IS NULL;


-- Exercise 4.4: LEFT JOIN with Aggregation
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;




-- Part 5: RIGHT JOIN Exercises

-- Exercise 5.1: Basic RIGHT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Tom Brown disappears because he doesn't have a department.
-- Finance appears because RIGHT JOIN includes departments without employees.


-- Exercise 5.2: Convert to LEFT JOIN

SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- Exercise 5.3: Find Departments Without Employees
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d
ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;




-- Part 6: FULL JOIN Exercises

-- Exercise 6.1: Basic FULL JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- FULL JOIN returns ALL rows from BOTH tables, whether they match or not.
/*Tom Brown appears even though he has no department.
Finance appears even though it has no employees.

This is why we use FULL JOIN.


LEFT side (employees):

Finance has NULL for employee columns.

Why? Because Finance doesn't have employees.

RIGHT side (departments):

Tom Brown has NULL for department columns.

Why? Because Tom Brown doesn't belong to a department.
 */



-- Exercise 6.2: FULL JOIN with Projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;
-- Therefore, FULL JOIN is necessary when we want unmatched records from both tables.


-- Exercise 6.3: Find Orphaned Records
SELECT
    CASE
        WHEN e.emp_id IS NULL
            THEN 'Department without employees'
        WHEN d.dept_id IS NULL
            THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d
ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL
   OR d.dept_id IS NULL;



-- Part 7: ON vs WHERE Clause
-- Exercise 7.1: Filtering in ON Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id
AND d.location = 'Building A';
--Matches employees with departments.

-- Exercise 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Filters the result to Building A.

-- Exercise 7.3: ON vs WHERE with INNER JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id
AND d.location = 'Building A';

-- Part 8: Complex JOIN Scenarios
-- Exercise 8.1: Multiple Joins with Different Types
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Exercise 8.2: Self Join
-- Add manager_id column
ALTER TABLE employees
ADD COLUMN manager_id INT;

-- Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;
-- Self join query
SELECT
 e.emp_name AS employee,
 m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Exercise 8.3: Join with Subquery
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;


/* 1. What is the difference between INNER JOIN and LEFT JOIN?

INNER JOIN returns only rows that have matching values in both tables.

LEFT JOIN returns all rows from the left table, even if there are no matches in the right table. Missing values are represented by NULL.
 */

 /*2. When would you use CROSS JOIN in a practical scenario?

We use CROSS JOIN when we need every possible combination of rows from two tables.
  */

/*3. Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.

ON defines which rows from two tables match.

WHERE filters rows from the joined result.

With LEFT JOIN, placing a condition in ON preserves all left-table rows, while putting the same condition in WHERE may remove some of them.
 */


/* 4. What is the result of SELECT COUNT(*) FROM table1 CROSS JOIN table2 if table1 has 5 rows and table2 has 10 rows?

Answer: 50 rows. 5 * 10 = 50
 */

/* 5. How does NATURAL JOIN determine which columns to join on?

NATURAL JOIN automatically finds columns with identical names in both tables and uses them as matching conditions.
 */

/* 6. What are the potential risks of using NATURAL JOIN?

The main risk is that NATURAL JOIN automatically matches every column with the same name, even if those columns should not be compared.
 */

-- Original
SELECT *
FROM A
LEFT JOIN B
ON A.id = B.id;
-- Converted
SELECT *
FROM B
RIGHT JOIN A
ON A.id = B.id;

/* 8. When should you use FULL OUTER JOIN instead of other join types?

We use FULL OUTER JOIN when we need all records from both tables, including those without matches.
 */