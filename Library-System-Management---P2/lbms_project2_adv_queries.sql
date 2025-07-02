-- SQL project - Library Management - Query 2
-- Advanced SQL Operations

SELECT * FROM book_issued_cnt
SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM members
SELECT * FROM return_status

/*	1.Identify Members with Overdue Books
	Write a query to identify members who have overdue books (assume a 30-day return period). 
	Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter the books in return
-- overdue > 30-days

SELECT 
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	r.return_date,
	DATE '2024-08-24' - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
ON ist.issued_member_id = m.member_id
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
LEFT JOIN
return_status as r
ON r.issued_id = ist.issued_id
WHERE 
	r.return_date is NULL
	AND (DATE '2024-08-24' - ist.issued_date) > 30;
	
	
/*
Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned
(based on entries in the return_status table).
*/

--Gendral way to make updation

/*SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-330-25864-8';

SELECT * FROM books
WHERE isbn = '978-0-330-25864-8'

SELECT * FROM return_status
WHERE issued_id = 'IS106'

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-330-25864-8'

INSERT INTO return_status(return_id, issued_id, return_date)
VALUES
('RS!25','IS130',Date..)

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-330-25864-8'
*/

-- Store Procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	-- Declare all the variables created inside BEGIN;
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(75);

BEGIN
	-- Logic for the code:
	
	-- Inserting into return based on users input
	INSERT INTO return_status(return_id, issued_id, return_date)
	VALUES
	(p_return_id, p_issued_id, CURRENT_DATE);
	
	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thankyou For Returning The book: %', v_book_name;
END;
$$


-- Testing Function add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1'

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1' 

SELECT * FROM return_status
WHERE issued_id = 'IS135'

-- Calling the function
CALL add_return_records('R138','IS135');


/*Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 2 months.*/

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;

/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2