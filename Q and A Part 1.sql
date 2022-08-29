--add question 9 and 10 please
-- 1. What is the total amount each customer spent at the restaurant?
Select customer_id, sum(price) as total_amount
from sales s
inner join menu m
on s.product_id = m.product_id
group by customer_id
order by customer_id

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(distinct(order_date)) as days_visited --- make sure to add distinct otherwise you will be picking duplicate dates
from sales s
group by customer_id
order by customer_id

-- 3. What was the first item from the menu purchased by each customer?
/*The DENSE_RANK() is a window function that assigns a rank to each row within a partition of a result set. Unlike the RANK() function, the DENSE_RANK() function returns consecutive rank values. 
Rows in each partition receive the same ranks if they have the same values.*/
with first_item as(
Select distinct customer_id, product_name, order_date
,dense_rank() OVER (
      PARTITION BY customer_id
      ORDER BY order_date
   ) row_num
from sales s
inner join menu m
on s.product_id = m.product_id)
select customer_id, product_name
from first_item
where row_num = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
--Ans:ramen
select product_name, count(s.product_id) as most_purchased_item
from sales s
inner join menu m
on s.product_id = m.product_id
group by product_name
order by most_purchased_item desc

-- 5. Which item was the most popular for each customer?
with most_popular as (select customer_id, product_name, count(s.product_id) as most_purchased_item
,DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(s.product_id) DESC ) AS ranks --- need top rank for most purchased item
from sales s
inner join menu m
on s.product_id = m.product_id
group by product_name, customer_id
--order by  most_purchased_item desc
)

select
customer_id, most_purchased_item, product_name ,ranks
from most_popular
where ranks = 1

-- 6. Which item was purchased first by the customer after they became a member?
with first_purchased as (select s.customer_id, order_date, s.product_id, product_name, join_date
,DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS ranks
from sales s
inner join members a
on s.customer_id = a.customer_id

inner join menu m
on s.product_id = m.product_id
where  order_date >= join_date

)
select customer_id, product_name, order_date, join_date
from first_purchased
where ranks = 1;

-- 7. Which item was purchased just before the customer became a member?
with just_before_purchased as (select s.customer_id, order_date, s.product_id, product_name, join_date
,DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date desc) AS ranks --- used desc because we like to know the purchased date just before the join date
from sales s
inner join members a
on s.customer_id = a.customer_id

inner join menu m
on s.product_id = m.product_id
where  order_date < join_date

)
select customer_id, product_name, order_date, join_date
from just_before_purchased
where ranks = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
with total_items_and_amount as (select s.customer_id,  count(s.product_id) as total_items,  sum(Price) as price

from sales s
inner join members a
on s.customer_id = a.customer_id

inner join menu m
on s.product_id = m.product_id
where  order_date < join_date
group by s.customer_id,  s.product_id

)
select customer_id, sum(total_items) as total_items, sum(price) as price --, --order_date, join_date
from total_items_and_amount
group by customer_id




