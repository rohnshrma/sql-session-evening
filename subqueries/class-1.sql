-- =====================================================================
-- SUBQUERIES : CLASS 1   (table used: raw_enrollments from data-cleaning-s1.sql)
-- Run in pgAdmin 4 > Query Tool > F5.
--
-- What is a subquery?
--   A subquery is a SELECT written inside another SQL statement, inside
--   round brackets ( ). The inner query runs first, gives its result to
--   the outer query, and the outer query uses that result like a value
--   or like a table. Think of it as "ask one small question first, then
--   use the answer to ask the bigger question".
--
-- Where can a subquery sit?
--   1. In SELECT  -> must return ONE value (scalar subquery)        [Query 1]
--   2. In FROM    -> returns a whole table (derived table)          [Query 2]
--   3. In WHERE   -> returns one value, or a list for IN / NOT IN   [Query 3]
--
-- Problem we are solving today:
--   raw_enrollments has duplicate students. The same ID is typed in
--   different ways: 'WG-1052', ' WG-1052 ', 'wg-1052', 'WG1052'.
--   We use subqueries to measure the duplicates, list them, and then
--   pull out the full rows of the duplicated students.
-- =====================================================================


-- ---------------------------------------------------------------------
-- QUERY 1 : Scalar subqueries in SELECT (three counts side by side)
-- Each ( SELECT ... ) below returns exactly one number (one row, one
-- column), so it can be used like a normal column value.
-- There is no FROM in the outer SELECT: it only shows three numbers
-- in a single row, like a mini report card.
-- ---------------------------------------------------------------------
select
-- Subquery 1: count(*) counts every row in the table, duplicates included
(select count(*) from raw_enrollments) as total_rows,
-- Subquery 2: count(distinct ...) counts unique IDs exactly as typed,
-- so 'WG-1052' and 'wg-1052' are still counted as two different IDs
(select count(distinct enrollment_id) from raw_enrollments )  as ids_as_types,
-- Subquery 3: TRIM removes spaces at both ends, UPPER makes 'wg' -> 'WG';
-- after this light cleaning, more IDs match, so this count is smaller
(select count(distinct upper(trim(enrollment_id)))  from raw_enrollments) as clean_ids;
-- Reading the result: total_rows > clean_ids means duplicates exist.
-- The gap between ids_as_types and clean_ids shows how many "fake unique"
-- IDs were only different because of spaces or small letters.




-- ---------------------------------------------------------------------
-- QUERY 2 : Subquery in FROM (derived table)
-- Goal: list every cleaned ID that appears more than once, with how
-- many copies it has.
-- Why a subquery? We cannot write WHERE copies > 1 in the same query
-- that creates "copies", because WHERE runs before SELECT names exist.
-- So the inner query builds a small table (clean_id, copies) and the
-- outer query filters that table like any normal table.
-- ---------------------------------------------------------------------
-- Outer query: pick the two columns made by the inner query
select clean_id , copies
-- FROM ( ... ): the inner SELECT acts as a temporary table
from (
	-- Inner query: build one row per cleaned ID
	select
	-- TRIM -> remove outer spaces, UPPER -> capital letters,
	-- REGEXP_REPLACE with pattern '^WG-?':
	--   ^   = start of the text
	--   WG  = the letters WG
	--   -?  = an optional hyphen (zero or one)
	-- so both 'WG1052' and 'WG-1052' become 'WG-1052'
	REGEXP_REPLACE(UPPER(TRIM(enrollment_id)) , '^WG-?' , 'WG-') as clean_id,
	-- count(*) per group = how many rows share this cleaned ID
	count (*) as copies from raw_enrollments
	-- group by the same cleaned expression so all spellings of an ID fall
	-- into one group (we repeat the full expression; GROUP BY 1 also works)
	group by REGEXP_REPLACE(UPPER(TRIM(enrollment_id)) , '^WG-?' , 'WG-')
)
-- Note: PostgreSQL 16+ allows a FROM-subquery without an alias.
-- In older versions (and most other databases) write: ) as t
-- Keep only IDs that occur more than once = the duplicates
where copies > 1
-- Most-copied IDs first; for a tie, sort by the ID alphabetically
order by copies desc , clean_id;


-- ---------------------------------------------------------------------
-- QUERY 3 : Multi-row subquery in WHERE with IN
-- Goal: show the FULL rows (name, city, course, fee) of every
-- duplicated student, so we can compare the copies by eye.
-- The inner query returns a LIST of duplicate IDs (many rows, one
-- column). IN checks: "is this row's cleaned ID inside that list?"
-- ---------------------------------------------------------------------
-- Outer query: columns we want to see for each duplicate row
select enrollment_id, full_name, city ,  course , fee_paid
from raw_enrollments
-- Clean the outer row's ID the same way, then test it against the list.
-- Both sides MUST use the same cleaning, otherwise ' wg-1052 ' would
-- never match 'WG-1052' from the list.
where REGEXP_REPLACE(UPPER(TRIM(enrollment_id)) , '^WG-?' , 'WG-')  in (
	-- Inner query: list of cleaned IDs that occur more than once
	select
	REGEXP_REPLACE(UPPER(TRIM(enrollment_id)) , '^WG-?' , 'WG-') from raw_enrollments
	-- GROUP BY 1 = group by the 1st column of this SELECT (the cleaned ID)
	group by 1
	-- HAVING filters groups after counting (WHERE cannot use count(*))
	having count(*) > 1
);
-- Tip: to keep copies of the same student next to each other, add
--   ORDER BY REGEXP_REPLACE(UPPER(TRIM(enrollment_id)), '^WG-?', 'WG-')
-- at the end, before the semicolon.
