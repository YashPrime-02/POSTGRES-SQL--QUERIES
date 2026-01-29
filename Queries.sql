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
-- BASIC SELECT (READ DATA)
-- ======================================

-- Select ALL columns and ALL rows from employees table
SELECT * FROM employees;


-- ======================================
-- WHERE : FILTER DATA
-- ======================================

-- Get employees who work in IT department
SELECT * FROM employees
WHERE dept = 'IT';

-- Get employees whose salary is more than 50000
SELECT * FROM employees
WHERE salary > 50000;

-- Get employees hired after 2020
SELECT * FROM employees
WHERE hire_date > '2020-01-01';

-- Get employees from IT department AND salary greater than 50000
SELECT * FROM employees
WHERE dept = 'IT' AND salary > 50000;

-- Get employees who are NOT from HR department
SELECT * FROM employees
WHERE dept != 'HR';

-- Get employees whose department is not assigned (NULL)
SELECT * FROM employees
WHERE dept IS NULL;


-- ======================================
-- IN OPERATOR : MULTIPLE VALUES FILTER
-- ======================================

-- IN is used when we want to match a column
-- against multiple values (OR condition made easy)

-- Employees working in IT or HR department
SELECT * FROM employees
WHERE dept IN ('IT', 'HR');
-- Same as:
-- WHERE dept = 'IT' OR dept = 'HR'


-- Employees whose salary is either 45000 or 50000
SELECT * FROM employees
WHERE salary IN (45000, 50000);


-- ======================================
-- NOT IN OPERATOR : EXCLUDE VALUES
-- ======================================

-- NOT IN is used to EXCLUDE multiple values

-- Employees who are NOT in IT or HR department
SELECT * FROM employees
WHERE dept NOT IN ('IT', 'HR');


-- Employees whose salary is NOT 45000 or 50000
SELECT * FROM employees
WHERE salary NOT IN (45000, 50000);


-- ======================================
-- BETWEEN OPERATOR : RANGE FILTER
-- ======================================

-- BETWEEN is used to filter values within a RANGE
-- It INCLUDES both start and end values (inclusive)

-- Employees with salary between 45000 and 55000
SELECT * FROM employees
WHERE salary BETWEEN 45000 AND 55000;
-- means: >= 45000 AND <= 55000


-- Employees hired between 2019 and 2021
SELECT * FROM employees
WHERE hire_date BETWEEN '2019-01-01' AND '2021-12-31';


-- ======================================
-- NOT BETWEEN OPERATOR : EXCLUDE RANGE
-- ======================================

-- NOT BETWEEN is used to EXCLUDE a range of values

-- Employees with salary NOT between 45000 and 55000
SELECT * FROM employees
WHERE salary NOT BETWEEN 45000 AND 55000;


-- Employees hired NOT between 2019 and 2021
SELECT * FROM employees
WHERE hire_date NOT BETWEEN '2019-01-01' AND '2021-12-31';



-- ======================================
-- DISTINCT : REMOVE DUPLICATES
-- ======================================

-- Get unique department names (no duplicates)
SELECT DISTINCT dept FROM employees;

-- Get unique salary values
SELECT DISTINCT salary FROM employees;

-- Get unique combinations of department and salary
SELECT DISTINCT dept, salary
FROM employees;


-- ======================================
-- ORDER BY : SORT DATA
-- ======================================

-- Sort employees by salary (low to high)
SELECT * FROM employees
ORDER BY salary ASC;

-- Sort employees by salary (high to low)
SELECT * FROM employees
ORDER BY salary DESC;

-- Sort employees by hire date (oldest first)
SELECT * FROM employees
ORDER BY hire_date ASC;

-- Sort employees by department first, then salary (highest first)
SELECT * FROM employees
ORDER BY dept, salary DESC;


-- ======================================
-- LIMIT : RESTRICT NUMBER OF ROWS
-- ======================================

-- Show only first 5 employees
SELECT * FROM employees
LIMIT 5;

