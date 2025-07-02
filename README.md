# library-management-sql
A complete Library Management System built using PostgreSQL. This project includes database design, CRUD operations, CTAS, advanced SQL queries, and stored procedures to manage books, members, employees, branches, and transactions efficiently.

Here's a clean and professional **README.md** file for your **Library Management System using SQL** project. You can copy this into your project repository:

---

````markdown
# 📚 Library Management System using SQL

## 🔍 Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`  
**Environment**: SQL (PostgreSQL)

This project implements a Library Management System using SQL, showcasing skills in database design, data manipulation (CRUD), advanced SQL queries, and stored procedures. The system tracks branches, employees, members, books, issue/return status, and performs data analysis and reporting.

---

## 🎯 Objectives

- Design and create a relational database with appropriate tables and relationships.
- Perform **CRUD operations** on different entities.
- Use **CTAS (Create Table As Select)** for reporting and data transformation.
- Execute **advanced SQL queries** for analysis and reporting.

---

## 🏗️ Project Structure

### 1. Database Setup

**Database Created**: `library_db`  
**Tables**:
- `branch`: Stores branch details
- `employees`: Stores employee details
- `members`: Contains library members
- `books`: Holds book inventory
- `issued_status`: Tracks book issues
- `return_status`: Tracks book returns

Each table includes proper constraints and foreign key relationships.

### 2. CRUD Operations

- **Create**: Inserted book record  
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
````

* **Read**: Select queries from various tables
* **Update**: Updated a member’s address

```sql
UPDATE members SET member_address = '125 Oak St' WHERE member_id = 'C103';
```

* **Delete**: Deleted a record from issued\_status

```sql
DELETE FROM issued_status WHERE issued_id = 'IS121';
```

---

## 🧠 Advanced SQL Tasks

### 3. CTAS (Create Table As Select)

**Book Issue Count Summary**

```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status AS ist
JOIN books AS b ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```

### 4. Data Analysis & Reporting

* **Books in ‘Classic’ Category**

```sql
SELECT * FROM books WHERE category = 'Classic';
```

* **Total Rental Income by Category**

```sql
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM issued_status AS ist
JOIN books AS b ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

* **Recent Member Registrations (Last 180 days)**

```sql
SELECT * FROM members WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

* **Employees with Their Manager and Branch Details**

```sql
SELECT e1.emp_id, e1.emp_name, e1.position, e1.salary, b.*, e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b ON e1.branch_id = b.branch_id
JOIN employees AS e2 ON e2.emp_id = b.manager_id;
```

* **Expensive Books Table (> ₹7.00)**

```sql
CREATE TABLE expensive_books AS
SELECT * FROM books WHERE rental_price > 7.00;
```

* **Unreturned Books**

```sql
SELECT * FROM issued_status AS ist
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

* **Overdue Books (>30 days)**

```sql
SELECT ist.issued_member_id, m.member_name, bk.book_title, ist.issued_date,
CURRENT_DATE - ist.issued_date AS over_dues_days
FROM issued_status AS ist
JOIN members AS m ON m.member_id = ist.issued_member_id
JOIN books AS bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date) > 30;
```

---

### 5. Stored Procedure: Return Handling

**Procedure: `add_return_records`**
Updates `return_status` and sets book status to `'yes'`.

```sql
CALL add_return_records('RS138', 'IS135', 'Good');
```

---

### 6. Branch Performance Report

```sql
CREATE TABLE branch_reports AS
SELECT b.branch_id, b.manager_id,
       COUNT(ist.issued_id) AS number_book_issued,
       COUNT(rs.return_id) AS number_of_book_return,
       SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;
```

---

### 7. Active Members (Last 2 Months)

```sql
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month'
);
```

---

### 8. Top 3 Employees by Book Issues Processed

```sql
SELECT e.emp_name, b.*, COUNT(ist.issued_id) AS no_book_issued
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id
ORDER BY no_book_issued DESC
LIMIT 3;
```

---

## 📦 Technologies Used

* **SQL (PostgreSQL)**
* **pgAdmin / SQL CLI**
* **PL/pgSQL** for stored procedures

---

## ✅ Key Learning Outcomes

* Practical application of database normalization and foreign keys
* Efficient use of aggregate functions and GROUP BY
* Writing optimized joins for data retrieval
* Working with CTAS and procedures for business logic
* Real-time reporting queries

---

## 🙌 Acknowledgements

Project guided and built with SQL best practices.
Special thanks to online learning resources and AI-assisted development tools.

---

## 🔗 License

This project is for educational and demonstration purposes only.

```
