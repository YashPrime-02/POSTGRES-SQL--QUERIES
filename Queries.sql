-- ============================
-- DATABASE & TABLE BASICS
-- ============================

-- Show all databases
-- \l

-- Connect to a database
-- \c your_database_name

-- Show all tables
-- \dt


-- ============================
-- CREATE TABLE
-- ============================

CREATE TABLE person (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100)
);


-- ============================
-- INSERT DATA
-- ============================

-- Insert single row
INSERT INTO person (id, name, city)
VALUES (101, 'Raju', 'Delhi');

-- Insert multiple rows
INSERT INTO person (id, name, city) VALUES
(102, 'Amit', 'Mumbai'),
(103, 'Neha', 'Pune'),
(104, 'Sita', 'Bangalore');


-- ============================
-- SELECT QUERIES
-- ============================

-- Select all rows
SELECT * FROM person;

-- Select specific columns
SELECT id, name FROM person;

-- Select with condition
SELECT * FROM person
WHERE city = 'Delhi';

-- Select with multiple conditions
SELECT * FROM person
WHERE city = 'Delhi' AND id > 100;

-- Order results
SELECT * FROM person
ORDER BY name ASC;

-- Limit results
SELECT * FROM person
LIMIT 2;


-- ============================
-- UPDATE DATA
-- ============================

-- Update one column
UPDATE person
SET city = 'Noida'
WHERE id = 101;

-- Update multiple columns
UPDATE person
SET name = 'Raj Kumar', city = 'Gurgaon'
WHERE id = 101;


-- ============================
-- DELETE DATA
-- ============================

-- Delete specific row
DELETE FROM person
WHERE id = 104;

-- Delete all rows (dangerous)
-- DELETE FROM person;


-- ============================
-- CONSTRAINT & CHECKING
-- ============================

-- Count rows
SELECT COUNT(*) FROM person;

-- Check unique cities
SELECT DISTINCT city FROM person;


