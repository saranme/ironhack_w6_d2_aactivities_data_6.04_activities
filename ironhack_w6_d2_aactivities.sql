/*
6.04 Activity 1
*/
use bank;
# How many accounts do we have?
SELECT COUNT(*)
FROM loan;

# How many of the accounts are defaulted?
SELECT COUNT(*)
FROM loan
WHERE status = 'B';

# What is the percentage of defaulted people in the dataset?
SELECT COUNT(account_id) / (SELECT COUNT(*) FROM loan) *100 percentage
FROM loan
GROUP BY status
HAVING status = 'B';


/*
Activity 2
*/
-- Get the customer intomation
select * from (
      select a.account_id, a.district_id, a.frequency, d.A2 as District,
        d.A3 as Region, l.loan_id, l.amount, l.payments, l.status
      from bank.account a
      join bank.district d
      on a.district_id = d.A1
        join bank.loan l
        on a.account_id = l.account_id
        where l.status = "B"
        order by a.account_id ) as sub1
      where sub1.amount > (
        select round(avg(amount),2)
        from bank.loan
        where status = "B")
order by amount desc;
/*
Find the account_id, amount and date of the first transaction of the defaulted people if 
its amount is at least twice the average of non-default people transactions.
Hint: Use the query used in class.
*/
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT account_id, date, amount
FROM trans
GROUP BY 1
HAVING date = min(date) AND amount >= 2*(SELECT AVG(amount) FROM(
										SELECT t.account_id, t.amount, l.status
										FROM trans t
										JOIN loan l
										ON t.account_id = l.account_id
										WHERE l.status != 'B') sub2)
ORDER BY 1;

with cte_1 as (
  select * from (
    select a.account_id, a.district_id, a.frequency, d.A2 as District,
      d.A3 as Region, l.loan_id, l.amount, l.payments, l.status
    from bank.account a
    join bank.district d
    on a.district_id = d.A1
      join bank.loan l
      on a.account_id = l.account_id
      where l.status = "B"
      order by a.account_id) sub1
    where sub1.amount > (select round(avg(amount),2) * 2 from bank.loan where status = "A")
order by amount desc)
select cte_1.account_id, cte_1.amount, min(date(t.date)) as First_transaction
from cte_1
join bank.trans t on cte_1.account_id = t.account_id
group by cte_1.account_id, cte_1.amount
order by cte_1.amount desc;

/*
Create a pivot table showing the average amount of transactions using frequency for each district.
*/
SELECT AVG( CASE WHEN a.frequency= "POPLATEK MESICNE" THEN amount END) AS "POPLATEK MESICNE",
	AVG( CASE WHEN a.frequency= "POPLATEK TYDNE" THEN amount END) AS "POPLATEK TYDNE",
    AVG( CASE WHEN a.frequency= "POPLATEK PO OBRATU"  THEN amount END) AS "POPLATEK PO OBRATU", d.A1 district_id, d.A2 district_name
FROM district d
JOIN account a
ON a.district_id = d.A1
JOIN trans t
ON t.account_id = a.account_id
GROUP BY 4,5
ORDER BY 4;

/*
Write a simple stored procedure to find the number of movies released in the year 2006.
*/
Use sakila;
delimiter //
create procedure number_of_movies_released_2006 (out param1 int) -- Within paretheses the OUTPUT of the procedure
begin
select COUNT(*) into param1 from film where release_year = 2006;
end;
//
delimiter ;

call number_of_movies_released_2006(@x);
select @x as 'Number_of_movies_2006';