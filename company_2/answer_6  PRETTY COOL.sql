/*
6.
What are the most profitable film categories in each country? Your query should return a
row for each country and a column should contain the name of the top 3 categories
separated by commas.
*/

WITH country_by_filmID AS (
	SELECT
		inv.film_id, -- flag
		re.inventory_id,
		re.rental_id, -- flag
		cu.address_id, 
		ad.city_id, 
		ci.country_id, 
		co.country -- flag
	FROM
		inventory inv
	INNER JOIN
		rental re
		ON inv.inventory_id = re.inventory_id
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
		ON ci.country_id = co.country_id
	ORDER BY 
		film_id),

category_by_filmId AS (
	SELECT 
		fc.film_id, -- flag
		fc.category_id,
		ca.name AS category_name -- flag
	FROM 
		film_category AS fc
	INNER JOIN 
		category AS ca
		ON fc.category_id = ca.category_id
	ORDER BY 
		fc.film_id
	),


-- profit per film_id as in answer_4 but

-- START

earning_by_inventoryId AS (
	SELECT 
		r.inventory_id,
		r.rental_id, -- added for this case
		SUM(p.amount) AS inventory_earning
	FROM
		payment p
	INNER JOIN rental r
		ON p.rental_id = r.rental_id
	GROUP BY 
		r.inventory_id, 
		r.rental_id
	ORDER BY 
		r.inventory_id),
		
earnings_by_filmId AS (
	SELECT 
		i.film_id,
		e.rental_id, -- added for this case
		SUM(e.inventory_earning) AS film_earning
	FROM 	
		earning_by_inventoryId e
	INNER JOIN
		inventory i
		ON e.inventory_id = i.inventory_id
	GROUP BY 
		i.film_id,
		e.rental_id
	ORDER BY 
		i.film_id),

replacementCost_partition AS ( -- new for this case
	SELECT 
		e.film_id,
		COUNT(e.rental_id) AS times_rented
	FROM 
		earnings_by_filmId e
	INNER JOIN 
		film f
		ON e.film_id = f.film_id
	GROUP BY 
		e.film_id
	ORDER BY 
		e.film_id),	

profit_by_rentalId AS (		
	SELECT 
		e.film_id,
		e.rental_id, -- added for this case
		(e.film_earning - f.replacement_cost/rp.times_rented)::money AS profit -- modified for this case
	FROM 
		earnings_by_filmId e
	INNER JOIN 
		film f
		ON e.film_id = f.film_id
	INNER JOIN 
		replacementCost_partition rp
		ON f.film_id = rp.film_id
	ORDER BY 
		e.film_id),

-- END

category_and_profit_by_film AS (
	SELECT 	
		pbr.film_id,
		pbr.rental_id,
		pbr.profit,
		cbf.category_name
	FROM 
		profit_by_rentalId pbr
	INNER JOIN
		category_by_filmId cbf
		ON pbr.film_id = cbf.film_id
	
	)

SELECT 
	country,
	string_agg(category, ', ') AS "top 3 categories" -- "categories" in the same line
FROM (
	SELECT
		cf.country,
		cpf.category_name AS category,
		SUM(cpf.profit) profit, -- sum same categories per country
		RANK() OVER(
				PARTITION BY cf.country 
				ORDER BY SUM(cpf.profit) DESC) AS ranking -- asign ranking by profit 
	FROM 
		country_by_filmID cf
	INNER JOIN
		category_and_profit_by_film cpf
		ON cf.rental_id = cpf.rental_id
	GROUP BY 
		cf.country,
		cpf.category_name	
	ORDER BY 
		cf.country,
		profit DESC
	) t
WHERE 
	ranking IN (1,2,3) -- keep top 3 in the ranking (see #assumption below)
GROUP BY 
	country
ORDER BY 
	country;
	
/*
assumption:
if some of the top 3 positions has more than one output I´ll keep all
of them because "top 3" was asked, not just 3 as output number. 
i.e. see "Yugoslavia" :: the output is 'Horror, Animation, Sports, Children'
*/
