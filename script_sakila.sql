/* Email Campaigns for customers of Store 2 */
First, Last name and Email address of customers from Store 2
SELECT first_name, last_name, email 
FROM customer
WHERE store_id = 2; 

/* movie with rental rate of 0.99$ */
SELECT COUNT(*) FROM film
WHERE rental_rate = 0.99; 

/* we want to see rental rate and how many movies are in each rental rate categories */
SELECT rental_rate, COUNT(*) AS total_number_of_movies FROM film
GROUP BY 1; 

/*Which rating do we have the most films in? */
SELECT rating, COUNT(*) AS total_number_of_movies FROM film
GROUP BY 1; 

/*Which rating is most prevalant in each store? */
SELECT s.store_id, f.rating, COUNT(f.rating) AS total_number_of_films FROM store s
INNER JOIN inventory i
ON s.store_id = i.store_id
INNER JOIN film f
ON f.film_id = i.film_id
GROUP BY 1, 2; 

/*We want to mail the customers about the upcoming promotion */
SELECT c.customer_id, c.first_name, c.last_name, a.address_id FROM customer c
INNER JOIN address a
ON c.address_id = a.address_id; 

/* List of films by Film Name, Category, Language */
SELECT f.title, c.name, l.name FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
INNER JOIN language l
ON f.language_id = l.language_id; 

/* How many times each movie has been rented out? */
SELECT i.film_id, f.title, COUNT(i.film_id) AS total_number_of_rental_times FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY i.film_id
ORDER BY 3 DESC; 

/*Revenue per Movie */
SELECT i.film_id, f.title, COUNT(i.film_id) AS total_number_of_rental_times, f.rental_rate, 
	COUNT(i.film_id)*f.rental_rate AS revenue_per_movie
FROM rental r
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON i.film_id = f.film_id
GROUP BY 1
ORDER BY 5 DESC; 

/* Most Spending Customer so that we can send him/her rewards or debate points */
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS "Total Spending" FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY 1
ORDER BY 4 DESC; 

/* What Store has historically brought the most revenue */
SELECT s.store_id, SUM(p.amount) "Total Spending" FROM store s
INNER JOIN inventory i
ON  s.store_id = i.store_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY 1
ORDER BY 2 DESC; 

/*How many rentals we have for each Month */
SELECT LEFT(rental_date,7) AS "Month", COUNT(*) FROM rental
GROUP BY 1; 

/* Rentals per Month (such Jan => How much, etc)*/
SELECT DATE_FORMAT(rental_date,"%M") AS "Month", COUNT(*) FROM rental
GROUP BY 1;

/* Which date first movie was rented out ? */
SELECT MIN(rental_date) FROM rental;

/* Which date last movie was rented out ? */
SELECT MAX(rental_date) FROM rental;

/* For each movie, when was the first time and last time it was rented out? */
SELECT f.title AS "Film Title", MIN(rental_date) AS "First Rented Date", MAX(rental_date) AS "Last Rented Date" 
	FROM rental r
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON i.film_id = f.film_id
GROUP BY 1;

/* Last Rental Date of every customer */
SELECT c.customer_id, c.first_name, c.last_name, MAX(rental_date) AS "Last Rented Date" FROM rental r
INNER JOIN customer c
ON r.customer_id = c.customer_id
GROUP BY 1;

/* Revenue Per Month */
SELECT LEFT(payment_date,7) AS "Month", SUM(amount) AS "Revenue Per Month" FROM payment
GROUP BY 1;

/* How many distint Renters per month*/
SELECT LEFT(rental_date,7) AS "Month",
	COUNT(DISTINCT(rental_id)) AS "Total Rentals",
    COUNT(DISTINCT(customer_id)) AS "Total Unique Renter",
    COUNT(DISTINCT(rental_id))/COUNT(DISTINCT(customer_id)) AS "Average Rent per Renter"
FROM rental
GROUP BY 1;

/*Number of Distinct Film Rented Each Month */
SELECT i.film_id, f.title, LEFT(r.rental_date,7) AS "Month" , COUNT(i.film_id) AS "Total Number of Rental Times"
FROM rental r
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON i.film_id = f.film_id
GROUP BY 1,2,3;

/* Number of Rentals in Comedy , Sports and Family */
SELECT c.name, COUNT(c.name) AS "Number of Rentals" FROM rental r
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc
ON i.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE c.name IN ('Comedy', 'Sports', 'Family')
GROUP BY 1;

/*Users who have been rented at least 3 times*/
SELECT c.customer_id, CONCAT(c.first_name," ",c.last_name) AS "Customer Name", 
	COUNT(c.customer_id) AS "Total Rentals" FROM rental r
INNER JOIN customer c
ON r.customer_id = c.customer_id
GROUP BY 1
HAVING COUNT(c.customer_id) >= 3
ORDER BY 1;

/*How much revenue has one single store made over PG13 and R rated films*/
SELECT s.store_id, f.rating, SUM(p.amount) AS "Total Revenue" FROM store s
INNER JOIN inventory i
ON s.store_id = i.store_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p
ON r.rental_id = p.rental_id
INNER JOIN film f
ON i.film_id = f.film_id
WHERE f.rating IN ('PG-13', 'R')
GROUP BY 1,2;

/******************************************/

/* Active User  where active = 1*/
DROP TEMPORARY TABLE IF EXISTS tbl_active_users;
CREATE TEMPORARY TABLE tbl_active_users(
SELECT c.*, a.phone
FROM customer c
INNER JOIN address a ON a.address_id = c.address_id
WHERE c.active = 1);

/* Reward Users : who has rented at least 30 times*/
DROP TEMPORARY TABLE IF EXISTS tbl_rewards_user;
CREATE TEMPORARY TABLE tbl_rewards_user(
SELECT r.customer_id, COUNT(r.customer_id) AS "Total Rents", MAX(r.rental_date) AS "Last Rental Date"
FROM rental r
GROUP BY 1
HAVING COUNT(r.customer_id) >= 30);

/* Reward Users who are also active */
SELECT au.customer_id, au.first_name, au.last_name, au.email
FROM tbl_rewards_user ru
INNER JOIN tbl_active_users au ON au.customer_id = ru.customer_id;

/* All Rewards Users with Phone */
SELECT ru.customer_id, c.email, au.phone
FROM tbl_rewards_user ru
LEFT JOIN tbl_active_users au ON au.customer_id = ru.customer_id
JOIN customer c ON c.customer_id = ru.customer_id;