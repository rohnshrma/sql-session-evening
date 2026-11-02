
-- ============================================================
-- LIBRARY MANAGEMENT SYSTEM
-- PostgreSQL Practice Dataset
-- ============================================================

-- STEP 1: Remove existing tables so this script can be rerun.
-- CASCADE also removes dependent objects if they exist.

-- Child tables (loans, books) are listed with parents; insert order later must be parents first
DROP TABLE IF EXISTS loans, books, members, authors CASCADE;


-- ============================================================
-- STEP 2: CREATE TABLES
-- ============================================================

-- Stores library members.

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,         -- auto-incrementing unique id (primary key)
    member_name VARCHAR(100) NOT NULL,    -- text up to 100 chars; value is mandatory
    city VARCHAR(50),                     -- optional city
    membership_type VARCHAR(20),          -- Premium / Standard / Student
    join_date DATE,                       -- calendar date (no time)
    age INT CHECK (age >= 5)              -- CHECK rejects ages below 5
);


-- Stores book authors.

CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,         -- unique auto id
    author_name VARCHAR(100) NOT NULL,    -- required name
    country VARCHAR(50)                   -- optional country
);


-- Stores books.
-- Each book references an author.

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,                  -- unique auto id
    book_title VARCHAR(150) NOT NULL,            -- required title
    genre VARCHAR(50),                           -- e.g. Fiction, Mystery
    price NUMERIC(8, 2) CHECK (price > 0),       -- exact decimal: 8 digits, 2 after the point; must be positive
    author_id INT REFERENCES authors(author_id), -- FOREIGN KEY: must exist in authors (many books -> one author)
    published_year INT                           -- year as a plain integer
);


-- Stores book loan transactions.
-- Each loan connects one member with one book.

CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,                   -- unique auto id
    member_id INT REFERENCES members(member_id),  -- FK -> who borrowed
    book_id INT REFERENCES books(book_id),        -- FK -> which book (loans is a junction table: members <-> books, many-to-many)
    loan_date DATE NOT NULL,                      -- required borrow date
    return_date DATE,                             -- NULL until the book is returned
    status VARCHAR(20)
        CHECK (status IN ('Borrowed', 'Returned', 'Overdue'))  -- only these 3 values allowed
);


-- ============================================================
-- STEP 3: INSERT AUTHORS (15 ROWS)
-- ============================================================

INSERT INTO authors (author_name, country) VALUES
('George Orwell', 'United Kingdom'),
('J.K. Rowling', 'United Kingdom'),
('R.K. Narayan', 'India'),
('Agatha Christie', 'United Kingdom'),
('Stephen King', 'United States'),
('Jane Austen', 'United Kingdom'),
('Ruskin Bond', 'India'),
('Paulo Coelho', 'Brazil'),
('Dan Brown', 'United States'),
('Rabindranath Tagore', 'India'),
('Mark Twain', 'United States'),
('Yuval Noah Harari', 'Israel'),
('Chetan Bhagat', 'India'),
('Arthur Conan Doyle', 'United Kingdom'),
('Oscar Wilde', 'Ireland');


-- ============================================================
-- STEP 4: INSERT MEMBERS (30 ROWS)
-- ============================================================

