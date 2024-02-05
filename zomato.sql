use zomato;
select * from orders;

/* Q1) Find customers who have never ordered */
select name from users 
where user_id not in (select user_id from orders);

/* Q2) AVERAGE PRICE of dish  */
select f.f_name,AVG(price) as 'AVG_Price' 
from menu m JOIN food f 
ON m.f_id=f.f_id 
group by m.f_id, f.f_name;

/* Q3)Find top restautants in terms of a number of orders for a given month */
SELECT r.r_name, COUNT(*) AS no_of_orders
FROM orders o
JOIN restaurants r ON o.r_id = r.r_id
WHERE MONTHNAME(o.date) = 'July'
GROUP BY o.r_id, r.r_name
ORDER BY no_of_orders DESC
LIMIT 1;

/*Restaurants with monthly sales>500 */
select r.r_name,sum(o.amount) as sales
from restaurants r JOIN orders o 
ON r.r_id=o.r_id 
where monthname(o.date) = 'JUNE'  
group by r.r_id,r.r_name having sales>500
order by sales desc;

/*Q5) Show all orders with order details for a particular customer in a particular data range*/
select o.order_id,r.r_name,f.f_name,o.date from
orders o JOIN order_details od ON  o.order_id=od.order_id
JOIN restaurants r ON o.r_id=r.r_id
JOIN food f ON f.f_id=od.f_id
where user_id= (select user_id from users where name like 'ANKIT') 
and date between '2022-05-14' and '2022-07-05';

/*Q6)Find restaurants with max repeated customers */
select r.r_name,count(*) as 'loyal_customers' from
	(select user_id,r_id,count(*) as 'visits' 
     from orders group by r_id,user_id 
	 having visits>1 ) t
JOIN restaurants r ON t.r_id=r.r_id
group by r.r_id,r.r_name 
order by loyal_customers desc limit 1;

/* Q7)Month over month revenue growth of zomato */
with t as
  (
	select  monthname(date) as month,
	sum(amount) as revenue,
	lag(sum(amount)) over (order by date) as prevRevenue
	from orders group by month order by date
  )
select month,revenue,
((revenue-prevRevenue)/prevRevenue)*100 as 'revenue growth (%)' from t;

/* Q8)customers-->favourite food */
with temp as
(
	select o.user_id,od.f_id,count(*) as 'frequency'
    from orders o 
    join order_details od
    ON o.order_id=od.order_id
    group by o.user_id,od.f_id
)
select u.name,f.f_name from temp t1 
join users u on u.user_id=t1.user_id 
join food f on f.f_id=t1.f_id
where t1.frequency=(select max(frequency) from temp t2 
where t2.user_id=t1.user_id
)