/* Question 1:

Find the total number of bathrooms and bedrooms for each city’s property types. 
Output the result along with the city name and the property type. */

-- Answer : --

select city, property_type, avg(bathrooms) as n_average_of_Bathroom, avg(bedrooms) as n_average_of_bedroom
from airbnb_search_details
group by city, property_type;

/* Question 2: 

Count the number of user events performed by MacBookPro users.
Output the result along with the event name.
Sort the result based on the event count in the descending order. */

-- Answer : --

select event_name, count(user_id) as event_count
from playbook_events
where device = 'macbook pro'
group by event_name
order by event_name;

/* Question 3:

Find the most profitable company from the financial sector.
Output the result along with the continent. */

-- Answer: --

select company,continent 
from forbes_global_2010_2014 
where sector = 'Financials'
and profits = 
  (select max(profits) 
  from forbes_global_2010_2014);
  
/* Question 4:

Find the activity date and the pe_description of facilities with the name 'STREET CHURROS' 
and with a score of less than 95 points. */

-- Answer : --

select 
  activity_date,
  pe_description
from los_angeles_restaurant_health_inspections
where facility_name like '%STREET CHURROS%' and score < 95;

/* Question 5:

Find the details of each customer regardless of whether the customer made an order. 
Output the customer's first name, last name, and the city along with the order details.
You may have duplicate rows in your results due to a customer ordering several of the same items. 
Sort records based on the customer's first name and the order details in ascending order. */

-- Answer : --

select c.first_name, c.last_name, c.city, o.order_details
from customers as c
left join orders as o
on c.id = o.cust_id
order by c.first_name , o.order_details asc;

/* Question 6:

Find order details made by Jill and Eva.
Consider the Jill and Eva as first names of customers.
Output the order date, details and cost along with the first name.
Order records based on the customer id in ascending order. */

-- Answer: --

select a.first_name, b.order_date, b.order_details, b.total_order_cost
FROM customers a
JOIN orders b on a.id = b.cust_id
WHERE a.first_name IN ('Jill','Eva')
ORDER BY a.id ASC;

/* Question 7:

Find the activity date and the pe_description of facilities with the name 'STREET CHURROS' 
and with a score of less than 95 points. */

-- Answer : --

select 
  department, 
  first_name, 
  salary, 
  avg(salary) over(partition by department)
from employee;

/* Question 8:

Find libraries who havent provided the email address in circulation year 2016 
but their notice preference definition is set to email.
Output the library code.*/

-- Answer : --

select distinct(home_library_code)
from library_usage
where notice_preference_definition = 'email' AND 
  provided_email_address is FALSE AND 
  circulation_active_year = 2016;

/* Question 9:

Find the base pay for Police Captains.
Output the employee name along with the corresponding base pay. */

-- Answer: --

select 
  employeename, 
  basepay
from sf_public_salaries
where lower(jobtitle) like '%captain%police%';

/* Question 10:

Find how many times each artist appeared on the Spotify ranking list
Output the artist name along with the corresponding number of occurrences.
Order records by the number of occurrences in descending order.*/

-- Answer : --

select artist, count(*) as n_occurrence 
from spotify_worldwide_daily_song_ranking
group by artist
order by n_occurrence desc;

/* Question 11:

Find all Lyft drivers who earn either equal to or less than 30k USD or equal to or more than 70k USD.
Output all details related to retrieved records. */

-- Answer : --

SELECT * 
FROM lyft_drivers
WHERE yearly_salary <= '30000' OR yearly_salary >= '70000'
ORDER BY yearly_salary DESC;

/* Question 12:

Meta/Facebook has developed a new programing language called Hack.To measure the popularity of Hack they ran a survey with their employees. The survey included data on previous programing familiarity as well as the number of years of experience, age, gender and most importantly satisfaction with Hack. Due to an error location data was not collected, but your supervisor demands a report showing average popularity of Hack by office location. Luckily the user IDs of employees completing the surveys were stored.
Based on the above, find the average popularity of the Hack per office location.
Output the location along with the average popularity. */

-- Answer: --

SELECT location, AVG(popularity) AS average_popularity
FROM facebook_employees e
JOIN facebook_hack_survey h ON e.id = h.employee_id
GROUP BY location;

/* Question 13:

Find all posts which were reacted to with a heart. For such posts 
output all columns from facebook_posts table. */

-- Answer : --

SELECT DISTINCT fp.*
FROM facebook_reactions as fr
JOIN facebook_posts as fp
ON fr.post_id = fp.post_id
WHERE fr.reaction = 'heart';

/* Question 14:

Count the number of movies that Abigail Breslin was nominated for an Oscar. */

-- Answer : --

select count(distinct movie) as number_of_movies
from oscar_nominees
where nominee= 'Abigail Breslin' ;

/* Question 15:

Find the last time each bike was in use. Output both the bike number 
and the date-timestamp of the bikes last use (i.e., the date-time the bike was returned). 
Order the results by bikes that were most recently used.*/

-- Answer: --

select bike_number, max(end_time) as last_used
from dc_bikeshare_q1_2012
group by bike_number
order by last_used desc;

/* Question 16:

We have a table with employees and their salaries, however, some of the records are old 
and contain outdated salary information. Find the current salary of each employee assuming 
that salaries increase each year. Output their id, first name, last name, department ID, 
and current salary. Order your list by employee ID in ascending order. */

-- Answer : --

select id, first_name, last_name, department_id, max(salary)
from ms_employee_salary
group by id,first_name, last_name, department_id
order by id asc;

/* Question 17:

Write a query that calculates the difference between the highest salaries 
found in the marketing and engineering departments. Output just the absolute difference in salaries. */

-- Answer : --

select ABS(MAX(eng.salary) - MAX(mkt.salary)) 
from db_employee eng, db_employee mkt
where eng.department_id = 1 and mkt.department_id = 4;
