create database RPA_Practice;
use RPA_Practice;
show tables;

-- Create Table--
create table Books(
	bookid int,
    title varchar(100),
    author varchar(50),
    genre varchar(50),
    price decimal(5,2),
    stock_quantity int
    );

-- Select Querry:-- 
select * from Books;
insert into Books values(1,'The Martian','Andy Weir','Sci-Fi',14.99,120);
insert into Books values(2,'Atomic Habits','James Clear','Self-Help',11.98,350);
select * from Books;
set sql_safe_updates=0;

-- Update query-- 
update Books set price=12.99,stock_quantity=115 where bookid=1;
update Books set price=15.50 where bookid=2;
select * from Books;

-- Delete Query-- 
delete from Books where bookid=1;
select * from Books;

-- Order By:-- 
select title,author,price from Books order by title;
select title,price from Books order by price desc;
insert into Books values
	(3, 'Dune', 'Frank Herbert', 'Sci-Fi', 10.50, 85),
	(4, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 9.99, 40),
	(5, 'Deep Work', 'Cal Newport', 'Self-Help', 12.50, 200),
	(6, '1984', 'George Orwell', 'Sci-Fi', 8.99, 150),
	(7, 'Thinking, Fast and Slow', 'Daniel Kahneman', 'Self-Help', 14.00, 90);
select * from Books;

-- Math:
select sum(stock_quantity) from Books;
select avg(price) from Books;
select max(price),min(price) from Books;

-- Groupby
select genre,count(bookid) from Books group by genre;
select genre,sum(stock_quantity) from Books group by genre;
select genre,avg(price) from Books group by genre;
 
 -- Having
select genre,avg(price) from Books group by genre having avg(price)>12;
select genre,sum(stock_quantity) as sq from Books group by genre having sq<150;

-- Inner Join
create table Sales(
	sale_id int,
	bookid int,
    quantity_sold int,
    sale_date date
    );
insert into Sales values
	(101,3,2,'2023-10-10'),
    (102,5,1,'2023-10-02'),
    (103,3,4,'2023-10-02');
    
select books.title, sales.quantity_sold
from books
join sales on books.bookid=sales.bookid;
select * from books;
select books.title,books.author,sales.sale_date
from books
join sales on books.bookid=sales.bookid;

-- Left join
insert into books values (8,'The Similarillion','J.R.R. Tolkien','Fantasy',18.50,500);
select books.title,sales.sale_date from books
left join sales on books.bookid=sales.bookid;

-- Like operation
select title,author from books where title like 'The%';
select title,author from books where title like 'Habit%';

-- case logic
select title,stock_quantity,
case
	when stock_quantity>=100 then 'Healthy'
    when stock_quantity<100 then 'Reorder soon'
end as stockstatus
from books;

-- with statement
with averagePrice as (select avg(price) as avg_price from books)
select books.title,books.price from books
join averagePrice on books.price>averagePrice.avg_price;

-- rank
select title,genre,stock_quantity,rank() over(partition by genre order by stock_quantity desc) from books;

-- view
create view test1 as
with averagePrice as (select avg(price) as avg_price from books)
select books.title,books.price from books
join averagePrice on books.price>averagePrice.avg_price;
select * from test1;

/*stored procedure ( automate changing data update/insert when using view)
syntax: 
delimiter// <tells sql we're writing multi line script>
create procedure <procedure_name>(in <variable_name> <datatype>)
begin
 <action>
end
delimiter; <sets rule back to normal>*/
DELIMITER // 
CREATE PROCEDURE writeoffdamagedook(IN p_bookid INT, IN purchased INT) 
BEGIN 
    UPDATE books 
    SET stock_quantity = stock_quantity - purchased 
    WHERE bookid = p_bookid; 
END // 
DELIMITER ;
-- ____________________________________________________________
-- Exercises 
-- 1 The Chief Financial Officer (CFO) is looking at profitability. She doesn't just want to know how many books sold; she wants to know how much money we made, and she only cares about our top performers.
select books.title,sum(books.price*sales.quantity_sold) as revenue from books
join sales on books.bookid=sales.bookid group by books.title having revenue>20 order by revenue desc;

-- 2 "We are running low on some of our Sci-Fi inventory. Please go into the system and increase the price by $2.00 for any book in the 'Sci-Fi' genre, but ONLY if we currently have less than 100 copies in stock."
update books set price=price+2.00 where genre='Sci-Fi' and stock_quantity<100;
set sql_safe_updates=0;
select * from books; 

-- 3 "Please pull a report showing the Genre and the Total Quantity Sold for that genre. However, to filter out the noise, I only want to see genres where the total number of books sold is 3 or more."
select books.genre,sum(sales.quantity_sold) as qty from books join
sales on books.bookid=sales.bookid group by books.genre having qty>=3;

-- 4 "Can you give me a list of every Author and the Most Recent Sale Date associated with their books? Please organize the final list alphabetically by the author's name."
select books.author,max(sales.sale_date) as last_purchased from books
join sales on books.bookid=sales.bookid group by books.author order by books.author;

