-- SESSION 3: whitespace cleanup on the staging table
-- (same UPDATE as the end of session 2, kept so this session can run on its own)

-- A single UPDATE can set many columns at once (no WHERE = applies to all rows)
-- trim() strips leading/trailing spaces
-- regexp_replace(col, '\s+', ' ', 'g'): '\s+' = one or more whitespace chars,
--   replaced by a single space, 'g' = replace every match, not just the first
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
