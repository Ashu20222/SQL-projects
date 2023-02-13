/* Part A. Pizza Metrics
1. How many pizzas were ordered? */
SELECT COUNT(*) AS pizza_order_count
FROM customer_orders;

/* 2. How many unique customer orders were made? */
SELECT 
  COUNT(DISTINCT order_id) AS unique_order_count
FROM customer_orders;

/* 3. How many successful orders were delivered by each runner? */
SELECT 
  runner_id, 
  COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE distance != 0
GROUP BY runner_id;

/* 4. How many of each type of pizza was delivered? */
SELECT 
 p.pizza_name, 
 COUNT(c.pizza_id) AS delivered_pizza_count
FROM pizza_names AS p
LEFT JOIN customer_orders AS c
 ON c.pizza_id = p.pizza_id
LEFT JOIN runner_orders AS r
 ON c.order_id = r.order_id
AND r.distance != 0
GROUP BY p.pizza_name;

/* 5. How many Vegetarian and Meatlovers were ordered by each customer?*/
SELECT 
 c.customer_id, 
 (SELECT pizza_name FROM pizza_names WHERE pizza_id = c.pizza_id) AS pizza_name, 
 COUNT(c.pizza_id) AS order_count
FROM customer_orders AS c
GROUP BY c.customer_id, c.pizza_id
ORDER BY c.customer_id;

/* 6. What was the maximum number of pizzas delivered in a single order? */
WITH pizza_count_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.pizza_id) AS pizza_per_order
  FROM customer_orders AS c
  JOIN runner_orders AS r
    ON c.order_id = r.order_id
  WHERE r.distance != 0
  GROUP BY c.order_id
)

SELECT 
  MAX(pizza_per_order) AS pizza_count
FROM pizza_count_cte;

/* 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?*/
SELECT 
 c.customer_id,
 SUM(
  CASE WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
  ELSE 0
  END) AS at_least_1_change,
 SUM(
  CASE WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 
  ELSE 0
  END) AS no_change
FROM customer_orders AS c
JOIN runner_orders AS r
 ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;

/* 8. How many pizzas were delivered that had both exclusions and extras?*/
SELECT  
 SUM(
  CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
  ELSE 0
  END) AS pizza_count_w_exclusions_extras
FROM customer_orders AS c
JOIN runner_orders AS r
 ON c.order_id = r.order_id
WHERE r.distance >= 1 
 AND exclusions <> ' ' 
 AND extras <> ' ';

/* 9. What was the total volume of pizzas ordered for each hour of the day? */
SELECT 
  HOUR(order_time) AS hour_of_day, 
  COUNT(order_id) AS pizza_count
FROM customer_orders
GROUP BY HOUR(order_time);

/* 10. What was the volume of orders for each day of the week?*/
SELECT 
  FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week,
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');

/* Part B. Runner and Customer Experience 
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) */
SELECT 
 WEEK(registration_date) AS registration_week,
 COUNT(runner_id) AS runner_signup
FROM runners
GROUP BY WEEK(registration_date);

/* 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? */
WITH time_taken_cte AS

(
 SELECT 
  c.order_id, 
  c.order_time, 
  r.pickup_time, 
  (r.pickup_time - c.order_time) * 1440 AS pickup_minutes
 FROM customer_orders AS c
 JOIN runner_orders AS r
  ON c.order_id = r.order_id
 WHERE r.distance != 0
 GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT 
 AVG(pickup_minutes) AS avg_pickup_minutes
FROM time_taken_cte
WHERE pickup_minutes > 1;


/* 3. Is there any relationship between the number of pizzas and how long the order takes to prepare? */
WITH prep_time_cte AS
(
 SELECT 
  c.order_id, 
  COUNT(c.order_id) AS pizza_order, 
  c.order_time, 
  r.pickup_time, 
  (r.pickup_time - c.order_time) * 1440 AS prep_time_minutes
 FROM customer_orders AS c
 JOIN runner_orders AS r
  ON c.order_id = r.order_id
 WHERE r.distance != 0
 GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT 
 pizza_order, 
 AVG(prep_time_minutes) AS avg_prep_time_minutes
FROM prep_time_cte
WHERE prep_time_minutes > 1
GROUP BY pizza_order;

/* 4. What was the average distance travelled for each customer? */
SELECT 
 c.customer_id, 
 AVG(r.distance) AS avg_distance
FROM customer_orders AS c
JOIN runner_orders AS r
 ON c.order_id = r.order_id
WHERE r.duration != 0
GROUP BY c.customer_id;

/* 5. What was the difference between the longest and shortest delivery times for all orders?*/
SELECT 
 order_id, duration
FROM runner_orders
WHERE duration not like ' ';

/* 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?*/
SELECT
	r.runner_id,
	c.customer_id,
	c.order_id,
	COUNT(DISTINCT c.order_id) AS pizza_count,
	SUM(r.distance) AS total_distance,
	SUM(r.duration) / 60 AS total_duration_hr ,
	SUM(r.distance) / SUM(r.duration) * 60 AS avg_speed
FROM runner_orders AS r
JOIN customer_orders AS c
ON r.order_id = c.order_id
WHERE r.distance != 0
GROUP BY r.runner_id, c.customer_id, c.order_id
ORDER BY c.order_id;

/* 7. What is the successful delivery percentage for each runner? */
SELECT
	runner_id,
	ROUND(100 - 100 * SUM(
	CASE WHEN distance = 0 THEN 1
	ELSE 0 END) / COUNT(*), 0) AS success_perc
FROM runner_orders
GROUP BY runner_id;