-- Show top 3 highest paid employees
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 3;

-- Show latest 2 hired employees
SELECT * FROM employees
ORDER BY hire_date DESC
LIMIT 2;





-- ======================================
-- LIKE : PATTERN MATCHING (TEXT SEARCH)
-- ======================================

-- Find employees whose first name starts with 'A'
SELECT * FROM employees
WHERE fname LIKE 'A%';

-- Find employees whose first name ends with 'a'
SELECT * FROM employees
WHERE fname LIKE '%a';

-- Find employees whose email contains 'example'
SELECT * FROM employees
WHERE email LIKE '%example%';

-- Find employees whose first name has exactly 5 letters
SELECT * FROM employees
WHERE fname LIKE '_____';

--  Find employees whose first name has exactly 4 letters and 'a' as second letter
SELECT * FROM employees
WHERE fname LIKE '_a__';


-- Find employees whose:
-- 1. First name has 'a' as the SECOND letter
-- 2. First name ENDS with 'h'

SELECT * FROM employees
WHERE fname LIKE '_a%h';


-- Case-insensitive search (PostgreSQL special)
-- Find names starting with 'p' or 'P'
SELECT * FROM employees
WHERE fname ILIKE 'p%';


-- ======================================
-- COMBINED REAL-WORLD QUERIES
-- ======================================

-- Top 3 highest paid employees from IT department
SELECT * FROM employees
WHERE dept = 'IT'
ORDER BY salary DESC
LIMIT 3;

-- Unique departments where employees were hired after 2019
SELECT DISTINCT dept
FROM employees
WHERE hire_date > '2019-01-01';

-- Employees whose name starts with 'R' and salary above 50000
SELECT * FROM employees
WHERE fname LIKE 'R%' AND salary > 50000;


-- ======================================
-- QUICK CHECK QUERIES
-- ======================================

-- Count total number of employees
SELECT COUNT(*) FROM employees;

-- Count employees per department
SELECT dept, COUNT(*)
FROM employees
GROUP BY dept;

-- ======================================
-- AGGREGATE FUNCTIONS : SUM, AVG, MAX, MIN
-- ======================================


-- ----------------------
-- MAX : Highest value
-- ----------------------

-- Highest salary in the company
SELECT MAX(salary) 
FROM employees;


-- Get the first name of employee(s)
-- who have the HIGHEST salary in the company

SELECT fname
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);

-- Explanation:
-- 1. Inner query finds the maximum salary in the table
-- 2. Outer query finds employee(s) whose salary equals that max value


-- ----------------------
-- MIN : Lowest value
-- ----------------------

-- Lowest salary in the company
SELECT MIN(salary) 
FROM employees;


-- ----------------------
-- SUM : Total value
-- ----------------------

-- Total salary paid to all employees
SELECT SUM(salary) 
FROM employees;

-- Total salary paid to IT department only
SELECT SUM(salary)
FROM employees
WHERE dept = 'IT';


-- ----------------------
-- AVG : Average value
-- ----------------------

-- Average salary of all employees
SELECT AVG(salary)
FROM employees;

-- Average salary of HR department
SELECT AVG(salary)
FROM employees
WHERE dept = 'HR';


-- ======================================
-- AGGREGATES WITH GROUP BY
-- ======================================

-- List of departments (unique)
SELECT dept from employees GROUP BY dept;

-- Count of employees in each department
SELECT dept,COUNT(emp_id) from employees GROUP BY dept;

-- SUM of salaries in each department
SELECT dept,SUM(salary) from employees GROUP BY dept;


-- Group by department
-- and calculate average salary for each department

SELECT dept, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept;


-- Highest salary in each department
SELECT dept, MAX(salary)
FROM employees
GROUP BY dept;

-- Lowest salary in each department
SELECT dept, MIN(salary)
FROM employees
GROUP BY dept;

-- Total salary per department
SELECT dept, SUM(salary)
FROM employees
GROUP BY dept;

