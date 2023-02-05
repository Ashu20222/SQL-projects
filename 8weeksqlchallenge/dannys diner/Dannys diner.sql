use dannys_diner;

/* Question: 1
What is the total amount each customer spent at the restaurant? */

SELECT S.customer_id, SUM(price) AS total_sales
FROM sales AS S
JOIN menu AS M
  ON S.product_id = M.product_id
GROUP BY customer_id; 

/* Question: 2
How many days has each customer visited the restaurant? */

SELECT customer_id, COUNT(DISTINCT(order_date)) AS visit_count
FROM sales
GROUP BY customer_id;

/* Question: 3
What was the first item from the menu purchased by each customer? */

WITH ordered_sales_cte AS
(
  SELECT customer_id, order_date, product_name,
   DENSE_RANK() OVER(PARTITION BY s.customer_id
   ORDER BY s.order_date) AS ranks
  FROM sales AS s
  JOIN menu AS m
   ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE ranks = 1
GROUP BY customer_id, product_name;

/* Question: 4
What is the most purchased item on the menu and how many times was it purchased by all customers? */

SELECT product_name, COUNT(s.product_id) AS total_purchased
FROM menu AS m
JOIN sales AS s
ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY total_purchased DESC
LIMIT 1;

/* Question: 5
Which item was the most popular for each customer? */

SELECT customer_id, product_name, order_count
FROM (
SELECT s.customer_id, m.product_name, COUNT(m.product_id) AS order_count,
ROW_NUMBER() OVER(PARTITION BY s.customer_id
ORDER BY COUNT(s.customer_id) DESC) AS rn
FROM menu AS m
JOIN sales AS s
ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
) subq
WHERE rn = 1;

/* Question: 6
Which item was purchased first by the customer after they became a member? */

WITH first_order_cte AS
(
SELECT s.customer_id, MIN(s.order_date) AS first_order_date
FROM sales AS s
JOIN members AS m
ON s.customer_id = m.customer_id
WHERE s.order_date >= m.join_date
GROUP BY s.customer_id
)

SELECT s.customer_id, s.order_date, m.product_name
FROM first_order_cte AS f
JOIN sales AS s
ON f.customer_id = s.customer_id AND f.first_order_date = s.order_date
JOIN menu AS m
ON s.product_id = m.product_id;

/* Question: 7
Which item was purchased just before the customer became a member? */

WITH prior_purchases AS (
SELECT
sales.customer_id,
members.join_date,
sales.order_date,
sales.product_id,
DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS ranks
FROM
sales
JOIN members
ON sales.customer_id = members.customer_id
WHERE
order_date < join_date
)
SELECT
customer_id,
order_date,
product_name
FROM
prior_purchases
JOIN menu
ON prior_purchases.product_id = menu.product_id
WHERE
ranks = 1;

/* Question: 8
What is the total items and amount spent for each member before they became a member? */

SELECT
sales.customer_id,
COUNT(DISTINCT sales.product_id) AS unique_menu_item,
SUM(price) AS total_sales
FROM
sales
JOIN members
ON sales.customer_id = members.customer_id
JOIN menu
ON sales.product_id = menu.product_id
WHERE
order_date < join_date
GROUP BY
customer_id;

/* Question: 9
If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have? */

WITH product_points AS (
SELECT
*,
CASE
WHEN product_id = 1 THEN price * 20
ELSE price * 10
END AS points
FROM
menu
)
SELECT
sales.customer_id,
SUM(product_points.points) AS total_points
FROM
product_points
JOIN sales
ON product_points.product_id = sales.product_id
GROUP BY
customer_id;

/* Question: 10
In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January? */

WITH dates_cte AS 
(
  SELECT *, 
   DATEADD(DAY, 6, join_date) AS valid_date, 
   EOMONTH('2021-01-31') AS last_date
  FROM members AS m
)

SELECT d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price,
  SUM(CASE
   WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
   WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
   ELSE 10 * m.price
   END) AS points
FROM dates_cte AS d
JOIN sales AS s
  ON d.customer_id = s.customer_id
JOIN menu AS m
  ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price;


/* Bonus Questions

Q.1 Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N) */

SELECT s.customer_id, s.order_date, m.product_name, m.price,
   CASE
      WHEN mm.join_date > s.order_date THEN 'N'
      WHEN mm.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
      END AS member
FROM sales AS s
LEFT JOIN menu AS m
   ON s.product_id = m.product_id
LEFT JOIN members AS mm
   ON s.customer_id = mm.customer_id;
   
/* Q.2 Rank All The Things - Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program. */

WITH summary_cte AS
(
SELECT
	s.customer_id,
	s.order_date,
	m.product_name,
	m.price,
	CASE
		WHEN mm.join_date > s.order_date THEN 'N'
		WHEN mm.join_date <= s.order_date THEN 'Y'
		ELSE 'N'
	END AS is_member
FROM sales s
LEFT JOIN menu m 
	ON s.product_id = m.product_id
LEFT JOIN members mm 
	ON s.customer_id = mm.customer_id
)
SELECT *,
	CASE
	WHEN is_member = 'N' THEN NULL
	ELSE RANK() OVER (PARTITION BY customer_id, is_member ORDER BY order_date)
	END AS customer_rank
FROM summary_cte;





