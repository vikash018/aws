select CURRENT_TIMESTAMP, LOCALTIMESTAMP FROM DUAL;

select * from EMPLOYEES a join
(
select * from
(
select b.*,dense_rank() over (order by cast(b.MAX_SALARY as int) desc) rnk
from jobs b
)
where rnk=4
) bb
on a.job_id=bb.job_id
;
select * from EMPLOYEES where job_id not in(
select max(MAX_SALARY) from jobs where MAX_SALARY not in(
select max(MAX_SALARY) from jobs)
);

---Write a SQL query to find the products which have continuous increase in sales every year?
select product_name from
(
select a.*,b.*,(a.quantity - lead(a.quantity,1)over(partition by a.PRODUCT_ID order by a.YEAR desc)) diff
from sales a,products b
WHERE  a.PRODUCT_ID = b.PRODUCT_ID
)
group by product_name
having min(diff) >=0
;

--Write a SQL query to find the products which does not have sales at all?
select PRODUCT_NAME 
from products a left join sales b
on a.PRODUCT_ID=b.PRODUCT_ID
where b.PRODUCT_ID is null;

select * from PRODUCTS a
where
not exists (select * from sales b where a.PRODUCT_ID=b.PRODUCT_ID);

--Write a SQL query to find the products whose sales decreased in 2012 compared to 2011?
select product_name from
(
select a.*,b.*,(a.quantity - lead(a.quantity,1)over(partition by a.PRODUCT_ID order by a.YEAR desc)) diff
from sales a,products b
WHERE  a.PRODUCT_ID = b.PRODUCT_ID and a.YEAR in (2011,2012)
)
group by product_name
having min(diff) < 0
;

select * from products
where product_id in
(
SELECT b.product_id
FROM SALES b,SALES c
WHERE  b.PRODUCT_ID = c.PRODUCT_ID
AND b.YEAR = 2012
AND c.YEAR = 2011
AND b.QUANTITY < c.QUANTITY);

--Write a query to select the top product sold in each year? 
select product_name,year from
(
select a.*,b.*,dense_rank() over(partition by year order by a.QUANTITY desc) t
from sales a,products b
where a.PRODUCT_ID = b.PRODUCT_ID
)
where t=1
order by year;

--Write a query to find the total sales of each product?

select distinct product_name,sum(QUANTITY*PRICE) over(partition by a.PRODUCT_ID) TOTAL_SALES
from sales a right join products b
on a.PRODUCT_ID = b.PRODUCT_ID
;

SELECT P.PRODUCT_NAME,
       NVL( SUM( S.QUANTITY*S.PRICE ), 0) TOTAL_SALES
FROM   PRODUCTS P
       LEFT OUTER JOIN
       SALES S
ON     (P.PRODUCT_ID = S.PRODUCT_ID)
GROUP BY P.PRODUCT_NAME;

--Write a query to find the products whose quantity sold in a year should be greater 
--than the average quantity of the product sold across all the years?

select * from sales a,
(select product_id,round(AVG(quantity),2) av_qunt from sales
group by product_id) b
,products c
where a.PRODUCT_ID = b.PRODUCT_ID 
and c.PRODUCT_ID = b.PRODUCT_ID
and quantity > av_qunt
order by a.product_id
;

--Write a query to compare the products sales of "IPhone" and "Samsung" in each year? 
--The output should look like as
--YEAR IPHONE_QUANT SAM_QUANT IPHONE_PRICE SAM_PRICE
---------------------------------------------------
--2010   10           20       9000         7000
--2011   15           18       9000         7000
--2012   20           20       9000         7000

select a.year,a.quantity IPHONE_QUANT,b.quantity SAM_QUANT
,a.price IPHONE_PRICE,b.price SAM_PRICE
from sales a,
sales b
where 
a.year = b.year 
and a.PRODUCT_ID in (select PRODUCT_ID from products where upper(product_name)='IPHONE')
and b.PRODUCT_ID in (select PRODUCT_ID from products where upper(product_name)='SAMSUNG')
order by a.year
;

--Write a query to find the ratios of the sales of a product?

select year,a.PRODUCT_ID,c.PRODUCT_NAME,price,total_price,round(((price*quantity)/total_price),2) ration
from sales a,
(select product_id,sum(price*QUANTITY) total_price from sales
group by product_id) b,
products c
where
a.PRODUCT_ID = b.PRODUCT_ID
and a.PRODUCT_ID = c.PRODUCT_ID
;

--In the SALES table quantity of each product is stored in rows for every year. 
--Now write a query to transpose the quantity for each product and display it in columns? The output should look like as 

--PRODUCT_NAME QUAN_2010 QUAN_2011 QUAN_2012
------------------------------------------
--IPhone       10        15        20
--Samsung      20        18        20
--Nokia        25        16        8

select d.product_name,a.quantity QUAN_2010,b.quantity QUAN_2011,c.quantity QUAN_2012
from sales a,sales b,sales c,products d
where a.product_id=b.product_id and b.product_id=c.product_id
and a.product_id=d.product_id
and a.year=2010
and b.year=2011
and c.year=2012
order by a.quantity
;

SELECT * FROM
(
SELECT P.PRODUCT_NAME,
       S.QUANTITY,
       S.YEAR
FROM   PRODUCTS P,
       SALES S
WHERE (P.PRODUCT_ID = S.PRODUCT_ID)
)A
PIVOT ( MAX(QUANTITY) AS QUAN FOR (YEAR) IN (2010,2011,2012));

