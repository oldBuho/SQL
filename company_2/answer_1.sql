-- 1st question:
/* Which day was the busiest day in terms of rentals and how many rentals were
there on that day? Your query should return one single row and one single
column with the date in the format “YYYY-MM-DD”. */

WITH CTE AS (
	SELECT 
		rental_date,
		COUNT(rental_id) AS daily_count
	FROM 
		rental
	GROUP BY 
		rental_date
	ORDER BY 
		daily_count DESC
	)

SELECT 
	rental_date::DATE
FROM 
	CTE
WHERE
	daily_count = (SELECT MAX(daily_count) FROM CTE);

-- result '2006-02-14'