-- Average salary per department
SELECT dept, AVG(salary)
FROM employees
GROUP BY dept;


-- ======================================
-- REAL-WORLD COMBINATION EXAMPLES
-- ======================================

-- Departments where average salary is greater than 50000
-- HAVING is used to filter aggregated results
SELECT dept, AVG(salary)
FROM employees
GROUP BY dept
HAVING AVG(salary) > 50000;


-- IT department salary stats
SELECT 
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary,
    AVG(salary) AS average_salary,
    SUM(salary) AS total_salary
FROM employees
WHERE dept = 'IT';


-- ======================================
-- STRING FUNCTION QUERIES (employees DB)
-- ======================================


-- 1. CONCAT : Combine first name and last name
SELECT CONCAT(fname, ' ', lname) AS full_name
FROM employees;


-- 2. CONCAT_WS : Combine multiple columns with separator
SELECT CONCAT_WS( ' - ', fname, lname, email) AS employee_details, dept
FROM employees;


-- 2.5 Example with emp_id = 1
SELECT CONCAT_WS( ' : ', fname, lname) AS employee_details, email, dept,salary
FROM employees WHERE emp_id =1;


-- 3. SUBSTR : Get first 3 letters of first name
SELECT fname,
       SUBSTR(fname, 1, 3) AS short_name
FROM employees;


-- 4. LEFT : Get first 2 characters of first name
SELECT fname,
       LEFT(fname, 2) AS first_two_letters
FROM employees;


-- 5. RIGHT : Get last 2 characters of last name
SELECT lname,
       RIGHT(lname, 2) AS last_two_letters
FROM employees;


-- 5.5. RIGHT : Get MIDDLE characters of last name
SELECT lname,
       RIGHT(lname, 2) AS last_two_letters
FROM employees;

-- Get middle character(s) for all names
-- 1 char for odd length
-- 2 chars for even length

SELECT fname,
       CASE
           WHEN LENGTH(fname) % 2 = 1
           THEN SUBSTR(fname, (LENGTH(fname) + 1) / 2, 1)
           ELSE SUBSTR(fname, (LENGTH(fname) / 2), 2)
       END AS middle_character
FROM employees;





-- 6. LENGTH : Get length of first name
SELECT fname,
       LENGTH(fname) AS name_length
FROM employees;


-- 7. UPPER : Convert first name to uppercase
SELECT UPPER(fname) AS upper_name
FROM employees;


-- 8. LOWER : Convert email to lowercase
SELECT LOWER(email) AS lower_email
FROM employees;


-- 9. TRIM : Remove extra spaces (demo example)
SELECT TRIM('   yash mishra   ') AS trimmed_text;


-- 10. REPLACE : Change email domain
SELECT email,
       REPLACE(email, 'example.com', 'company.com') AS updated_email
FROM employees;


-- 11. POSITION : Find position of '@' in email
SELECT email,
       POSITION('@' IN email) AS at_position
FROM employees;


-- 12. SUBSTR + POSITION : Extract email domain
SELECT email,
       SUBSTR(email, POSITION('@' IN email) + 1) AS email_domain
FROM employees;


-- 13. STRING_AGG : Group employee names by department
SELECT dept,
       STRING_AGG(fname, ', ') AS employee_names
FROM employees
GROUP BY dept;


-- 14. Full name in UPPERCASE
SELECT UPPER(CONCAT(fname, ' ', lname)) AS full_name_upper
FROM employees;


-- 15. Employees whose first name length > 4
SELECT fname
FROM employees
WHERE LENGTH(fname) > 4;


-- 16. First name starts with same letter as last name
SELECT fname, lname
FROM employees
WHERE LEFT(fname, 1) = LEFT(lname, 1);


-- 17. Extract first letter of first name and last name
SELECT fname, lname,
       LEFT(fname, 1) AS fname_initial,
       LEFT(lname, 1) AS lname_initial
FROM employees;