-- 5 "Please pull a report showing the Title and Author of any book that has never been sold in our system."
select books.title,books.author,sales.quantity_sold from books
left join sales on books.bookid=sales.bookid where sales.quantity_sold is null;

-- 6 "Please find the Title and Genre of the book that had the highest quantity_sold in a single transaction. We don't want the sum of all sales, just the title attached to that one massive transaction."
select books.title,books.genre,sales.quantity_sold from books
join sales on books.bookid=sales.bookid where quantity_sold=(select max(quantity_sold) from sales);

-- 7 "Please write a query to find the Title, Author, and Price of any book where the Author's name contains 'Newport' AND the Title contains 'Work'."
select title,author,price from books where author like '%Newport%' and title like '%Work%';

-- 8 "Please pull a report showing the Title, the Price, and a brand new column called PricingTier.If the book costs $13.00 or more, label it 'Premium'.If the book costs between $10.00 and $12.99, label it 'Standard'.If the book costs less than $10.00, label it 'Value'.Finally, sort the list so the Premium books are at the top."
select title,price,
case
	when price>=13 then 'Premium'
    when price between 10 and 12.99 then 'Standard'
    else 'Value'
end as PricingTier
from books order by price desc;

-- 9 	Step 1: Create a CTE called BookRevenue that joins the Books and Sales tables. Calculate the Total Revenue (Price * QuantitySold) and group it by BookID.
	-- Step 2: In your main query, JOIN the Books table to your BookRevenue CTE.
	-- Step 3: Pull the Title and the Total Revenue, but ONLY show books where the Total Revenue is greater than $30.00.
with BookRevenue as (select books.bookid,sum(books.price*sales.quantity_sold) as TotalRevenue from books
join sales on books.bookid=sales.bookid group by books.bookid)
select books.title,BookRevenue.TotalRevenue from books
join BookRevenue on books.bookid=BookRevenue.bookid where BookRevenue.TotalRevenue>30.00;

-- 10 "Please pull a report showing the Title, Genre, and Price of every book. Add a new column called PriceRank that ranks the books from most expensive (1) to least expensive WITHIN each individual genre."
select bookid,title,genre,price,rank() over(partition by genre order by price desc) as pricerank from books;

-- 11 Write a query that returns the Title, Genre, Total Revenue, and Revenue Rank of a book, but ONLY if it is the #1 or #2 highest-grossing book within its specific genre.
with revenue as (select books.bookid,case
	when sum(books.price*sales.quantity_sold) is null then 0
    else sum(books.price*sales.quantity_sold)
    end as rev
    from books
left join sales on books.bookid=sales.bookid group by books.bookid),
revenue_rank as(
select books.title,books.genre,revenue.rev,rank() over(partition by genre order by revenue.rev desc) as revenue_rank from books
join revenue on books.bookid=revenue.bookid)
select * from revenue_rank where revenue_rank<=2;

-- 12 Pull a report of EVERY book in the Books table (including The Silmarillion, which has zero sales). Calculate the total quantity_sold for each book. Then, create a new column called RiskLevel using a CASE statement with the following rules If the total quantity sold is NULL (meaning it has never been sold), label it 'Critical Risk'.If the total quantity sold is less than 5, label it 'High Risk'.If the total quantity sold is 5 or more, label it 'Safe'.
select books.title,case
	when sum(sales.quantity_sold) is null then 'Critical Risk'
    when sum(sales.quantity_sold)<5 then 'High Risk'
    else 'Safe'
    end as risk_level
    from books
left join sales on books.bookid=sales.bookid group by books.title;

-- 13 Write a query that returns the SaleDate, the Daily Revenue (Total revenue generated on that specific date), and a Running Total of revenue up to and including that date. Sort the report chronologically by date.
with daily as (select sales.sale_date,sum(books.price*sales.quantity_sold) as daily_rev from books
join sales on books.bookid=sales.bookid group by sale_date)
select sale_date,daily_rev,sum(daily_rev) over(order by sale_date) as cumulative_sales from daily;

-- 14 Pull a report showing the Title, Genre, the Book's Total Revenue, and the Percentage of revenue that book contributes to its specific Genre's overall total revenue.
with rev_prod as(select books.bookid,case
when sum(sales.quantity_sold*books.price) is null then 0
else sum(sales.quantity_sold*books.price)
end as rev
from books left join
sales on books.bookid=sales.bookid group by bookid),
rev_per as(select books.title,books.genre,rev_prod.rev,sum(rev_prod.rev) over(partition by genre) as cum from books
join rev_prod on books.bookid=rev_prod.bookid)
select title,genre,rev as book_revenue, case
	when (rev_per.rev/rev_per.cum)*100 is null then 0
    else (rev_per.rev/rev_per.cum)*100
    end as percent_of_rev
 from rev_per;
 
