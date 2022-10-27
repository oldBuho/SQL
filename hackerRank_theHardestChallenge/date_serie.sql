-- generating date serie column
SELECT 
	s.submission_date,  
	(s.submission_date - MIN(m.min_date) +1) AS days_in_a_row
FROM
	public."Submissions" AS s
CROSS JOIN (
	SELECT MIN(submission_date) min_date
	FROM public."Submissions") AS m
GROUP BY 
	s.submission_date
ORDER BY 
	s.submission_date

