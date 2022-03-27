/*
#5
What is the revenue for each country for the top 10 most popular 
movies in terms of overall rentals?
*/


WITH top_10_rentals_byFilmId AS (
	SELECT 
		COUNT(r.rental_id) AS times_rented,
		i.film_id
	FROM 
		rental r
	INNER JOIN inventory i
		ON r.inventory_id = i.inventory_id
	GROUP BY
		i.film_id
	ORDER BY -- assumption: i´ll just take the first 10 films ordered like this
		times_rented DESC, 
		i.film_id ASC
	LIMIT 10 
		),
		
earning_by_inventoryId AS ( -- as in answer #4 
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
		
earnings_by_filmId AS ( -- as in answer #4 PLUS film_id field
	SELECT 
		i.film_id,
		i.inventory_id,
		SUM(e.inventory_earning) AS film_earning
	FROM 	
		earning_by_inventoryId e
	INNER JOIN
		inventory i
		ON e.inventory_id = i.inventory_id
	GROUP BY 
		i.film_id,
		i.inventory_id
	ORDER BY 
		i.film_id),
		
top10_film_earnings AS (
	SELECT 
		t.film_id, 
		e.inventory_id,
		e.film_earning
	FROM 
		top_10_rentals_byFilmId t
	INNER JOIN 
		earnings_by_filmId e
		ON t.film_id = e.film_id
	ORDER BY 
		t.film_id),
		
country_by_inventoryID AS (
	SELECT
		re.inventory_id,
		cu.address_id, 
		ad.city_id, 
		ci.country_id, 
		co.country
	FROM
		rental re
	INNER JOIN
		customer cu
		ON re.customer_id = cu.customer_id
	INNER JOIN
		address ad
		ON cu.address_id = ad.address_id
	INNER JOIN 
		city ci
		ON ad.city_id = ci.city_id	
	INNER JOIN 
		country co
		ON ci.country_id = co.country_id)
		

SELECT
	c.country,
	SUM(film_earning)::money AS revenue
FROM 
	top10_film_earnings t
LEFT JOIN 
	country_by_inventoryID c
	ON t.inventory_id = c.inventory_id
GROUP BY
	c.country
ORDER BY 
	c.country;