-- 18. Email username (before @)
SELECT email,
       SUBSTR(email, 1, POSITION('@' IN email) - 1) AS email_username
FROM employees;




-- SOME PRACTICE QUESTIONS 

-- DISTINCT removes duplicate department names
-- Shows all unique departments present in employees table

SELECT DISTINCT dept
FROM employees;

-- ORDER BY salary DESC sorts salary from highest to lowest

SELECT *
FROM employees
ORDER BY salary DESC;


-- LIMIT restricts number of rows returned
-- ORDER BY salary DESC ensures top salaries come first

SELECT *
FROM employees
ORDER BY salary DESC
LIMIT 3;



-- LIKE 'A%' means:
-- 'A' at the start, followed by any characters

SELECT *
FROM employees
WHERE fname LIKE 'A%';

-- CASE INSESITIVE
SELECT *
FROM employees
WHERE fname ILIKE 'a%';

-- LENGTH() counts number of characters in lname
-- Only rows with exactly 4 characters are returned

SELECT *
FROM employees
WHERE LENGTH(lname) = 4;



-- REVERSE() reverses characters in a string

SELECT fname,
       REVERSE(fname) AS reversed_fname
FROM employees;




-- ======================================
-- ALTER TABLE QUERIES
-- ======================================


-- Add a new column called phone_number
-- VARCHAR because phone numbers are not used in calculations
SELECT * FROM employees

ALTER TABLE employees
ADD COLUMN phone_number VARCHAR(15);


-- Remove default value from salary column

ALTER TABLE employees
ALTER COLUMN salary DROP DEFAULT;



--- Drop the phone_number column
ALTER TABLE employees
DROP COLUMN phone_number;



-- Add column 'status' with default value
-- Existing rows will get 'ACTIVE'

ALTER TABLE employees
ADD COLUMN status VARCHAR(10) DEFAULT 'ACTIVE';

-- Verify
SELECT emp_id, fname, status FROM employees;




-- Rename column 'dept' to 'department'
-- Common refactor in real projects

ALTER TABLE employees
RENAME COLUMN dept TO department;

-- Verify
SELECT emp_id, fname, department FROM employees;


-- Change salary from INT to BIGINT
-- Useful when salary values may grow large

ALTER TABLE employees
ALTER COLUMN salary TYPE BIGINT;

-- Verify
SELECT salary FROM employees;

-- Change default salary to 35000 for future inserts

ALTER TABLE employees
ALTER COLUMN salary SET DEFAULT 35000;


-- Remove default value from salary column

ALTER TABLE employees
ALTER COLUMN salary DROP DEFAULT;



-- Add CHECK constraint to ensure salary is Positive

ALTER TABLE employees
ADD CONSTRAINT salary_positive CHECK (salary > 0);

-- Remove CHECK constraint
-- Constraint name must match exactly

ALTER TABLE employees
DROP CONSTRAINT salary_positive;


-- Add MOBILE_NUMBER column with CHECK constraint
-- Ensures mobile number is exactly 10 characters long
ALTER TABLE employees
ADD COLUMN MOBILE_NUMBER VARCHAR(15) CHECK (LENGTH(MOBILE_NUMBER) = 10);

SELECT * FROM employees


-- Update existing rows to have a default mobile number

-- 1. Add column first (already done)
-- 2. Update existing rows
UPDATE employees
SET mobile_number = '9999999999'
WHERE mobile_number IS NULL;

-- 3. Enforce NOT NULL
ALTER TABLE employees
ALTER COLUMN mobile_number SET NOT NULL;



-- CASE STATEMENT EXAMPLES
SELECT fname, salary,

CASE 
    WHEN salary >=50000 THEN 'High'
	WHEN salary >=40000 THEN 'Mid'
	WHEN salary IN (30000,39999) THEN ' Lower Mid'
	ELSE 'Low'
END AS Salary_Category
FROM employees;

--CASE BONUS CALCULATION
SELECT fname, salary,

