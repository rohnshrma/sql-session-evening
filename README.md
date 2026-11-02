# SQL Evening Sessions (WebiGeeks)

PostgreSQL practice scripts from the evening SQL classes. Run them in pgAdmin 4 (Query Tool, F5). Every script is commented line by line.

| File | Topic |
|---|---|
| `session_1_script.sql` | SQL fundamentals on a small shop database |
| `Class_3_SQL_Notes_WebiGeeks.pdf`, `SQL_Notes_WebiGeeks_SESSION_1.pdf` | Class notes |
| `library-management.sql` | Practice dataset: library system |
| `data-cleaning-s1.sql` | Data cleaning, part 1: load and profile dirty data |
| `data-cleaning-s2.sql` | Data cleaning, part 2: staging table and whitespace trimming |
| `data-cleaning-s3.sql` | Data cleaning, part 3: whitespace cleanup on the staging table |

## Session 1: SQL basics (`session_1_script.sql`)
Builds a shop database (`customers`, `products`, `orders`) and covers:
- **DDL:** `CREATE`, `ALTER`, `DROP`, `TRUNCATE`; constraints (`PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`, foreign keys)
- **DML:** `INSERT`, `UPDATE`, `DELETE`, and transactions (`BEGIN`, `COMMIT`, `ROLLBACK`)
- **Querying:** `SELECT`, `DISTINCT`, aliases, casting, `WHERE` (`IN`, `BETWEEN`, `LIKE`/`ILIKE`), `ORDER BY`, `LIMIT`/`OFFSET`
- **Aggregation:** `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`
- **Joins:** inner, left, anti-join, self join
- **Set operations:** `UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT`
- **`CASE`:** in `SELECT`, `GROUP BY` and `ORDER BY`

## Library management (`library-management.sql`)
A ready-made practice dataset: `members` (30), `authors` (15), `books` (30) and `loans` (40). It is a normalized design with a many-to-many link through `loans`. It ends with a row-count check and a three-table join to practise on.

## Data cleaning (sessions 1 to 3)
Works on `raw_enrollments`, a deliberately dirty table of 308 student enrollments with every column stored as `TEXT`. The problems include inconsistent case and spelling, extra spaces, fake NULLs, mixed date and fee formats, and duplicate IDs.

- **Session 1 (`data-cleaning-s1.sql`):** loads the data, then profiles it. It counts NULLs, finds empty strings and fake NULLs, builds frequency tables for city, course and gender, and checks for duplicate IDs.
- **Session 2 (`data-cleaning-s2.sql`):** copies the raw table into `stg_enrollments` (the raw data stays untouched). It adds a `row_id` key, checks the row counts match, and trims whitespace in all columns with `trim()` and `regexp_replace()`.
- **Session 3 (`data-cleaning-s3.sql`):** the same whitespace-cleanup `UPDATE`, so the session can run on its own.

## How to run
1. Create or open a PostgreSQL database in pgAdmin 4.
2. Open a script in the Query Tool and press F5.
3. Run `data-cleaning-s1.sql` before s2 and s3, because they depend on `raw_enrollments`.
