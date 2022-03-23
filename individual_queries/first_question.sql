WITH 
	fraud_names AS (
		SELECT DISTINCT
			UPPER(visitor) AS fraud_nameUp
		FROM 
			fraud
	), 
	
	demos_cleansed AS (
		SELECT
			*
		FROM 
			(
			SELECT DISTINCT -- see 'Assumptions' (discarding duplicates)
				UPPER(name) AS nameUp,
				MAX(age) AS max_age  -- quality issue n° 1
			FROM 
				demos
			GROUP BY 
				nameUp
			) AS demos_preCleansed
		WHERE 
			max_age IS NOT NULL  -- quality issue n° 2 & challenge question 
			AND
			nameUp NOT IN (SELECT fraud_nameUp FROM fraud_names) -- quality issue n° 3		
	), 
	
	percentage_distributions AS (
		SELECT 
			max_age, 
			ROUND(
					(COUNT(max_age)
						* 100
						/ (SELECT COUNT(*) AS total_visitors 
						   FROM demos_cleansed)),
				1) 
				AS "percentage distribution" -- see 'Assumptions' [round()] & challenge question 
		FROM 
			demos_cleansed
		GROUP BY 	
			max_age
	)
		
SELECT 
	max_age AS "visitor age", 
	"percentage distribution"
FROM 
	percentage_distributions
WHERE 
	"percentage distribution" >= 5.0; -- see challenge question 







