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


-- Part 2: Creating Basic Views

-- Exercise 2.1: Simple View Creation
DROP VIEW IF EXISTS employee_details;

CREATE VIEW employee_details AS
SELECT e.emp_name, d.dept_name, e.salary, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

-- As you can see from result 4 rows are returned.
-- Tom Brown is excluded because his dept_id is NULL,
-- and INNER JOIN only returns matching records from both tables.


-- Exercise 2.2: View with Aggregation
CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_number,
    AVG(e.salary) AS avg_salary,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name; -- This calculates statistics separately for each department.
--LEFT JOIN keeps all departments, even if they have no employees.

SELECT * FROM dept_statistics
ORDER BY employee_number DESC;


-- Exercise 2.3: View with Multiple Joins
CREATE VIEW project_overview AS
SELECT p.project_name, p.budget, d.dept_name, d.location, COUNT(e.emp_id) AS team_size
FROM projects p
INNER JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, d.dept_id;

SELECT * FROM project_overview;

-- Exercise 2.4: View with Filtering
CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;
-- yes, we see all high-earning employees. output: employees whose salaries are greater than $55,000



-- Part 3: Modifying and Managing Views
-- Exercise 3.1: Replace a View
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name, d.dept_name, e.salary, d.location,
       CASE
           WHEN e.salary > 60000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Standard'
       END AS salary_grade
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

-- Exercise 3.2: Rename a View
ALTER VIEW high_earners RENAME TO top_performers;

SELECT * FROM top_performers;

-- Exercise 3.3: Drop a View
CREATE TEMP VIEW temp_view AS
SELECT e.emp_name, e.salary
FROM employees e
WHERE e.salary < 50000;

SELECT * FROM temp_view;

DROP VIEW IF EXISTS temp_view;

-- Part 4: Updatable Views
-- Exercise 4.1: Create an Updatable View
CREATE VIEW employee_salaries AS
SELECT e.emp_id, e.emp_name, e.dept_id, e.salary
FROM employees e;

SELECT * FROM employee_salaries;

-- Exercise 4.2: Update Through a View
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT * FROM employees WHERE emp_name = 'John Smith';
-- Updated


-- Exercise 4.3: Insert Through a View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employee_salaries
WHERE emp_id = 6;

-- Exercise 4.4: View with CHECK OPTION
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

SELECT * FROM it_employees;

INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
-- WHERE dept_id = 101 — Only IT employees are allowed in the view.
-- WITH LOCAL CHECK OPTION — Prevents inserting or updating rows through the view if they don't satisfy its condition.

-- Part 5: Materialized Views
-- Exercise 5.1: Create a Materialized View
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(e.total_employees, 0) AS total_employees,
    COALESCE(e.total_salaries, 0) AS total_salaries,
    COALESCE(p.total_projects, 0) AS total_projects,
    COALESCE(p.total_budget, 0) AS total_budget
FROM departments d

LEFT JOIN (
    SELECT
        dept_id,
        COUNT(emp_id) AS total_employees,
        SUM(salary) AS total_salaries
    FROM employees
    GROUP BY dept_id
) e ON d.dept_id = e.dept_id

LEFT JOIN (
    SELECT
        dept_id,
        COUNT(project_id) AS total_projects,
        SUM(budget) AS total_budget
    FROM projects
    GROUP BY dept_id
) p ON d.dept_id = p.dept_id

WITH DATA;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

-- Exercise 5.2: Refresh Materialized View
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

-- BEFORE refreshing
SELECT * FROM dept_summary_mv
WHERE dept_id = 101;

-- Even though Charlie Brown has been inserted into employees,
-- the materialized view still shows the old statistics.

REFRESH MATERIALIZED VIEW dept_summary_mv;
-- This command makes PostgreSQL execute the materialized view's query again and update its stored results.

-- AFTER refreshing
SELECT * FROM dept_summary_mv
WHERE dept_id = 101;


-- Exercise 5.3: Concurrent Refresh
CREATE UNIQUE INDEX index_dept_summary
ON dept_summary_mv (dept_id);
-- UNIQUE INDEX Required for concurrent refresh.

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- CONCURRENTLY Updates stored results without blocking readers.
-- ADVANTAGES: it allows other users to continue reading the materialized view during the refresh.
SELECT * FROM dept_summary_mv;



-- Exercise 5.4: Materialized View with NO DATA

CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, d.dept_id
WITH NO DATA;

SELECT * FROM project_stats_mv;

-- Fixing the error
REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;

-- Part 6: Database Roles
-- Exercise 6.1: Create Basic Roles

-- A basic role named analyst (no login)
CREATE ROLE analyst;

-- A role named data_viewer with LOGIN and password 'viewer123'
CREATE ROLE data_viewer
WITH LOGIN PASSWORD 'viewer123';

