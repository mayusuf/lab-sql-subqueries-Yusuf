-- LAB | SQL Subqueries
USE sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system

SELECT COUNT(*)
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";

SELECT *
FROM inventory i 
WHERE i.film_id IN (
	SELECT f.film_id 
	FROM film f
	WHERE f.title = "Hunchback Impossible"
);

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database

SELECT f.title, f.`length` 
FROM film f
WHERE f.`length` > ( 
	SELECT AVG(sf.LENGTH)
	FROM film sf
);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip"

SELECT a.first_name, a.last_name
FROM actor a
WHERE a.actor_id IN (
		SELECT fa.actor_id
		FROM film_actor fa
		WHERE fa.film_id IN (
			SELECT f.film_id
			from film f 
			WHERE f.title = 'Alone Trip'
		)
);


-- Bonus:
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. 
-- Identify all movies categorized as family films

SELECT f.title
FROM film f
WHERE f.film_id IN (
		SELECT fc.film_id
		FROM film_category fc
		WHERE fc.category_id IN (
			SELECT c.category_id
			from category c 
			WHERE c.name = 'Family'
		)
);

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, 
-- you will need to identify the relevant tables and their primary and foreign keys.

SELECT CONCAT(c.first_name,' ',c.last_name) AS NAME, c.email
FROM customer c
WHERE c.address_id IN (
	SELECT ad.address_id
	FROM address ad
	WHERE ad.city_id IN (
			SELECT ct.city_id
			FROM city ct
			WHERE ct.country_id IN (
				SELECT cn.country_id
				from country cn 
				WHERE cn.country = 'Canada'
			)
	)
);

SELECT CONCAT(c.first_name,' ',c.last_name) AS NAME, c.email
FROM customer c
JOIN address ad
USING (address_id)
JOIN city ct
USING (city_id)
JOIN country cn
USING (country_id)
WHERE cn.country = 'Canada';

-- 6. Determine which films were starred by the most prolific actor in the Sakila database.  A prolific actor is 
-- defined as the actor who has acted in the most number of films. First, you will need to find the most prolific 
-- actor and then use that actor_id to find the different films that he or she starred in

SELECT f.title, a.first_name, a.last_name
FROM film f
JOIN film_actor fa
USING(film_id)
JOIN actor a
USING (actor_id)
WHERE fa.actor_id = (
	SELECT actor_id
    FROM (
		SELECT actor_id, COUNT(*) AS film_count
		FROM film_actor
		GROUP BY actor_id
		ORDER BY film_count DESC
		LIMIT 1
	) AS prolific_actor
);

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables 
-- to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT f.title
FROM film f
WHERE f.film_id IN (
	SELECT i.film_id
	FROM inventory i
	WHERE i.inventory_id IN (
		SELECT r.inventory_id
		FROM rental r
		WHERE r.customer_id = (
			SELECT c.customer_id
			FROM customer c
			WHERE c.customer_id = (
				SELECT p.customer_id
				FROM payment p
				GROUP BY p.customer_id
				order BY SUM(p.amount) DESC
				LIMIT 1
			)
		)
	)
);

SELECT f.title, c.first_name, c.last_name
FROM film f
JOIN inventory i
USING (film_id)
JOIN rental r
USING (inventory_id)
JOIN customer c
USING (customer_id)
WHERE c.customer_id = (
  SELECT customer_id
  FROM payment
  GROUP BY customer_id
  ORDER BY SUM(amount) DESC
  LIMIT 1
);


-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount 
-- spent by each client. You can use subqueries to accomplish this.

SELECT customer_id, c.first_name, c.last_name, total_amount_spent
FROM (
  SELECT customer_id, SUM(amount) AS total_amount_spent
  FROM payment
  GROUP BY customer_id
) AS customer_payments
JOIN customer c
USING (customer_id)
WHERE total_amount_spent > (
  SELECT AVG(total_amount_spent)
  FROM (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
  ) AS avg_payments
);














