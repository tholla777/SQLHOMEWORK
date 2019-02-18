-- 1a. Display the first and last names of all actors from the table `actor`
use sakila;
select* from actor;
select first_name, last_name
from actor; 

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`
ALTER TABLE actor ADD COLUMN Actor_Name VARCHAR(100);
-- Update the current values:
UPDATE actor SET Actor_Name  = CONCAT(first_name, ' ', last_name);
select* from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = "Joe";

-- Find all actors whose last name contain the letters `GEN`:
select* from actor where last_name like '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select last_name, first_name from actor where last_name like '%LI%';

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country IN ('Afghanistan', 'Bangladesh', 'China');
 

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD COLUMN Description BLOB;
select* from actor;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP Description;
select* from actor;


-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name,COUNT(last_name)
    FROM actor
    GROUP BY last_name;

--  4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
    FROM actor
    GROUP BY last_name
    HAVING COUNT(last_name) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO";
select* from actor where last_name= "Williams";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";
select* from actor where last_name= "Williams";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address
FROM actor
INNER JOIN staff ON actor.authorId = authors.id;

SELECT address, first_name, last_name
from address
JOIN staff
ON (city_id = city_id);

select* from payment;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff_id, amount, payment_date
from payment
JOIN staff
USING (staff_id)
where payment_date like '%2005-08%';
-- Group BY staff_id;





-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title AS 'Film', COUNT(film_actor.actor_id) AS `# of Actors`
FROM film_actor
JOIN film 
ON film_actor.film_id= film.film_id
GROUP BY film.title;


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, count(film_id)
from film
JOIN inventory
USING (film_id)
where title = "Hunchback Impossible";

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.last_name, customer.customer_id, SUM(payment.amount)
FROM customer
JOIN payment
ON (customer.customer_id = payment.customer_id)
GROUP BY customer.customer_id, customer.last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT film.title, language.name 
FROM film
JOIN language
ON (film.language_id = language.language_id)
WHERE film.title like 'K%'
OR film.title like 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
Select actor_id
FROM film_actor
WHERE film_id IN 
(
SELECT film_id
FROM film
WHERE title = 'Alone Trip'
));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information
SELECT customer.first_name, customer.last_name, customer.email 
FROM customer
JOIN address 
ON (customer.address_id = address.address_id)
JOIN city
ON (city.city_id = address.city_id)
JOIN country
ON (country.country_id = city.country_id)
WHERE country.country= 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films. 
-- select category.name, film_category.film_id,  
-- from category
SELECT title FROM film 
WHERE film_id IN
(
SELECT film_id FROM film_category
WHERE category_id IN
(
SELECT category_id FROM category
WHERE name = "Family"
));


-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental_id) AS 'Times Rented'
FROM rental 
JOIN inventory
ON (rental.inventory_id = inventory.inventory_id)
JOIN film
ON (inventory.film_id = film.film_id)
GROUP BY film.title
ORDER BY `Times Rented` DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount)
FROM payment
JOIN rental
ON (payment.rental_id = rental.rental_id)
JOIN inventory
ON (inventory.inventory_id = rental.inventory_id)
JOIN store
ON (store.store_id = inventory.store_id)
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country 
FROM store
JOIN address 
ON (store.address_id = address.address_id)
JOIN city
ON (city.city_id = address.city_id)
JOIN country
ON (country.country_id = city.country_id);

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) 
FROM category
JOIN film_category 
ON (category.category_id=film_category.category_id)
JOIN inventory
ON (film_category.film_id=inventory.film_id)
JOIN rental 
ON (inventory.inventory_id=rental.inventory_id)
JOIN payment
ON (rental.rental_id=payment.rental_id)
GROUP BY category.name;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view
CREATE VIEW execrevenue_genre AS
SELECT category.name, SUM(payment.amount) AS Revenue
FROM category
JOIN film_category 
ON (category.category_id=film_category.category_id)
JOIN inventory
ON (film_category.film_id=inventory.film_id)
JOIN rental 
ON (inventory.inventory_id=rental.inventory_id)
JOIN payment 
ON (rental.rental_id=payment.rental_id)
GROUP BY category.name ORDER BY Revenue LIMIT 5; 

-- 8b. How would you display the view that you created in 8a?
SELECT* FROM execrevenue_genre;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW execrevenue_genre;

