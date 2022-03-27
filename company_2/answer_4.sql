/*
4°
A) Let "film.replacement_cost " be the actual cost of buying the movie 
for the rental shop. 
B) Calculate the profit/loss for each movie.
*/

WITH earning_by_inventoryId AS (
	SELECT 
		r.inventory_id,
		SUM(p.amount) AS inventory_earning
	FROM
		payment p
	INNER JOIN rental r
		ON p.rental_id = r.rental_id
	GROUP BY 
		r.inventory_id
	ORDER BY 
		r.inventory_id),
		
earnings_by_filmId AS (
	SELECT 
		i.film_id,
		SUM(e.inventory_earning) AS film_earning
	FROM 	
		earning_by_inventoryId e
	INNER JOIN
		inventory i
		ON e.inventory_id = i.inventory_id
	GROUP BY 
		i.film_id
	ORDER BY 
		i.film_id)
		
SELECT 
	e.film_id, 
	e.film_earning::money AS earning,
	f.replacement_cost::money AS "cost",
	(e.film_earning - f.replacement_cost)::money AS profit, 
	CASE 
		WHEN (e.film_earning - f.replacement_cost) > 0 THEN 'profit'
		WHEN (e.film_earning - f.replacement_cost) < 0 THEN 'loss'
		ELSE 'no movements'
	END result
FROM 
	earnings_by_filmId e
INNER JOIN 
	film f
	ON e.film_id = f.film_id
ORDER BY 
	e.film_id