-- 15 Create a VIEW named AuthorPerformance. This view should display the Author's Name, their Total Lifetime Revenue (across all their books), and the Total Number of Books Sold.
-- Constraint: The view should ONLY include authors who have actually generated revenue (Total Revenue > 0).*/
create view authorPerformance as
select books.author,
sum(sales.quantity_sold*books.price) as tot_rev,
sum(sales.quantity_sold) as books_sold
from books left join sales
on books.bookid=sales.bookid group by books.author having tot_rev>0;
select * from authorPerformance;

-- 16 Create a STORED PROCEDURE named ProcessRestock.
-- It must accept two parameters: a BookID (INT) and a RestockAmount (INT).
delimiter //
create procedure process_restock(in bookID int,in restock_amount int)
begin
	update books
    set stock_quantity=stock_quantity+restock_amount
    where bookid=bookID;
end //
delimiter ;
select * from books where bookid=4;
call process_restock(4,10);

create table Sales2(
	sale_id int,
	bookid int,
    quantity_sold int,
    sale_date date
    );
insert into Sales2 values
	(101,3,2,'2023-10-19'),
    (102,3,1,'2023-10-20'),
    (103,2,4,'2023-10-23'),
    (104,2,5,'2023-10-24'),
    (105,4,5,'2023-10-25');
select * from sales2;

-- 17 A book is considered "Trending" if it has been sold on two consecutive days.
-- Write a query to find the Title of every book that meets this criteria. If a book had a sale on Oct 1st and Oct 2nd, it makes the list. If it sold on Oct 1st and Oct 3rd, it does not.
create view Trending as
with join1 as(select bookid,sale_date from sales2),
join2 as(
select join1.bookid,join1.sale_date,sales2.sale_date as joined_date from join1
cross join sales2 on sales2.bookid=join1.bookid where join1.sale_date=date_add(sales2.sale_date,interval -1 day) order by join1.bookid ,join1.sale_date)
select books.title,
case
	when join2.bookid is null then 'Not Trending'
    else 'Trending'
    end as Trending
from books
left join join2 on books.bookid=join2.bookid;

-- or
SELECT DISTINCT b.title, 'Trending' AS Status FROM books b
JOIN sales2 s1 ON b.bookid = s1.bookid
JOIN sales2 s2 ON s1.bookid = s2.bookid 
where s2.sale_date = DATE_ADD(s1.sale_date, INTERVAL 1 DAY);

-- or
with join1 as(
select distinct title as title,books.bookid,sales2.sale_date, 'Trend' as status from books
join sales2 on books.bookid=sales2.bookid)
select title,status from join1 join sales2
on sales2.bookid=join1.bookid where join1.sale_date=date_add(sales2.sale_date,interval 1 day);

-- 18 The CFO refuses to read reports where she has to scroll down. She hates the standard GROUP BY output where every genre gets its own row. She wants the data "flattened" into a single row matrix.
create view Genre_Revenue as
select
sum(case when books.genre='Self-Help' then (books.price*sales.quantity_sold) end) as 'SelfHelp_Revenue',
sum(case when books.genre='Sci-Fi' then (books.price*sales.quantity_sold) end) as 'SciFi_Revenue',
sum(case when books.genre='Fantasy' then (books.price*sales.quantity_sold) else 0 end) as 'Fantasy'
from books
join sales on books.bookid=sales.bookid;
select * from Genre_Revenue;


/* 19 The CEO is reviewing the company's dependency on certain books. There is a famous business theory called the Pareto Principle, which states that 80% of your revenue usually comes from your top 20% of products. She wants to see this in action.
Your Task:
Write a query to identify the "heavy hitters" that make up the top 80% of the bookstore's total lifetime revenue.*/
create view _80_20_Pareto_Analysis as
with book_rev as(
select title,sum(price*quantity_sold) as rev from books join sales2
on books.bookid=sales2.bookid group by title),
net_rev as(select sum(rev) as net_rev from book_rev),
cumulative as(select *, sum(rev) over(order by rev desc) as cum,(select * from net_rev) as net_rev from book_rev)
select title,rev,cum/net_rev as 'cum%' from cumulative where cum/net_rev<=0.8;
select * from _80_20_Pareto_Analysis;


/*The marketing team is looking at daily sales data, but the day-to-day numbers are too erratic. Monday is high, Tuesday is zero, Wednesday is high again. They want you to smooth out the data using a 3-Day Rolling Average.
Your Task:
Pull a chronological report showing the SaleDate, the Total Daily Revenue for that exact date, and a 3-Day Moving Average of revenue (the average of the current day's revenue and the two days prior).*/
create view _3_day_moving_avg as
with date_rev as(
select sale_date,sum(price*quantity_sold) as rev from sales2 join books
on books.bookid=sales2.bookid group by sales2.sale_date)
select sale_date,rev,avg(rev) over(order by sale_date rows between 2 preceding and current row) as '3_day_moving_avg' from date_rev;
-- _______________________________________________________________________________________________