-- A user named report_user with password 'report456'
CREATE USER report_user
WITH PASSWORD 'report456';

-- VIEW ALL ROLES
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

-- Exercise 6.2: Role with Specific Attributes
CREATE ROLE db_creator
WITH CREATEDB LOGIN PASSWORD 'creator789';
-- CREATEDB Permission to create databases.

CREATE ROLE user_manager
WITH CREATEROLE LOGIN PASSWORD 'manager101';
-- CREATEROLE Permission to create and manage roles.

CREATE ROLE admin_user
WITH SUPERUSER LOGIN PASSWORD 'admin999';

-- Exercise 6.3: Grant Privileges to Roles
GRANT SELECT ON employees, departments, projects TO analyst;
-- Allow analyst to read data from employees, departments, and projects.

GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
-- Give data_viewer all available privileges on the employee_details view.

GRANT SELECT, INSERT ON employees TO report_user;
-- Allow report_user to read and insert employee records.



-- Exercise 6.4: Create Group Roles

-- Create group roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

-- Create users
CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

-- Assign users to groups
GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

-- Give permissions
GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;


-- Exercise 6.5: Revoke Privileges

-- Remove UPDATE permission
REVOKE UPDATE ON employees FROM hr_team;

-- Remove user from group
REVOKE hr_team FROM hr_user2;

-- Remove privileges on view
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;


-- Exercise 6.6: Modify Role Attributes
-- Enable login and set password
ALTER ROLE analyst
WITH LOGIN PASSWORD 'analyst123';

-- Make user_manager a superuser
ALTER ROLE user_manager
WITH SUPERUSER;

-- Remove analyst password
ALTER ROLE analyst
WITH PASSWORD NULL;

-- Limit data_viewer connections
ALTER ROLE data_viewer
WITH CONNECTION LIMIT 5;




-- Part 7: Advanced Role Management
-- Exercise 7.1: Role Hierarchies

CREATE ROLE read_only;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE USER junior_analyst WITH PASSWORD 'junior123';
CREATE USER senior_analyst WITH PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees TO senior_analyst;



-- Exercise 7.2: Object Ownership
CREATE ROLE project_manager
WITH LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics
OWNER TO project_manager;

ALTER TABLE projects
OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

SELECT viewname, viewowner
FROM pg_views
WHERE schemaname = 'public';



-- Exercise 7.3: Reassign and Drop Roles
CREATE ROLE temp_owner WITH LOGIN;

CREATE TABLE temp_table (
    id INT
);

ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;

DROP ROLE temp_owner;



-- Exercise 7.4: Row-Level Security with View
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;



-- Part 8: Practical Scenarios
-- Exercise 8.1: Department Dashboard Vie
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COALESCE(e.employee_count, 0) AS employee_count,
    ROUND(e.avg_salary, 2) AS avg_salary,
    COALESCE(p.project_count, 0) AS active_projects,
    COALESCE(p.total_budget, 0) AS total_budget,
    COALESCE(
        ROUND(p.total_budget / NULLIF(e.employee_count, 0), 2),
        0
    ) AS budget_per_employee
FROM departments d

LEFT JOIN (
    SELECT
        dept_id,
        COUNT(emp_id) AS employee_count,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
) e ON d.dept_id = e.dept_id

LEFT JOIN (
    SELECT
        dept_id,
        COUNT(project_id) AS project_count,
        SUM(budget) AS total_budget
    FROM projects
    GROUP BY dept_id
) p ON d.dept_id = p.dept_id;

-- Exercise 8.2: Audit View
-- Step 1: Add created_date
ALTER TABLE projects
ADD COLUMN created_date TIMESTAMP
DEFAULT CURRENT_TIMESTAMP;

-- Step 2: Create audit view
CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
LEFT JOIN departments d
ON p.dept_id = d.dept_id
WHERE p.budget > 75000;


-- Exercise 8.3: Create Access Control System
-- LEVEL 1: Viewer
CREATE ROLE viewer_role;

GRANT SELECT ON ALL TABLES IN SCHEMA public
TO viewer_role;

GRANT USAGE ON SCHEMA public TO viewer_role;


-- LEVEL 2: Entry
CREATE ROLE entry_role;

GRANT viewer_role TO entry_role;

GRANT INSERT ON employees, projects
TO entry_role;


-- LEVEL 3: Analyst
CREATE ROLE analyst_role;

GRANT entry_role TO analyst_role;

GRANT UPDATE ON employees, projects
TO analyst_role;


-- LEVEL 4: Manager
CREATE ROLE manager_role;

GRANT analyst_role TO manager_role;

GRANT DELETE ON employees, projects
TO manager_role;


-- CREATE USERS
CREATE USER alice WITH PASSWORD 'alice123';
CREATE USER bob WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';


-- ASSIGN ROLES
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;