INSERT INTO members
(member_name, city, membership_type, join_date, age)
VALUES
('Aarav Sharma', 'Delhi', 'Premium', '2025-01-10', 25),
('Priya Verma', 'Gurgaon', 'Standard', '2025-02-15', 22),
('Rahul Singh', 'Noida', 'Premium', '2025-03-20', 31),
('Neha Gupta', 'Delhi', 'Student', '2025-04-05', 19),
('Amit Kumar', 'Jaipur', 'Standard', '2025-05-12', 28),
('Sneha Kapoor', 'Gurgaon', 'Premium', '2025-06-18', 27),
('Vikram Yadav', 'Noida', 'Student', '2025-07-21', 20),
('Ananya Mehta', 'Mumbai', 'Premium', '2025-08-02', 24),
('Karan Malhotra', 'Delhi', 'Standard', '2025-08-14', 35),
('Pooja Mishra', 'Lucknow', 'Student', '2025-09-09', 18),
('Rohit Jain', 'Gurgaon', 'Premium', '2025-09-17', 29),
('Simran Kaur', 'Chandigarh', 'Standard', '2025-10-01', 26),
('Arjun Patel', 'Ahmedabad', 'Student', '2025-10-11', 21),
('Isha Agarwal', 'Jaipur', 'Premium', '2025-10-19', 23),
('Manish Saini', 'Delhi', 'Standard', '2025-11-03', 40),
('Kavya Rao', 'Bengaluru', 'Premium', '2025-11-15', 30),
('Sahil Bansal', 'Gurgaon', 'Student', '2025-11-20', 19),
('Meera Joshi', 'Pune', 'Standard', '2025-12-01', 32),
('Varun Arora', 'Delhi', 'Premium', '2025-12-10', 27),
('Tanya Das', 'Kolkata', 'Student', '2025-12-18', 20),
('Dev Khanna', 'Noida', 'Standard', '2026-01-05', 34),
('Riya Saxena', 'Gurgaon', 'Premium', '2026-01-12', 24),
('Mohit Chauhan', 'Jaipur', 'Student', '2026-01-19', 22),
('Nisha Reddy', 'Hyderabad', 'Standard', '2026-02-02', 29),
('Aditya Bose', 'Kolkata', 'Premium', '2026-02-11', 33),
('Shreya Nair', 'Mumbai', 'Student', '2026-02-20', 18),
('Kunal Thakur', 'Delhi', 'Standard', '2026-03-03', 36),
('Diya Chawla', 'Gurgaon', 'Premium', '2026-03-15', 26),
('Yash Tiwari', 'Lucknow', 'Student', '2026-04-01', 21),
('Aditi Sen', 'Bengaluru', 'Standard', '2026-04-12', 28);


-- ============================================================
-- STEP 5: INSERT BOOKS (30 ROWS)
-- ============================================================

INSERT INTO books
(book_title, genre, price, author_id, published_year)
VALUES
('1984', 'Fiction', 450, 1, 1949),
('Animal Farm', 'Fiction', 350, 1, 1945),
('Harry Potter and the Philosopher Stone', 'Fantasy', 650, 2, 1997),
('Harry Potter and the Chamber of Secrets', 'Fantasy', 700, 2, 1998),
('The Guide', 'Fiction', 400, 3, 1958),
('Malgudi Days', 'Fiction', 300, 3, 1943),
('Murder on the Orient Express', 'Mystery', 500, 4, 1934),
('And Then There Were None', 'Mystery', 450, 4, 1939),
('The Shining', 'Horror', 600, 5, 1977),
('It', 'Horror', 850, 5, 1986),
('Pride and Prejudice', 'Romance', 400, 6, 1813),
('Sense and Sensibility', 'Romance', 380, 6, 1811),
('The Blue Umbrella', 'Fiction', 250, 7, 1980),
('The Room on the Roof', 'Fiction', 320, 7, 1956),
('The Alchemist', 'Philosophy', 350, 8, 1988),
('Brida', 'Philosophy', 420, 8, 1990),
('The Da Vinci Code', 'Thriller', 550, 9, 2003),
('Angels and Demons', 'Thriller', 520, 9, 2000),
('Gitanjali', 'Poetry', 280, 10, 1910),
('The Home and the World', 'Fiction', 390, 10, 1916),
('Adventures of Tom Sawyer', 'Adventure', 430, 11, 1876),
('Adventures of Huckleberry Finn', 'Adventure', 460, 11, 1884),
('Sapiens', 'History', 750, 12, 2011),
('Homo Deus', 'History', 800, 12, 2015),
('Five Point Someone', 'Fiction', 300, 13, 2004),
('2 States', 'Romance', 280, 13, 2009),
('Sherlock Holmes: The Complete Novels', 'Mystery', 900, 14, 1892),
('The Hound of the Baskervilles', 'Mystery', 480, 14, 1902),
('The Picture of Dorian Gray', 'Fiction', 420, 15, 1890),
('The Importance of Being Earnest', 'Drama', 350, 15, 1895);


-- ============================================================
-- STEP 6: INSERT LOANS (40 ROWS)
-- ============================================================

