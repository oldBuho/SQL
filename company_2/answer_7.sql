/*
7
What are the top 3 most common films that customers rent as their first rental?
*/

WITH inventoryId_selected AS ( -- pool of inventory_IDs for this analysis
	SELECT
		customer_id,
		inventory_id
	FROM (
		SELECT
			customer_id,
			inventory_id,
			rental_date,
			RANK() OVER(PARTITION BY customer_id ORDER BY rental_date) 
		FROM 
			rental
		GROUP BY 
			customer_id,
			inventory_id,
			rental_date
		ORDER BY 
			customer_id,
			rental_date,
			inventory_id) t
	WHERE
		rank IN (1,2,3)),

filmId_selected AS ( -- pool of films_IDs for this analysis
	SELECT
		iid.customer_id,
		iid.inventory_id,
		inv.film_id
	FROM 
		inventoryId_selected AS iid 
	INNER JOIN 
		inventory AS inv
		ON iid.inventory_id = inv.inventory_id
	ORDER BY 
		iid.customer_id,
		inv.film_id),

film_ranking AS (
SELECT 
	film_id,
	--times_rented,
	RANK() OVER(ORDER BY times_rented DESC) ranking
FROM (
	SELECT 
		film_id,
		COUNT(inventory_id) times_rented
	FROM 
		filmId_selected
	GROUP BY 
		film_id
	ORDER BY 
		times_rented DESC) t)

SELECT
	film_id,
	ranking
FROM 
	film_ranking
WHERE 
	ranking IN (1,2,3); -- TOP 3	
	


-- with a couple of joins we could get the film names for these IDs... 

-- RESULT
/*
film_id ranking
103		1
738		2
775		3
875		3
*/