SELECT P.PRODUCT_NAME,
       MAX(DECODE(S.YEAR,2010, S.QUANTITY)) QUAN_2010,
       MAX(DECODE(S.YEAR,2011, S.QUANTITY)) QUAN_2011,
       MAX(DECODE(S.YEAR,2012, S.QUANTITY)) QUAN_2012
FROM   PRODUCTS P,
       SALES S
WHERE (P.PRODUCT_ID = S.PRODUCT_ID)
GROUP BY P.PRODUCT_NAME;

select PRODUCT_ID
,max(case when year=2010 then quantity end) QUAN_2010
,max(case when year=2011 then quantity end) QUAN_2011
,max(case when year=2012 then quantity end) QUAN_2012
from sales
group by PRODUCT_ID
;

--Write a query to find the number of products sold in each year?
select year,count(*) from sales
group by year;

--Write a query to generate sequence numbers from 1 to the specified number N?

SELECT LEVEL FROM DUAL CONNECT BY LEVEL<=&N;

--Write a query to display only friday dates from Jan, 2000 to till now?

-- Write a query to duplicate each row based on the value in the repeat column? 
--The input table data looks like as below
--Products, Repeat
----------------
--A,         3
--B,         5
--C,         2

SELECT PRODUCTS,
       REPEAT 
FROM   T, 
      ( SELECT LEVEL L FROM DUAL 
        CONNECT BY LEVEL <= (SELECT MAX(REPEAT) FROM T) 
      ) A 
WHERE T.REPEAT >= A.L 
ORDER BY T.PRODUCTS;

--Write a query to display each letter of the word "SMILE" in a separate row?
SELECT SUBSTR('SMILE',LEVEL,1) A 
FROM   DUAL 
CONNECT BY LEVEL <=LENGTH('SMILE');

------------------------------------------------
with friend_list as (
(select 'sam' as name, 'ram'  as friend_name from dual ) union all
(select 'sam' as name, 'vamsi' as friend_name from dual ) union all
(select 'vamsi' as name, 'ram'  as friend_name from dual ) union all
(select 'vamsi' as name, 'jhon'  as friend_name from dual ) union all
(select 'ram' as name, 'vijay'  as friend_name from dual ) union all
(select 'ram' as name, 'anand'  as friend_name from dual )
)
select a.name,b.friend_name from friend_list a,friend_list b
where b.name=a.friend_name and a.name='sam'
minus
select * from friend_list where name='sam'
;

-----------------------------------
with sales as (
(select 'A' as products,200 as quantity_sold,2009 as year from dual) union all
(select 'B' as products,155 as quantity_sold,2009 as year from dual) union all
(select 'C' as products,455 as quantity_sold,2009 as year from dual) union all
(select 'D' as products,620 as quantity_sold,2009 as year from dual) union all
(select 'E' as products,135 as quantity_sold,2009 as year from dual) union all
(select 'F' as products,390 as quantity_sold,2009 as year from dual) union all
(select 'G' as products,999 as quantity_sold,2010 as year from dual) union all
(select 'H' as products,810 as quantity_sold,2010 as year from dual) union all
(select 'I' as products,910 as quantity_sold,2010 as year from dual) union all
(select 'J' as products,109 as quantity_sold,2010 as year from dual) union all
(select 'L' as products,260 as quantity_sold,2010 as year from dual) union all
(select 'M' as products,580 as quantity_sold,2010 as year from dual)
)
select * from
(
select products,cast(quantity_sold as NUMBER) quantity_sold,rownum r,(select count(*) from sales) cnt 
from sales a 
order by cast(quantity_sold as NUMBER)
)
where r <= 5
;

--Query to find Second Highest Salary of Employee?
with emp as (
(select 1 as Employee_num,'Amit' as Employee_name,'OBIEE' as Department,680000 as Salary from dual) union all
(select 2 as Employee_num,'Rohan' as Employee_name,'OBIEE' as Department,550000 as Salary from dual) union all
(select 3 as Employee_num,'Rohit' as Employee_name,'OBIEE' as Department,430000 as Salary from dual)
)
select * from
(
select a.*,rank() over( order by salary desc) sal_order
from emp a
)
where sal_order=2
;

--How to Find Duplicate Records in Table?
with emp as (
(select 1 as Employee_num,'Amit' as Employee_name,'OBIEE' as Department,680000 as Salary from dual) union all
(select 1 as Employee_num,'Amit' as Employee_name,'OBIEE' as Department,680000 as Salary from dual) union all
(select 3 as Employee_num,'Rohit' as Employee_name,'OBIEE' as Department,430000 as Salary from dual)
)
select a.* from emp a where rowid != (select max(rowid) from emp b where a.Employee_num =b.Employee_num)
;

--Write a query to display employee records having same salary?

select * from employees where salary in (select salary from employees group by salary having count(*) > 1);

select a.* from employees a, employees b where a.employee_id <> b.employee_id and a.salary=b.salary order by a.salary;

--numeric value of a column
select salary from employees where regexp_like(DEPARTMENT_ID,'^[0-9]*$');

--Replace Only Third Character with *

select a.*,REGEXP_REPLACE(JOB_ID, '^[1-9A-Za-z][1-9A-Za-z]', '*')  from employees a;

--middle record
SELECT a.* FROM employees a WHERE rownum <= (SELECT trunc(count(*)/2) FROM employees)
minus
SELECT a.* FROM employees a WHERE rownum <> (SELECT trunc(count(*)/2) FROM employees)
;



