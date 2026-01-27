-- =====================================================
-- POSTGRESQL LEARNER GUIDE - BASIC QUERIES
-- =====================================================


-- ======================================
-- COMMON POSTGRESQL DATA TYPES (REFERENCE)
-- ======================================

-- =====================================================
-- POSTGRESQL NUMERIC DATA TYPES (OFFICIAL REFERENCE)
-- =====================================================

-- INTEGER FAMILY (WHOLE NUMBERS)

-- SMALLINT   → 2 bytes  
-- Range: -32768 to +32767  
-- Use when values are very small (age, small counters)

-- INTEGER / INT → 4 bytes  
-- Range: -2147483648 to +2147483647  
-- Default choice for most integer columns (IDs, counts)

-- BIGINT     → 8 bytes  
-- Range: -9223372036854775808 to +9223372036854775807  
-- Use for very large values (big counters, financial systems, logs)


-- EXACT DECIMAL TYPES (NO ROUNDING ERRORS)

-- DECIMAL(p, s) / NUMERIC(p, s) → variable size, exact precision  
-- p = total digits, s = digits after decimal  
-- Max before decimal: 131072 digits  
-- Max after decimal: 16383 digits  

-- Example: salary NUMERIC(10,2) → up to 99999999.99  
-- Use for money, salary, financial values (must be exact)


-- FLOATING POINT TYPES (FAST BUT INEXACT)

-- REAL (float4) → 4 bytes  
-- Precision: ~6 decimal digits  
-- Inexact → rounding errors possible  

-- DOUBLE PRECISION (float8) → 8 bytes  
-- Precision: ~15 decimal digits  
-- Inexact but more accurate than REAL  

-- Use for scientific values, measurements, GPS, physics (not money)


-- AUTO-INCREMENT TYPES (LEGACY STYLE)

-- SMALLSERIAL → 2 bytes auto-increment  
-- Range: 1 to 32767  

-- SERIAL → 4 bytes auto-increment  
-- Range: 1 to 2147483647  
-- Internally: INTEGER + SEQUENCE  

-- BIGSERIAL → 8 bytes auto-increment  
-- Range: 1 to 9223372036854775807  
-- Internally: BIGINT + SEQUENCE  

-- Note:
-- SERIAL is legacy.
-- Modern PostgreSQL prefers:
-- GENERATED ALWAYS AS IDENTITY

-- BOOLEAN              → true / false

-- DATE                 → only date (YYYY-MM-DD)
-- TIME                 → only time (HH:MM:SS)
-- TIMESTAMP            → date + time

-- FLOAT / REAL         → decimal numbers (approx)
-- NUMERIC(p,s)         → exact decimal (money, salary)

-- JSON / JSONB         → JSON data storage

-- UUID                 → unique id format

-- DEFAULT              → default value if not provided
-- NOT NULL             → column cannot be NULL
-- UNIQUE               → no duplicate values allowed
-- PRIMARY KEY          → unique + not null combined




-- ======================================
-- TABLE WITH CONSTRAINTS (FOR LEARNING)
-- ======================================

DROP TABLE IF EXISTS person;

CREATE TABLE person (
    -- id INT PRIMARY KEY,               
    -- ↑ Manual ID insertion required
    -- Problem:
    -- 1. You must always provide id while inserting
    -- 2. Risk of duplicate IDs
    -- 3. Not convenient for real applications

    id SERIAL PRIMARY KEY,              
    -- SERIAL automatically creates:
    -- 1. An INTEGER column
    -- 2. A SEQUENCE object behind the scenes
    -- 3. Auto-increment behavior on every insert
    --
    -- Why we replace INT with SERIAL:
    -- ✔ No need to manually pass id
    -- ✔ Guarantees unique increasing values
    -- ✔ Prevents duplicate primary key mistakes
    -- ✔ Standard practice in most PostgreSQL projects
    --
    -- Internally equivalent to:
    -- id INTEGER NOT NULL DEFAULT nextval('person_id_seq')

    name VARCHAR(100) NOT NULL,        
    -- must always have a name, NULL not allowed

    city VARCHAR(100) DEFAULT 'Delhi', 
    -- if city not provided, default value will be 'Delhi'

    age INT DEFAULT 18                 
    -- age is optional, if not passed → 18 is stored
);