INSERT INTO loans
(member_id, book_id, loan_date, return_date, status)
VALUES
(1, 1, '2026-01-02', '2026-01-10', 'Returned'),
(1, 3, '2026-02-05', NULL, 'Borrowed'),
(2, 2, '2026-01-05', '2026-01-15', 'Returned'),
(2, 5, '2026-02-10', NULL, 'Overdue'),
(3, 7, '2026-01-08', '2026-01-18', 'Returned'),
(3, 8, '2026-02-12', NULL, 'Borrowed'),
(4, 4, '2026-01-10', '2026-01-20', 'Returned'),
(4, 6, '2026-02-15', NULL, 'Overdue'),
(5, 9, '2026-01-12', '2026-01-22', 'Returned'),
(5, 10, '2026-03-01', NULL, 'Borrowed'),
(6, 11, '2026-01-14', '2026-01-24', 'Returned'),
(6, 12, '2026-03-03', NULL, 'Borrowed'),
(7, 13, '2026-01-16', '2026-01-26', 'Returned'),
(7, 14, '2026-03-05', NULL, 'Overdue'),
(8, 15, '2026-01-18', '2026-01-28', 'Returned'),
(8, 16, '2026-03-07', NULL, 'Borrowed'),
(9, 17, '2026-01-20', '2026-01-30', 'Returned'),
(9, 18, '2026-03-09', NULL, 'Overdue'),
(10, 19, '2026-01-22', '2026-02-01', 'Returned'),
(10, 20, '2026-03-11', NULL, 'Borrowed'),
(11, 21, '2026-01-24', '2026-02-03', 'Returned'),
(11, 22, '2026-03-13', NULL, 'Borrowed'),
(12, 23, '2026-01-26', '2026-02-05', 'Returned'),
(12, 24, '2026-03-15', NULL, 'Overdue'),
(13, 25, '2026-01-28', '2026-02-07', 'Returned'),
(13, 26, '2026-03-17', NULL, 'Borrowed'),
(14, 27, '2026-01-30', '2026-02-09', 'Returned'),
(14, 28, '2026-03-19', NULL, 'Overdue'),
(15, 29, '2026-02-01', '2026-02-11', 'Returned'),
(15, 30, '2026-03-21', NULL, 'Borrowed'),
(16, 1, '2026-02-03', '2026-02-13', 'Returned'),
(17, 3, '2026-02-05', NULL, 'Overdue'),
(18, 5, '2026-02-07', '2026-02-17', 'Returned'),
(19, 7, '2026-02-09', NULL, 'Borrowed'),
(20, 9, '2026-02-11', '2026-02-21', 'Returned'),
(21, 11, '2026-02-13', NULL, 'Overdue'),
(22, 13, '2026-02-15', '2026-02-25', 'Returned'),
(23, 15, '2026-02-17', NULL, 'Borrowed'),
(24, 17, '2026-02-19', '2026-03-01', 'Returned'),
(25, 19, '2026-02-21', NULL, 'Overdue');


-- ============================================================
-- STEP 7: VERIFY THE DATA
-- ============================================================

-- Count rows in each table.

SELECT 'members' AS table_name, COUNT(*) AS total_rows
FROM members

UNION ALL

-- UNION ALL stacks the results of the SELECTs into one list (keeps duplicates, faster than UNION)
SELECT 'authors', COUNT(*)
FROM authors

UNION ALL

SELECT 'books', COUNT(*)
FROM books

UNION ALL

SELECT 'loans', COUNT(*)
FROM loans;


-- Expected row counts:
-- members = 30
-- authors = 15
-- books   = 30
-- loans   = 40
-- TOTAL   = 115 ROWS


-- View all loan transactions with member and book details.

SELECT
    l.loan_id,
    m.member_name,
    b.book_title,
    b.genre,
    l.loan_date,
    l.return_date,
    l.status
FROM loans AS l                      -- AS gives the table a short alias
JOIN members AS m USING (member_id)  -- INNER JOIN on the shared column name member_id
JOIN books AS b USING (book_id)      -- second join: attach book details to each loan
ORDER BY l.loan_id;                  -- sort the result by loan id
