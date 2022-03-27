-- 2
/* Who is the most famous actor/actress in terms of times their movies were rented
out? Your query should return the full name of the actor or actress, first name
and last name in a single column */

WITH rental_count AS (
	SELECT 
		i.film_id,
		COUNT(r.rental_id) AS times_rented
	FROM 
		rental r
	INNER JOIN inventory i
		ON r.inventory_id = i.inventory_id
	GROUP BY
		i.film_id
	ORDER BY 
		times_rented DESC
		), 
top_rented_film_id AS (
	SELECT film_id
	FROM rental_count
	WHERE times_rented = (SELECT MAX(times_rented) FROM rental_count)
	)
	
SELECT 
	CONCAT(a.first_name,' ',a.last_name) AS actor
FROM 
	actor AS a
INNER JOIN film_actor AS fa
	ON a.actor_id = fa.actor_id
WHERE 
	fa.film_id = (SELECT film_id FROM top_rented_film_id)
ORDER BY 1 ASC
	

/*
RESULT:

"Burt Temple"
"Charlize Dench"
"Gary Phoenix"
"Kirsten Akroyd"
"Rip Crawford"
"Tim Hackman"

*/
	