-- ======================================
-- CREATE (INSERT) - CORRECT & ERROR CASES
-- ======================================

-- 1. Correct insert → works
INSERT INTO person (id, name, city, age)
VALUES (101, 'Raju', 'Delhi', 25);

-- 2. Missing optional column (city) → becomes NULL
INSERT INTO person (id, name, age)
VALUES (102, 'Amit', 22);

-- 3. Missing optional age → default 18 is used
INSERT INTO person (id, name, city)
VALUES (103, 'Neha', 'Pune');

-- 4. Missing required column (name) → ERROR
-- ERROR: null value in column "name" violates not-null constraint
-- INSERT INTO person (id, city)
-- VALUES (104, 'Mumbai');

-- 5. Duplicate primary key → ERROR
-- ERROR: duplicate key value violates unique constraint "person_pkey"
-- INSERT INTO person (id, name, city)
-- VALUES (101, 'Duplicate', 'Jaipur');

-- 6. Explicit NULL in NOT NULL column → ERROR
-- INSERT INTO person (id, name, city)
-- VALUES (105, NULL, 'Chennai');

-- 7. Less values than columns (no column list) → ERROR
-- INSERT INTO person
-- VALUES (106, 'Sita');

-- 8. Wrong datatype → ERROR
-- INSERT INTO person (id, name, city)
-- VALUES ('abc', 'Karan', 'Noida');

-- 9. Safe insert (best practice)
INSERT INTO person (id, name)
VALUES (106, 'Karan');


-- ======================================
-- READ (SELECT QUERIES)
-- ======================================

-- Read all data
SELECT * FROM person;

-- Read specific columns
SELECT id, name FROM person;

-- Filter by condition
SELECT * FROM person
WHERE city = 'Delhi';

-- Multiple conditions
SELECT * FROM person
WHERE age > 20 AND city IS NOT NULL;

-- Order results
SELECT * FROM person
ORDER BY age DESC;

-- Limit results
SELECT * FROM person
LIMIT 2;

-- Count rows
SELECT COUNT(*) FROM person;

-- Distinct values
SELECT DISTINCT city FROM person;


-- ======================================
-- UPDATE (MODIFY DATA)
-- ======================================

-- Update single column
UPDATE person
SET city = 'Noida'
WHERE id = 101;

-- Update multiple columns
UPDATE person
SET name = 'Raj Kumar', age = 26
WHERE id = 101;

-- Update with condition
UPDATE person
SET age = age + 1
WHERE city = 'Pune';

-- Dangerous update (without WHERE) → updates all rows
-- UPDATE person SET age = 30;


-- ======================================
-- DELETE (REMOVE DATA)
-- ======================================

-- Delete one record
DELETE FROM person
WHERE id = 102;

-- Delete by condition
DELETE FROM person
WHERE city IS NULL;

-- Dangerous delete (removes all rows)
-- DELETE FROM person;




-- ======================================
-- BANK DATABASE : EMPLOYEES TABLE (LEARNER VERSION)
-- ======================================


-- Create employees table with proper constraints
CREATE TABLE employees (

    emp_id SERIAL PRIMARY KEY,
    -- SERIAL → auto-increment integer value
    -- PRIMARY KEY → unique + not null
    -- Automatically generates employee id for every new row
    -- We do NOT pass emp_id manually during insert

    fname VARCHAR(100) NOT NULL,
    -- First name is mandatory
    -- NOT NULL ensures no employee record exists without first name

    lname VARCHAR(100) NOT NULL,
    -- Last name is mandatory

    email VARCHAR(150) UNIQUE NOT NULL,
    -- UNIQUE → no two employees can have same email
    -- NOT NULL → email must always be provided
    -- Email is commonly used as login / identifier in real systems

    dept VARCHAR(100),
    -- Department is allowed to be NULL
    -- Some employees may not be assigned a department initially

    salary INT DEFAULT 30000,
    -- DEFAULT 30000 → if salary is not passed, 30000 is stored automatically
    -- Good example of business rule at database level

    hire_date DATE NOT NULL
    -- DATE stores only date (YYYY-MM-DD)
    -- NOT NULL → every employee must have a joining date
);


