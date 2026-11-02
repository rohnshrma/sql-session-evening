-- SESSION 2: build a staging table so the raw data is never modified

-- Remove any old staging table so the script is re-runnable
drop table if exists stg_enrollments;

-- CTAS (CREATE TABLE AS SELECT): copy every row/column of raw into a staging table
create table stg_enrollments as select * from raw_enrollments;


-- Add an auto-incrementing surrogate key (SERIAL) to uniquely identify each row,
-- useful because enrollment_id itself has duplicates
alter table stg_enrollments
	add column row_id serial;


-- Verify the copy: both counts must be equal (308)
-- Scalar subqueries in SELECT return one value each
select
	(select count(*) from raw_enrollments) as raw_rows,
	(select count(*) from stg_enrollments ) as stg_rows;


-- Step 1 of cleaning: trim whitespace in every column
-- trim() removes leading/trailing spaces
-- regexp_replace(col, '\s+', ' ', 'g') collapses any run of whitespace into one space ('g' = all matches)
-- Single-value columns (gender, age, email...) only need trim
update stg_enrollments
set
	enrollment_id = trim(Regexp_replace(enrollment_id , '\s+' , ' ', 'g')),
	full_name = trim(regexp_replace(full_name,'\s+' , ' ' , 'g')),
	gender = trim(gender),
	age = trim(age),
	email = trim(email),
	phone= trim(phone),
	city= trim(regexp_replace(city , '\s+', ' ' , 'g')),
	course= trim(regexp_replace(course , '\s+', ' ' , 'g')),
	enroll_date= trim(enroll_date),
	fee_paid= trim(fee_paid),
	payment_mode= trim(regexp_replace(payment_mode, '\s+' , ' ' , 'g')),
	status= trim(status),
	rating= trim(rating);
