-- Part A
CREATE DATABASE advanced_lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

-- Part B
INSERT INTO employees
    (emp_id,	first_name, last_name,	department)
VALUES
    (10, 'Will', 'Smith', 'IT');

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Anna', 'Brown', 'HR', DEFAULT, '2026-09-01', DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 500000, 1),
    ('HR', 300000, 2),
    ('Finance', 400000, 3);

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Michael', 'Johnson', 'IT', 50000 * 1.1, CURRENT_DATE);

CREATE TEMP TABLE temp_employees
(LIKE employees INCLUDING ALL);

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';

-- Part C
UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;


UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


UPDATE departments
SET budget = (
    SELECT AVG(salary) * 1.20
    FROM employees
    WHERE employees.department = departments.dept_name
    );

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- Part D

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN(
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
    );

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- Part E

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Aibar', 'Baqyt', NULL, NULL, CURRENT_DATE);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

-- Part F

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Anna', 'Williams', 'IT', 600000, CURRENT_DATE)
RETURNING emp_id,
    first_name || ' ' || last_name AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING
    emp_id,
    salary - 5000 AS old_salary,
    salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- Part G

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
SELECT
    'James', 'Wilson', 'IT', 60000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'James'
      AND last_name = 'Wilson'
);


UPDATE employees
SET salary = salary *
    CASE
        WHEN departments.budget > 100000 THEN 1.10
        ELSE 1.05
    END
FROM departments
WHERE employees.department = departments.dept_name;


INSERT INTO employees
    (first_name, last_name, department, salary, hire_date)
VALUES
    ('Alex', 'Brown', 'IT', 50000, CURRENT_DATE),
    ('Emma', 'Davis', 'HR', 55000, CURRENT_DATE),
    ('Daniel', 'Miller', 'Finance', 60000, CURRENT_DATE),
    ('Sophia', 'Wilson', 'IT', 65000, CURRENT_DATE),
    ('Oliver', 'Taylor', 'HR', 70000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (
    ('Alex', 'Brown'),
    ('Emma', 'Davis'),
    ('Daniel', 'Miller'),
    ('Sophia', 'Wilson'),
    ('Oliver', 'Taylor')
);



CREATE TABLE employee_archive
(LIKE employees INCLUDING ALL);

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';


UPDATE projects
SET end_date = end_date + 30
WHERE budget > 50000
  AND dept_id IN (
      SELECT departments.dept_id
      FROM departments
      JOIN employees
        ON employees.department = departments.dept_name
      GROUP BY departments.dept_id
      HAVING COUNT(*) > 3
  );