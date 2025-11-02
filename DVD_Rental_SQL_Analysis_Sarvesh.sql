USE sakila;

-- Start Understanding of Tables 
SELECT * FROM actor; -- Actor table is all about actor_id and there name, last update 
SELECT COUNT(DISTINCT actor_id) FROM actor; -- Around 200 Actor are found

SELECT * FROM address; -- Address table about adresses not useful

SELECT * FROM category; -- Category table is about category of movie
SELECT COUNT(DISTINCT name) FROM category; -- Around 16 movie categorys found

SELECT * FROM customer; -- Deatail about customer such as Customer_id, store_id, address_id and there is active status of customer
SELECT COUNT(DISTINCT customer_id) FROM customer; -- there are around 599 customer details
SELECT active As activity_status,COUNT(customer_id) AS Activity_Status FROM customer
GROUP BY active; -- Here around 584 customer( active) & 15 customer (non active)

SELECT * FROM film; -- film is aslo important table main columns film_id,description,rental_duration,rental_rate,replacement_cost
SELECT COUNT(DISTINCT film_id) FROM film; -- there are 1000 films

SELECT rental_duration, COUNT(*) AS film_count,
ROUND((COUNT(*) / (SELECT COUNT(*) FROM film)) * 100, 2) AS percentage_of_total
FROM film
GROUP BY rental_duration
ORDER BY rental_duration DESC;

-- Insight - Films with 6-day rental durations are most common (21.2%), 
-- followed closely by 3–4-day rentals (around 20% each), indicating balanced rental period preferences.

SELECT * FROM film_actor; -- Have columns like actor_id,film_id useful during join
SELECT * FROM film_category; -- Have columns like film_id,categor_id useful during join
SELECT * FROM film_text; -- Description of film

SELECT * FROm inventory; -- Have a columns like inventory_id,film_id,store_id

SELECT * FROM rental; -- Have deatails of rental_date,return_date
SELECT * FROM staff; -- satff Details
SELECT * FROM store; -- store deatils

-- Data Quality Validation – Null Value Check
SELECT 
  -- Customer Table Check
  SUM(CASE WHEN c.customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN c.active IS NULL THEN 1 ELSE 0 END) AS null_active,
  
  -- Rental Table Check
  SUM(CASE WHEN r.rental_id IS NULL THEN 1 ELSE 0 END) AS null_rental_id,
  SUM(CASE WHEN r.rental_date IS NULL THEN 1 ELSE 0 END) AS null_rental_date,
  SUM(CASE WHEN r.inventory_id IS NULL THEN 1 ELSE 0 END) AS null_inventory_id
FROM customer c;

-- IN BOTH THERE ARE NO NULL VLAUES

-- Data cleaning and preprocessing

-- TABLE rental
SELECT * FROM rental;
WITH duplicate_rental AS(
SELECT * ,ROW_NUMBER() OVER(
PARTITION BY inventory_id,customer_id,rental_date,return_date
ORDER BY rental_id
) rn
FROM rental)
SELECT * FROM duplicate_rental
WHERE rn>1;
-- RESLUT Same no duplicate

-- TABLE film
SELECT * FROM film;
SELECT * FROM (
SELECT film_id,title,description,release_year,language_id,
ROW_NUMBER() OVER(PARTITION BY title,description,release_year,language_id ORDER BY film_id) as rn
FROM film) AS duplicate_film
WHERE rn>2;
-- Result: No duplicate rows found in the film table. Data is clean and consistent.

-- Verify whether all customers have rental records
SELECT COUNT(customer_id) FROM customer;
SELECT COUNT(DISTINCT customer_id) FROM rental;
-- Observation: Both counts are 599, meaning every customer has made at least one rental.
-- Note: Some inactive customers exist, likely due to having past rental history but no recent activity.

-- Validate record consistency between film and film_text tables
SELECT COUNT(*) FROM film_text;
SELECT COUNT(*)FROM film; -- okay
-- Result: Record counts match. Data between film and film_text tables is synchronized.

-- Business problem solving
-- 1.Identify the most rented films and their categories.
-- 1) Top 10 Films by Rental Count
WITH film_popularity AS (
  SELECT R.rental_id, I.film_id, F.title, FC.category_id, C.name
  FROM rental AS R
  JOIN inventory AS I ON R.inventory_id = I.inventory_id
  JOIN film AS F ON I.film_id = F.film_id
  JOIN film_category AS FC ON F.film_id = FC.film_id
  JOIN category AS C ON FC.category_id = C.category_id
)
SELECT title, COUNT(rental_id) AS Rent_count
FROM film_popularity
GROUP BY film_id, title
ORDER BY Rent_count DESC;
-- LIMIT 10;

-- RENTALS BY GENRE (popularity by genre):
WITH film_popularity AS (
  SELECT R.rental_id, I.film_id, F.title, FC.category_id, C.name
  FROM rental AS R
  JOIN inventory AS I ON R.inventory_id = I.inventory_id
  JOIN film AS F ON I.film_id = F.film_id
  JOIN film_category AS FC ON F.film_id = FC.film_id
  JOIN category AS C ON FC.category_id = C.category_id
)
SELECT 
  name AS category,
  COUNT(rental_id) AS rental_count,
  ROUND(COUNT(rental_id) * 100.0 / (SELECT COUNT(*) FROM rental), 1) AS rental_percentage
FROM film_popularity
GROUP BY category_id, name
ORDER BY rental_count DESC;