-- ======================================
-- INSERT EMPLOYEE RECORDS
-- ======================================

-- emp_id is not included because SERIAL auto-generates it

INSERT INTO employees (fname, lname, email, dept, salary, hire_date)
VALUES 
('Yash',   'Mishra', 'yashprime@gmail.com',        'IT',        50000, '2020-01-15'),
('Priya',  'Singh',  'priya.singh@example.com',   'HR',        45000, '2019-03-22'),
('Arjun',  'Verma',  'arjun.verma@example.com',   'IT',        55000, '2021-06-01'),
('Suman',  'Patel',  'suman.patel@example.com',   'Finance',   60000, '2018-07-30'),
('Kavita', 'Rao',    'kavita.rao@example.com',    'HR',        47000, '2020-11-10'),
('Amit',   'Gupta',  'amit.gupta@example.com',    'Marketing', 52000, '2020-09-25'),
('Neha',   'Desai',  'neha.desai@example.com',    'IT',        48000, '2019-05-18'),
('Rahul',  'Kumar',  'rahul.kumar@example.com',   'IT',        53000, '2021-02-14'),
('Anjali', 'Mehta',  'anjali.mehta@example.com',  'Finance',   61000, '2018-12-03'),
('Vijay',  'Nair',   'vijay.nair@example.com',    'Marketing', 50000, '2020-04-19');


-- ======================================
-- CONSTRAINT ERROR DEMONSTRATIONS
-- ======================================

-- ❌ Duplicate email test
-- This will fail because email has UNIQUE constraint
-- ERROR: duplicate key value violates unique constraint "employees_email_key"

-- INSERT INTO employees (fname, lname, email, dept, hire_date)
-- VALUES ('Test', 'User', 'yashprime@gmail.com', 'IT', '2022-01-01');


-- ❌ Missing NOT NULL column test
-- fname is NOT NULL → cannot insert without first name
-- ERROR: null value in column "fname" violates not-null constraint

-- INSERT INTO employees (lname, email, hire_date)
-- VALUES ('Test', 'test@example.com', '2022-01-01');



-- ======================================
-- UPDATE EMPLOYEE NAME (LEARNER GUIDE)
-- ======================================

-- First, always VERIFY the record before updating
-- This ensures you are updating the correct employee

SELECT * FROM employees
WHERE email = 'priya.singh@example.com';
-- We use email because:
-- 1. Email is UNIQUE
-- 2. Guarantees exactly one record
-- 3. Safer than using only fname/lname


-- --------------------------------------
-- UPDATE NAME OF PRIYA SINGH
-- --------------------------------------

UPDATE employees
SET fname = 'Priyanka', lname = 'Singh'
WHERE email = 'priya.singh@example.com';

-- Explanation:
-- SET → columns we want to change
-- WHERE → condition to select exact row
-- Using email avoids accidental multiple-row updates


-- --------------------------------------
-- CHECK AFTER UPDATE
-- --------------------------------------

SELECT * FROM employees
WHERE email = 'priya.singh@example.com';



-- ======================================
-- DEFAULT VALUE DEMONSTRATION
-- ======================================

-- Salary is not provided here
-- DEFAULT 30000 will automatically be stored

INSERT INTO employees (fname, lname, email, dept, hire_date)
VALUES ('Rohit', 'Malik', 'rohit.malik@example.com', 'IT', '2022-05-10');


-- ======================================
-- READ (SELECT QUERIES - PRACTICE)
-- ======================================

-- View all employees
SELECT * FROM employees;

-- View only employees from IT department
SELECT * FROM employees
WHERE dept = 'IT';

-- View employees with salary greater than 50000
SELECT * FROM employees
WHERE salary > 50000;

-- Count number of employees in each department
SELECT dept, COUNT(*) 
FROM employees
GROUP BY dept;

-- Show employees ordered by highest salary first
SELECT * FROM employees
ORDER BY salary DESC;




-- ======================================
-- FINAL CHECK
-- ======================================

-- View final table data
SELECT * FROM person;

-- Check table structure
-- \d person