CASE 
    WHEN salary >=50000 THEN salary * 0.10
    WHEN salary >=40000 THEN salary * 0.07
    WHEN salary IN (30000,39999) THEN salary * 0.05
    ELSE 0
END AS Bonus_Amount
FROM employees;


-- Categorize employees into bonus groups
-- and count how many employees fall into each group

SELECT
    CASE
        WHEN salary >= 50000 THEN 'High'
        WHEN salary >= 40000 THEN 'Mid'
        ELSE 'Low'
    END AS Salary_Category, COUNT(emp_id) AS employee_count
FROM employees
GROUP BY Salary_Category;



-- Categorize employees based on experience (joining year)

SELECT fname, hire_date,
CASE
    WHEN hire_date <= '2019-12-31' THEN 'Senior'
    WHEN hire_date <= '2021-12-31' THEN 'Mid Level'
    ELSE 'Junior'
END AS experience_level
FROM employees;




------------------------------------------------------------------------

-- FOREIGN KEYS EXAMPLE

-- Parent table
-- Stores customer details
-- cust_id uniquely identifies each customer

CREATE TABLE customers (
    cust_id SERIAL PRIMARY KEY,
    cust_name VARCHAR(100) NOT NULL
);

-- Child table
-- Child table
-- Each order is linked to a customer using cust_id

CREATE TABLE orders (
    ord_id SERIAL PRIMARY KEY,
    ord_date DATE NOT NULL,
    price NUMERIC NOT NULL,
    cust_id INTEGER NOT NULL,

    -- FOREIGN KEY enforces relationship
    FOREIGN KEY (cust_id)
    REFERENCES customers (cust_id)
);



-- Insert customers (parent table first)

INSERT INTO customers (cust_name)
VALUES
('Yash'),
('Priya'),
('Arjun');


-- Insert orders (child table)
-- Insert orders
-- cust_id must already exist in customers table

INSERT INTO orders (ord_date, price, cust_id)
VALUES
('2024-01-10', 1500, 1),
('2024-01-12', 2500, 1),
('2024-01-15', 1800, 2),
('2024-01-20', 3200, 3);



-- ======================================
-- CROSS JOIN (Cartesian Product)
-- ======================================

-- CROSS JOIN combines EVERY row from customers
-- with EVERY row from orders
-- Number of rows = customers_count × orders_count
-- ⚠️ Very dangerous on large tables

SELECT *
FROM customers
CROSS JOIN orders;

-- Example:
-- If customers = 3 rows
-- and orders = 4 rows
-- result = 12 rows

-- Use case:
-- Rarely used
-- Mainly for testing, matrix-like data, or demo purposes


-- ======================================
-- INNER JOIN (Join by Common Column)
-- ======================================

-- INNER JOIN returns ONLY matching records
-- Rows appear only when cust_id exists in BOTH tables

SELECT *
FROM customers cust
INNER JOIN orders ord
ON cust.cust_id = ord.cust_id;

-- Explanation:
-- cust and ord are table aliases (short names)
-- cust.cust_id = ord.cust_id is the join condition
-- If a customer has NO orders → they will NOT appear

-- Most commonly used JOIN in real projects


-- inner join with GROUP BY (though not typical here)
SELECT cust.cust_name, COUNT (ord.ord_id)
FROM customers cust
INNER JOIN orders ord
ON cust.cust_id = ord.cust_id
GROUP BY cust.cust_name;



-- inner join with GROUP BY (though not typical here)
SELECT cust.cust_name, SUM (ord.price)
FROM customers cust
INNER JOIN orders ord
ON cust.cust_id = ord.cust_id
GROUP BY cust.cust_name;


--LEFT JOIN

SELECT * FROM customers 
cust LEFT JOIN orders ord 
ON cust.cust_id =ord.cust_id;

--RIGHT JOIN
SELECT * FROM customers 
cust RIGHT JOIN orders ord 
ON cust.cust_id =ord.cust_id;




