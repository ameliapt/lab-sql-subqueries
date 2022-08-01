-- SQL LAB 3.2

USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
	title, 
	COUNT(inventory_id) as copies_available 
FROM (
	SELECT 
		i.inventory_id,
		i.film_id,
		f.title
	FROM inventory as i
	LEFT JOIN film as f
	ON i.film_id = f.film_id) as sub
WHERE title = 'HUNCHBACK IMPOSSIBLE';

-- 2. List all films whose length is longer than the average of all the films.
SELECT title, length 
FROM film
WHERE length > (
	SELECT AVG(length) 
    FROM film)
ORDER BY length ASC;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name, title 
FROM (
	SELECT 
		a.first_name, 
		a.last_name, 
		fa.film_id, 
		f.title
	FROM film_actor as fa
	LEFT JOIN actor as a
	ON fa.actor_id = a.actor_id
	LEFT JOIN film as f
	ON fa.film_id = f.film_id) AS sub
WHERE title = "ALONE TRIP";

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT * 
FROM (
	SELECT 
		f.title, 
		c.name AS film_category
	FROM film AS f
	LEFT JOIN film_category AS fc
	ON f.film_id = fc.film_id
	LEFT JOIN category as c
	ON fc.category_id = c.category_id) as sub
WHERE film_category = 'Family';

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.

-- Using subquery
SELECT 
	first_name, 
	last_name, 
	email
FROM customer
WHERE address_id IN (
	SELECT address_id 
	FROM address
	WHERE city_id IN (
		SELECT city_id
		FROM city 
		WHERE country_id = (
			SELECT country_id 
			FROM country
			WHERE country = 'Canada'
			)
		)
	);

-- Using joints
SELECT 
	first_name, 
    last_name, 
    email 
FROM customer
WHERE address_id IN (
	SELECT a.address_id 
	FROM country AS c
	RIGHT JOIN city as ci
	ON c.country_id = ci.country_id
	LEFT JOIN address as a
	ON ci.city_id = a.city_id
	WHERE country = 'Canada' AND address_id IS NOT NULL);

    
-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT * FROM film;

SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id 
	FROM film_actor
	WHERE actor_id = (
		SELECT actor_id
		FROM (
			SELECT 
				fa.actor_id, 
				a.first_name, 
				a.last_name,
				COUNT(film_id) as film_count
			FROM film_actor as fa
			LEFT JOIN actor as a
			ON fa.actor_id = a.actor_id
			GROUP BY a.first_name, a.last_name
			ORDER BY film_count DESC LIMIT 1
			) AS s
		)
	);


-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer 
-- ie the customer that has made the largest sum of payments. 
SELECT title as movies_rented_by_most_profitable_customer 
FROM film
WHERE film_id IN (
	SELECT film_id FROM inventory
	WHERE inventory_id IN (
		SELECT inventory_id FROM rental
		WHERE customer_id = ( 
			SELECT customer_id
				FROM (
				SELECT 
					p.customer_id,
					sum(p.amount) as amount
				FROM payment as p
				LEFT JOIN customer as c
				ON p.customer_id = c.customer_id
				GROUP BY customer_id
				ORDER BY amount DESC LIMIT 1
				) AS subq
			)
		)
	);


-- 8. Customers who spent more than the average payments.
SELECT 
	p.customer_id, 
    c.first_name, 
    c.last_name,
    p.amount
FROM payment as p
LEFT JOIN customer as c
ON p.customer_id = c.customer_id
WHERE amount > (
	SELECT round(AVG(amount),2) as avg_amount
	FROM payment
    )
GROUP BY p.customer_id
ORDER BY p.amount ASC;