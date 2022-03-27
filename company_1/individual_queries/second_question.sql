WITH 
	fraud_names AS (
		SELECT DISTINCT
			UPPER(visitor) AS fraud_name
		FROM 
			fraud
	), 
	
	purchases_cleansed AS (
		SELECT *
		FROM 
			(
			SELECT DISTINCT -- see 'Assumptions' (discarding duplicates)
				UPPER(visitor) AS visitor,
				transaction
			FROM 
				purchases) AS purchasesUpper
		WHERE 
			visitor LIKE ('A%') -- see challenge question (visitors who begin with the letter A)
			AND
			visitor NOT IN (SELECT fraud_name FROM fraud_names) -- quality issue n° 3		
	),
	
	transaction_indicator AS (  
		SELECT
			visitor,
			MAX("pre transaction indicator") AS "transaction indicator" -- see challenge question
		FROM 
			(
			SELECT	
				visitor, 
				CASE
					WHEN transaction >= 100
						THEN 1
					ELSE 0
				END "pre transaction indicator"  
			FROM
				purchases_cleansed
			) AS pre_transaction_indicators
		GROUP BY
			visitor
	),
	
	avg_transaction AS (
		SELECT 
			visitor, 
			ROUND(AVG(transaction)) AS "mean of transactions"  -- see challenge question 
		FROM 
			purchases_cleansed 
		GROUP BY
			visitor
	)

SELECT * INTO table_report FROM -- see challenge question (create a table)
	(
	SELECT 
		a.visitor,
		a."mean of transactions",
		i."transaction indicator"
	FROM 
		avg_transaction AS a
	INNER JOIN
		transaction_indicator AS i
	ON
		a.visitor = i.visitor
	ORDER BY 
		"mean of transactions" DESC -- see challenge question  
	LIMIT 10 -- see challenge question  
	) AS t;  