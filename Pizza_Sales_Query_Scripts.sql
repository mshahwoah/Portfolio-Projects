-- Reveal All Data Table
select *
from pizza_sales;

-- Total Revenue
select sum(total_price) as total_revenue
from pizza_sales;

-- Total Revenue Clean Price (remove decimal into 2 decimal point by using round)
select round(sum(total_price),2) as total_revenue
from pizza_sales;

-- Average Order Value
select sum(total_price) / count(distinct order_id) as avg_order_value
from pizza_sales;

-- Average Order Value Clean Version
select round(sum(total_price) / count(distinct order_id),2) as avg_order_value
from pizza_sales;

-- Total Pizza Sold
select sum(quantity)  as total_pizza_sold
from pizza_sales;

-- Total Pizza Orders
select count(distinct order_id)  as total_pizza_orders
from pizza_sales;

-- Average Pizza per Order
select sum(quantity) / count(distinct order_id)  as avg_pizza_per_order
from pizza_sales;

-- Daily Trend Total Order (Bar Chart)
select coalesce(dayname(str_to_date(order_date, '%d-%m-%Y')), 'Invalid Date') as order_day, count(distinct order_id) as total_orders
from pizza_sales
group by coalesce(dayname(str_to_date(order_date, '%d-%m-%Y')), 'Invalid Date')
order by order_day desc;

-- Hourly Trend Total Order (Line Chart)
select hour(order_time) as order_hours, count(distinct order_id) as total_orders 
from pizza_sales 
group by hour(order_time)
order by hour(order_time);

-- Percentage of Sales by Pizza Category (Pie Chart)
select pizza_category, round(sum(total_price),2) as total_revenue, round(sum(total_price) * 100 / (
select sum(total_price)
from pizza_sales),2) as pizza_sales_percentage 
from pizza_sales
group by pizza_category;

-- Applying filter for Monthly/Weekly(January/1st Week = 1)
select pizza_category, round(sum(total_price),2) as total_revenue, sum(total_price) * 100 / (
select sum(total_price) 
from pizza_sales
where month(str_to_date(order_date, '%d-%m-%Y')) = 1) as pizza_sales_percentage 
from pizza_sales
where month(str_to_date(order_date, '%d-%m-%Y')) = 1
group by pizza_category;


-- Applying filter for Quarterly (Quarter 1 = 1)
select pizza_category, round(sum(total_price),2) as total_revenue, sum(total_price) * 100 / (
select sum(total_price) 
from pizza_sales
where quarter(str_to_date(order_date, '%d-%m-%Y')) = 1) as pizza_sales_percentage 
from pizza_sales
where quarter(str_to_date(order_date, '%d-%m-%Y')) = 1
group by pizza_category;

-- Percentage of Sales by Pizza Size (Pie Chart)
select pizza_size, round(sum(total_price),2) as total_revenue, round(sum(total_price) * 100 / (
select sum(total_price)
from pizza_sales),2) as pizza_sales_percentage 
from pizza_sales
group by pizza_size
order by pizza_sales_percentage desc;

-- Total Pizza Sold by Pizza Category
select pizza_category, sum(quantity) as total_pizza_sold
from pizza_sales
group by pizza_category;

-- Top 5 Best Selling by Total Pizza Sold
select pizza_name, sum(quantity) as total_pizza_sold 
from pizza_sales 
group by pizza_name
order by total_pizza_sold desc
limit 5;

-- Bottom 5 Worst Selling by Total Pizza Sold
select pizza_name, sum(quantity) as total_pizza_sold 
from pizza_sales 
group by pizza_name
order by total_pizza_sold asc 
limit 5;
