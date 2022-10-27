/*
HackerRank.com
Hardest SQL challenge _ 2022
*/

-- keeping just the users with >=1 submissions per day

WITH not_null_subm AS (
	SELECT  
		submission_date, 
		hacker_id, 
		COUNT(submission_id) AS subm_count_per_user
	FROM 
		public."Submissions"
	GROUP BY 
		submission_date, hacker_id
	HAVING 
		COUNT(submission_id) >= 1
	ORDER BY 
		submission_date),
	
-- max numb subm per day per user

max_User_Daily AS (
	SELECT submission_date, 
		MAX(subm_count_per_user) AS max_of_the_day
	FROM 
		not_null_subm
	GROUP BY 
		submission_date),

-- this CTE contains the list of users with more 
-- submissions each day per date. REQUIREMENT COMPLETED

user_daily_more_subm AS (
	SELECT s.submission_date, 
		MIN(s.hacker_id) AS hacker_id
	FROM
		not_null_subm s
	INNER JOIN max_User_Daily AS m
	ON s.submission_date = m.submission_date
	WHERE 
		subm_count_per_user = max_of_the_day -- only users with more submissions
	GROUP BY
		s.submission_date, m.max_of_the_day), -- if theres´s more than one print the one with lowest user_id

-- adding a "how many days in a row _ column" per day

subm_day_count AS (
	SELECT 
		*,  
		COUNT(submission_date) OVER (PARTITION BY hacker_id ORDER BY submission_date) AS days_in_a_row
	FROM
		not_null_subm
	ORDER BY
		hacker_id, submission_date),

-- generation of a CTE with a column that adds a "+1" counter for each day in the calendar

accum_day_counters AS (
	SELECT 
		s.submission_date,  
		s.submission_date - min(m.min_date)+1 AS accum_day_counter
	FROM 
		public."Submissions" AS s
	CROSS JOIN (
		SELECT MIN(submission_date) min_date
		FROM public."Submissions") AS  m
	GROUP BY 
		s.submission_date
	ORDER BY 
		s.submission_date),

-- joining the "accum_day_counters" table with "subm_day_count" 
-- who contains "the days in a row"_counter.
-- keep only those useres that submit daily

pre_final AS (
	SELECT 
		sdc.submission_date, 
		sdc.days_in_a_row
	FROM 
		subm_day_count sdc 
	LEFT JOIN 
		accum_day_counters adc
		ON sdc.submission_date = adc.submission_date
	WHERE 
		sdc.days_in_a_row = adc.accum_day_counter -- keep only those useres that submit daily 
	ORDER BY 
		sdc.submission_date, sdc.hacker_id),

-- CTE containing date (I´ll use it as and "id"...) and users submitting daily
-- REQUIREMENT COMPLETED

numb_users_in_a_row AS (
	SELECT submission_date, 
		COUNT(days_in_a_row) AS num_days_in_a_row 
	FROM 
		pre_final
	GROUP BY 
		submission_date),

-- joining dates, number of users submitting in a row, and user_id with max daily subm

pre_final_table AS (
	SELECT 
		n.submission_date, 
		n.num_days_in_a_row, 
		u.hacker_id 
	FROM 
		numb_users_in_a_row n
	LEFT JOIN 
		user_daily_more_subm u
		ON n.submission_date = u.submission_date),

-- adding names to pre_final_table CTE and done

final_table AS (
	SELECT 
		t.submission_date, 
		t.num_days_in_a_row, 
		t.hacker_id,  
		h.name
	FROM 
		pre_final_table AS t
	INNER JOIN 
		public."Hackers" h
		ON t.hacker_id = h.hacker_id)

-- final result:
SELECT * FROM final_table;