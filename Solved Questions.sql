-- Basic level Questions

/* Retrieve the total number of orders placed */
select count(distinct order_id) 'Total Orders' from dataproject.order_details

-- Calculate the total revenue generated from pizza sales.
order_detailspizzas
select round(sum(p.price * o.quantity),2) as 'total revenue'
from dataproject.pizzas p
join dataproject.order_details o on p.pizza_id = o.pizza_id;

-- Identify the highest-priced pizza.
select pt.name, p.price from dataproject.pizza_types pt
join dataproject.pizzas as p on pt.pizza_type_id=p.pizza_type_id
where p.price in (select max(price) from dataproject.pizzas)
                 -- or
 select pt.name, p.price from dataproject.pizza_types pt
join dataproject.pizzas as p on pt.pizza_type_id=p.pizza_type_id
order by p.price desc
limit 1;            

-- Identify the most common pizza size ordered.
select p.size as Size, sum(o.quantity) as quantity from dataproject.order_details o
join dataproject.pizzas p on p.pizza_id=o.pizza_id
group by  p.size
order by quantity desc ;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name, sum(p.quantity) as Quantity from dataproject.pizza_types pt
join (select o.pizza_id, b.pizza_type_id, o.quantity as quantity from dataproject.order_details o
  join dataproject.pizzas b on b.pizza_id=o.pizza_id) p 
  on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by Quantity desc limit 5;

-- Intermediate level Questions
-- Find the total quantity of each pizza category ordered (this will help us to understand the category which customers prefer the most).
select pt.category, sum(od.quantity) as Quantity from dataproject.order_details od
join dataproject.pizzas as p on p.pizza_id= od.pizza_id
join dataproject.pizza_types as pt on pt.pizza_type_id= p.pizza_type_id
group by pt.category
order by Quantity desc

-- Determine the distribution of orders by hour of the day (at which time the orders are maximum).
select hour(time) as hour_of_day, count(order_id) as "total orders"
from dataproject.orders
group by hour_of_day
order by hour_of_day desc

-- Group the orders by date and calculate the average number of pizzas ordered per day.
with cte as (
	select o.date, sum(od.quantity) as for_day
    from dataproject.orders o
    join dataproject.order_details od on o.order_id=od.order_id
    group by o.date
)
select round(avg(for_day),0) as "Pizza ordered per day" from cte

-- Determine the top 3 most ordered pizza types based on revenue 
	select pt.name, sum(od.quantity*p.price) as Revenue
    from dataproject.order_details as od
    join dataproject.pizzas as p on p.pizza_id=od.pizza_id
    join dataproject.pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
    group by pt.name
    order by Revenue desc
    limit 3
    
-- Advanced level Questions

-- Calculate the percentage contribution of each pizza type to total revenue 
with cte as (
  select sum(o.quantity * p.price) as revenue
  from dataproject.order_details o
  join dataproject.pizzas p on p.pizza_id = o.pizza_id
)
select pt.name,
       round(sum(o.quantity * p.price / cte.revenue) * 100,2) as percentage_contribution
from dataproject.order_details o
join dataproject.pizzas p on o.pizza_id = p.pizza_id
join dataproject.pizza_types pt on p.pizza_type_id = pt.pizza_type_id
join cte on 1=1
group by pt.name
order by percentage_contribution desc;


/* UPDATE dataproject.orders
SET date = STR_TO_DATE(date, '%d-%m-%Y');
alter table dataproject.orders 
modify column date date */

-- Analyze the cumulative revenue generated over time.

with cte as (select month(o.date) as month, sum(od.quantity*p.price) as Revenue
from dataproject.orders o 
join dataproject.order_details as od on od.order_id=o.order_id
join dataproject.pizzas as p on p.pizza_id=od.pizza_id
group by month(o.date)
order by month(o.date) asc
)

select round(sum(cte.Revenue) over (order by cte.month), 1) as Cumulative_revenue
from cte