-- MANY ONE JOIN 
-- ======================================
-- INSERT DATA INTO STUDENTS TABLE
-- ======================================
-- Adds student records
-- s_id is auto-generated (SERIAL)

INSERT INTO students(name) VALUES
('YASH'),
('DIVYANSHU'),
('ALEX');


-- ======================================
-- INSERT DATA INTO COURSES TABLE
-- ======================================
-- Adds courses with their fees
-- fee represents course price

INSERT INTO courses(name, fee) 
VALUES
('Maths', 500),
('Physics', 600),
('English', 700);


-- ======================================
-- INSERT DATA INTO ENROLLMENT TABLE
-- ======================================
-- Links students to courses
-- enrollment_date shows when student joined course

INSERT INTO enrollment (s_id, c_id, enrollment_date)
VALUES
(1, 1, '2024-01-01'),
(1, 2, '2024-01-15'),
(2, 1, '2024-02-01'),
(2, 3, '2024-02-15'),
(3, 3, '2024-03-25');


-- ======================================
-- VIEW RAW TABLE DATA (DEBUG / ADMIN)
-- ======================================

-- View all students
SELECT * FROM students;

-- View all courses
SELECT * FROM courses;

-- View all enrollments
SELECT * FROM enrollment;


-- ======================================
-- STUDENT + COURSE DETAILS (JOIN QUERY)
-- ======================================
-- Shows which student enrolled in which course
-- Includes course fee and enrollment date

SELECT 
    s.name AS student_name,
    c.name AS course_name,
    c.fee,
    e.enrollment_date
FROM enrollment e
JOIN students s ON e.s_id = s.s_id
JOIN courses c ON c.c_id = e.c_id;


-- ======================================
-- COURSES TAKEN BY A SPECIFIC STUDENT
-- ======================================
-- Used in student profile page
-- Here: student with s_id = 1

SELECT 
    c.name AS course_name,
    c.fee,
    e.enrollment_date
FROM enrollment e
JOIN courses c ON e.c_id = c.c_id
WHERE e.s_id = 1;


-- ======================================
-- STUDENTS ENROLLED IN A SPECIFIC COURSE
-- ======================================
-- Used in course detail / admin view
-- Here: course with c_id = 1

SELECT 
    s.name AS student_name,
    e.enrollment_date
FROM enrollment e
JOIN students s ON e.s_id = s.s_id
WHERE e.c_id = 1;


-- ======================================
-- COUNT STUDENTS PER COURSE
-- ======================================
-- LEFT JOIN ensures courses with ZERO enrollments are shown

SELECT 
    c.name AS course_name,
    COUNT(e.s_id) AS total_students
FROM courses c
LEFT JOIN enrollment e ON c.c_id = e.c_id
GROUP BY c.name;


-- ======================================
-- TOTAL REVENUE PER COURSE
-- ======================================
-- Calculates how much money each course earned

SELECT 
    c.name AS course_name,
    SUM(c.fee) AS total_revenue
FROM enrollment e
JOIN courses c ON e.c_id = c.c_id
GROUP BY c.name;


-- ======================================
-- TOTAL COURSES PER STUDENT
-- ======================================
-- Shows how many courses each student enrolled in
-- LEFT JOIN keeps students with zero courses

SELECT 
    s.name AS student_name,
    COUNT(e.c_id) AS total_courses
FROM students s
LEFT JOIN enrollment e ON s.s_id = e.s_id
GROUP BY s.name;


-- ======================================
-- STUDENTS WITH NO ENROLLMENTS
-- ======================================
-- Finds students who are not enrolled in any course

SELECT s.name
FROM students s
LEFT JOIN enrollment e ON s.s_id = e.s_id
WHERE e.s_id IS NULL;


-- ======================================
-- LATEST ENROLLMENTS (ACTIVITY FEED)
-- ======================================
-- Shows recent student enrollments
-- Used for dashboards / activity logs

SELECT 
    s.name AS student_name,
    c.name AS course_name,
    e.enrollment_date