-- INSIGHT:
-- Sports, Animation, and Action lead with around 7% of total rentals each, 
-- while the top five genres together capture over 35% of demand—showing audiences prefer energetic and family-oriented content, 
-- with steady but lower interest in niche genres like Horror, Travel, and Music.y entertainment.


 -- 2.Determine the top customers based on rental frequency and total payments.
 
WITH rentals AS (
  SELECT customer_id, COUNT(*) AS rent_count
  FROM rental
  GROUP BY customer_id
),
payments AS (
  SELECT customer_id,
         COUNT(*) AS payment_count,
         SUM(amount) AS total_spent,
         AVG(amount) AS avg_payment,
         MAX(payment_date) AS last_payment_date
  FROM payment
  GROUP BY customer_id
)
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  COALESCE(r.rent_count, 0)    AS rent_count,
  COALESCE(p.payment_count,0)  AS payment_count,
  COALESCE(p.total_spent,0.00) AS total_spent,
  COALESCE(p.avg_payment,0.00) AS avg_payment,
  p.last_payment_date,
  CASE
    WHEN COALESCE(p.total_spent,0) >= 200 THEN 'High'
    WHEN COALESCE(p.total_spent,0) >= 100 THEN 'Medium'
    ELSE 'Low'
  END AS spender_segment
FROM customer c
LEFT JOIN rentals r ON c.customer_id = r.customer_id
LEFT JOIN payments p ON c.customer_id = p.customer_id
;
-- GET LIST OF list of all customer and there spender segment use the excel for the insight.
-- BASED on analysis of excel Observation are:
-- Medium spenders (66%) show average rental and payment activity.
-- Low spenders (34%) have minimal engagement and can be targeted for reactivation.
-- High spenders (0.33%) are few but contribute significantly to revenue.
-- Action: Focus on retaining high spenders and upgrading medium customers through offers or loyalty programs.


-- 3.Analyze rental trends over time, including busiest rental months and days.

WITH date_data AS (
  SELECT rental_id,
         DATE(rental_date)      AS rental_date,
         MONTH(rental_date)     AS rental_month_num,
         MONTHNAME(rental_date) AS rental_month,
         YEAR(rental_date)      AS rental_year
  FROM rental
),
payment_data AS (
  SELECT rental_id, payment_id, amount
  FROM payment
)
SELECT D.rental_month,
       D.rental_year,
       COALESCE(SUM(P.amount),0)                     AS total_payment_per_month,
       ROUND(COALESCE(AVG(P.amount),0),2)            AS avg_payment_per_month,
       COUNT(DISTINCT D.rental_id)                   AS rent_count,
       COUNT(P.payment_id)                           AS payment_count
FROM date_data D
LEFT JOIN payment_data P
  ON D.rental_id = P.rental_id
GROUP BY D.rental_year, D.rental_month, D.rental_month_num
ORDER BY D.rental_year, D.rental_month_num;

-- Insight:
-- Rental activity peaked in July–August 2005 with the highest payments and rent counts, showing peak demand mid-year. 
-- Activity dropped sharply by February 2006, indicating an off-season trend


-- 4.Identify the most profitable film categories based on total revenue

-- total revenue.
SELECT SUM(amount) AS total_revenue FROM payment; -- total revenue 67406.56 

-- Most profitable film categories with revenue percentage
SELECT c.name AS category,SUM(p.amount) AS total_revenue,
    ROUND((SUM(p.amount) / SUM(SUM(p.amount)) OVER()) * 100, 2) AS revenue_percentage
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_revenue DESC;

-- Insights:
-- Sports, Sci-Fi, and Animation lead with over 21% of total revenue.
-- Drama and Comedy show stable mid-range performance.
-- Music and Travel earn the least, indicating lower audience interest.

-- 5.Evaluate staff performance by analyzing revenue generated per staff member.

SELECT st.staff_id,CONCAT(st.first_name,' ',st.last_name) AS staff_name,SUM(p.amount) AS total_revenue,
RANK() OVER (ORDER BY SUM(p.amount) DESC) AS staff_rank
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN staff st ON r.staff_id  = st.staff_id
GROUP BY st.staff_id, staff_name;

-- Insight 
-- Jon Stephens achieved the highest total revenue (33,881.94), slightly surpassing Mike Hillyer (33,524.62)
-- indicating both staff have nearly equal strong sales performance.

-- 6.Locate the best-performing stores based revenue.
SELECT s.store_id,SUM(p.amount) AS total_revenue,RANK() OVER (ORDER BY SUM(p.amount) DESC) AS store_rank
FROM payment p
JOIN rental r    ON p.rental_id = r.rental_id
JOIN staff st    ON r.staff_id  = st.staff_id
JOIN store s     ON st.store_id = s.store_id
GROUP BY s.store_id;

-- insight
-- Store 2 leads with a total revenue of 33,881.94, slightly higher than Store 1’s 33,524.62
-- showing nearly equal performance between both stores.

-- Final Insights & Suggestions:
-- Data is clean and consistent across all tables.
-- Sports, Sci-Fi, and Animation generate 21%+ of total revenue.
-- Medium spenders (66%) dominate; high spenders drive major revenue.
-- Rentals peak in July–August, lowest in February.
-- Both stores and staff perform almost equally.
-- Suggestions: Boost off-season rentals, target medium spenders, and promote top-performing genres for higher returns.
