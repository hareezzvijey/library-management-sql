-- CRUD Operations
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

INSERT INTO books 
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address 

UPDATE members
SET member_address = '456 Elm Avenue'
WHERE member_id = 'C101';


-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';


-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'


-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
issued_member_id,COUNT(issued_id) AS No_of_books
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id) > 1
ORDER BY 2 DESC;

-- CTAS (Create Table As Select)
-- Used CTAS to generate new tables based on query results - each book and total book_issued_count

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title,COUNT(ist.issued_id) as issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

SELECT * FROM book_issued_cnt;


-- Data Analysis & Findings

-- 1.Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic';

-- 2.Find Total Rental Income by Category:
SELECT 
	category,
	SUM(rental_price),
	COUNT(*)
FROM issued_status iss
JOIN books as b
ON b.isbn = iss.issued_book_isbn
GROUP BY category;

-- 3.List Members Who Registered in the Last 180 Days having current date as '2024-09-01':
SELECT * FROM members
WHERE reg_date >= DATE '2024-09-01' - INTERVAL '180 days';

-- 4.List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.positions,
    e1.salary,
    b.*, 
    e2.emp_name AS manager
FROM employees e1
JOIN branch b ON e1.branch_id = b.branch_id
JOIN employees e2 ON e2.emp_id = b.manager_id
WHERE e1.positions <> 'Manager';

-- 5.Create a Table of Books with Rental Price Above a Certain Threshold (here 7.00):
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00

-- 6.Retrieve the List of Books Not Yet Returned:

SELECT 
	 DISTINCT issued_book_name
FROM issued_status ist
LEFT JOIN 
	return_status as rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL
GROUP BY 1