FROM enrollment e
JOIN students s ON e.s_id = s.s_id
JOIN courses c ON e.c_id = c.c_id
ORDER BY e.enrollment_date DESC
LIMIT 5;


-- PROJECT E STORE 

-- =====================================================
-- CUSTOMERS TABLE
-- =====================================================
-- This table stores customer information
-- One customer can place MANY orders (one-to-many)

CREATE TABLE customers (
    cust_id SERIAL PRIMARY KEY,      -- Auto-increment unique ID for each customer
    cust_name VARCHAR(100) NOT NULL  -- Customer name, cannot be empty
);



-- =====================================================
-- ORDERS TABLE
-- =====================================================
-- This table stores orders placed by customers
-- Each order belongs to ONE customer

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,                 -- Unique order ID
    order_date DATE NOT NULL DEFAULT CURRENT_DATE, -- If date not provided, today’s date is used
    cust_id INT NOT NULL,                        -- Stores which customer placed the order

    -- Foreign key ensures cust_id must exist in customers table
    FOREIGN KEY (cust_id)
    REFERENCES customers (cust_id)
);



-- =====================================================
-- PRODUCTS TABLE
-- =====================================================
-- This table stores products available in the shop
-- Price of product is stored here

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,       -- Unique product ID
    product_name VARCHAR(100) NOT NULL,  -- Product name
    price NUMERIC(10,2) NOT NULL          -- Product price (money value)
);



-- =====================================================
-- ORDER_ITEMS TABLE (JUNCTION TABLE)
-- =====================================================
-- This table connects orders and products
-- Handles MANY-TO-MANY relationship
-- Also stores quantity of each product in an order

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY, -- Unique row ID
    order_id INT NOT NULL,             -- References an order
    product_id INT NOT NULL,           -- References a product
    quantity INT NOT NULL CHECK (quantity > 0), -- Quantity must be greater than 0

    -- Ensures order exists
    FOREIGN KEY (order_id)
    REFERENCES orders (order_id),

    -- Ensures product exists
    FOREIGN KEY (product_id)
    REFERENCES products (product_id)
);



-- =====================================================
-- INSERT DATA INTO CUSTOMERS
-- =====================================================
-- Adds customers into the system

INSERT INTO customers (cust_name)
VALUES ('Yash'), ('Priya');



-- =====================================================
-- INSERT DATA INTO PRODUCTS
-- =====================================================
-- Adds products with prices

INSERT INTO products (product_name, price)
VALUES
('Laptop', 55000),
('Mouse', 500),
('Keyboard', 1500);



-- =====================================================
-- INSERT DATA INTO ORDERS
-- =====================================================
-- Creates orders for customers
-- cust_id links order to customer

INSERT INTO orders (cust_id)
VALUES (1), (1), (2);



-- =====================================================
-- INSERT DATA INTO ORDER_ITEMS
-- =====================================================
-- Links products to orders with quantity

INSERT INTO order_items (order_id, product_id, quantity)
VALUES
(1, 1, 1),   -- Order 1 → Laptop x1
(1, 2, 2),   -- Order 1 → Mouse x2
(2, 3, 1),   -- Order 2 → Keyboard x1
(3, 2, 1);   -- Order 3 → Mouse x1



-- =====================================================
-- FINAL DISPLAY QUERY
-- =====================================================
-- Shows:
-- Customer name
-- Order ID and order date
-- Product name, price, quantity
-- Total price per product (price * quantity)

SELECT
    c.cust_name,
    o.order_id,
    o.order_date,
    p.product_name,
    p.price,
    oi.quantity,
    (p.price * oi.quantity) AS item_total
FROM customers c
JOIN orders o
    ON c.cust_id = o.cust_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
ORDER BY o.order_id;
-- This query joins all four tables to get complete order details



-- ======================================
-- FINAL CHECK
-- ======================================

-- View final table data
SELECT * FROM person;

-- Check table structure
-- \d person
