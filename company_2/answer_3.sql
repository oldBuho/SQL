-- 3
/* What about the most famous in terms of the amount of 
money brought to the rental from their movies? */

WITH rental_incomes AS (
	SELECT 
	r.inventory_id,
	p.amount
	FROM 
		rental r
	INNER JOIN 
		payment p
		ON r.rental_id = p.rental_id
	ORDER BY 
		r.rental_id DESC),
		
total_income_per_film AS (
	SELECT 
		i.film_id,
		SUM(ri.amount) AS total_income
	FROM 
		inventory i
	INNER JOIN 
		rental_incomes ri
		ON i.inventory_id = ri.inventory_id
	GROUP BY 
		i.film_id
	ORDER BY 
		total_income DESC), -- result film_id = #879 with $215.75
		
top_income_film AS (
	SELECT 
		film_id,
		total_income 	
	FROM 
		total_income_per_film
	WHERE 
		total_income = (SELECT MAX(total_income) FROM total_income_per_film)
	)


SELECT 
	CONCAT(a.first_name,' ',a.last_name) AS actor
FROM 
	actor AS a
INNER JOIN 
	film_actor AS fa
	ON a.actor_id = fa.actor_id
WHERE 
	fa.film_id = (SELECT film_id FROM top_income_film)
ORDER BY 1 ASC

/*
result:

"Carmen Hunt"
"Gina Degeneres"
"Lucille Dee"
"Michael Bening"
"Thora Temple"
"Vivien Basinger"
"Woody Hoffman"

*/


	
