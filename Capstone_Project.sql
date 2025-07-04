-- create database power_bi_project;

-- use power_bi_project;

select * from bank_churn;
select * from customerinfo;

-- -----------------------------------------------------------OBJECTIVE----------------------------------------------------------------------
-- Q.2
select
	CustomerId,
    EstimatedSalary,
    `Bank DOJ` as Last_Quarter
from customerinfo
where month(STR_TO_DATE(`Bank DOJ`, '%d/%m/%Y')) between 10 and 12
order by EstimatedSalary desc
limit 5;

-- Q.3
select
	avg(NumOfProducts) Avg_Products_CreditCard
from bank_churn
where HasCrCard = 1;

-- select * from gender;

-- Q.4 Churn Rate by gender for latest year
SELECT
    g.GenderCategory AS Gender,
    COUNT(CASE WHEN bc.Exited = 1 THEN 1 END) * 100.0 / COUNT(*) AS Churn_Rate
FROM bank_churn bc
JOIN customerinfo ci ON ci.CustomerId = bc.CustomerId
JOIN gender g ON ci.GenderID = g.GenderID
WHERE YEAR(STR_TO_DATE(ci.`Bank DOJ`, '%d/%m/%Y')) = (
    SELECT MAX(YEAR(STR_TO_DATE(`Bank DOJ`, '%d/%m/%Y'))) 
    FROM customerinfo
)
GROUP BY g.GenderCategory;

-- Q.5
-- select * from exitcustomer;

select 
	 Exited, avg(CreditScore) Avg_CreditScore
from bank_churn
group by Exited;  -- where 1: Exit, 0: Retain

-- Q.6
select 
	g.GenderCategory as Gender, 
    round(avg(c.EstimatedSalary), 2) Avg_EstimatedSal,
    sum(bc.IsActiveMember) Active_Members
from customerinfo c
join gender g on c.GenderID = g.GenderID
join bank_churn bc on c.CustomerId = bc.CustomerId
group by g.GenderCategory;

-- Q.7
select 
	case
		when CreditScore < 600 then "Low_Credit_Score"
        when CreditScore between 600 and 750 then "Medium_Credit_Score"
        else "High_Credit_Score"
	end as Credit_Segments,
    count(*) Total_Customers,
    sum(Exited) Exit_Customers,
    round(avg(Exited)* 100, 2) Exit_Rate
from bank_churn
group by Credit_Segments;

-- Q.8
select 
	GeographyLocation as Region,
    sum(IsActiveMember) as Active_Members
from bank_churn bc
join customerinfo c on bc.CustomerId = c.CustomerId
join geography g on c.GeographyID = g.GeographyID
where Tenure > 5
group by Region;

-- Q.9
SELECT 
    HasCrCard,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Exited_Customers,
    ROUND(AVG(Exited) * 100, 2) AS Exit_Rate_Percent
FROM bank_churn
GROUP BY HasCrCard;

-- Q.11
SELECT 
    YEAR(STR_TO_DATE(`Bank DOJ`, '%d/%m/%Y')) AS Join_Year,
    MONTH(STR_TO_DATE(`Bank DOJ`, '%d/%m/%Y')) AS Join_Month,
    COUNT(*) AS Customers_Joined
FROM CustomerInfo
GROUP BY Join_Year, Join_Month
ORDER BY Join_Year, Join_Month;

-- select * from CustomerInfo

-- Q.15
select
	GenderCategory as Gender,
    GeographyID,
    round(avg(EstimatedSalary), 2) Avg_Income,
    dense_rank() over(partition by GeographyID order by avg(EstimatedSalary) desc) Income_Rank
from customerinfo ci
join gender g on ci.GenderID = g.GenderID
group by GenderCategory, GeographyID;

-- Q.16
select 
    round(avg(Tenure), 2) Avg_Tenure,
    case
		when Age between 18 and 30 then "18-30"
        when Age between 30 and 50 then "30-50"
        when Age > 50 then "50+"
	end as Age_Bracket
from bank_churn bc
join customerinfo ci on bc.CustomerId = ci.CustomerId
where Exited = 1
group by Age_Bracket;

-- Q.19 Rank each bucket of credit score as per the number of customers who have churned the bank.
with cte as(
select
	count(*) Total_Customers,
	case
		when CreditScore < 500 then "Poor"
        when CreditScore between 500 and 599 then "Fair"
		when CreditScore between 600 and 699 then "Good"
        when CreditScore between 700 and 799 then "Very Good"
        else "Excellent "
	end as CreditScore_Bucket  
from bank_churn
where Exited = 1
group by CreditScore_Bucket
)
select 
	CreditScore_Bucket,
    rank() over(order by Total_Customers desc) rnk
from cte;

-- Q.20 According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average number of credit cards per 
-- bucket.

with cte as(
select 
    count(*) Total_Customers,
    case
		when Age < 30 then "Under 30"
        when Age between 30 and 39 then "30-39"
		when Age between 40 and 49 then "40-49"
        when Age between 50 and 59 then "50-59"
        else "60+"
	end as Age_Bracket
from bank_churn bc
join customerinfo ci on bc.CustomerId = ci.CustomerId
where HasCrCard = 1
group by Age_Bracket
)
select 
	Age_Bracket, Total_Customers
from cte 
where Total_Customers < (select avg(Total_Customers) from cte);

-- Q.23 Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to the Bank_Churn table?

select 
	bc.*,
    (select ExitCategory from exitcustomer
    where ExitID = bc.Exited) as ExitCategory
from bank_churn bc;

-- Q.25 Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.

select 
	c.CustomerId, Surname as Lastname, IsActiveMember
from customerinfo c
join bank_churn b on c.CustomerId = b.CustomerId
where Surname like "%on";        -- 1: Active, 0: Inactive

-- Q.26 Data Discrepancy 

SELECT *
FROM bank_churn
WHERE Exited = 1 AND IsActiveMember = 1;

-- -----------------------------------------------------------SUBJECTIVE----------------------------------------------------------------------

-- Q.9
-- 1. Segment by Age Bucket
SELECT 
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+' 
    END AS Age_Bucket,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Churned_Customers
FROM Bank_Churn b
JOIN CustomerInfo c ON b.CustomerId = c.CustomerId
GROUP BY Age_Bucket
ORDER BY Age_Bucket;

-- 2. Segment by Gender
SELECT 
    GenderCategory as Gender,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Churned_Customers
FROM Bank_Churn b
JOIN CustomerInfo c ON b.CustomerId = c.CustomerId
JOIN Gender g on c.GenderID = g.GenderID
GROUP BY Gender;

-- 3. Segment by Tenure Bucket
SELECT 
    CASE 
        WHEN Tenure <= 1 THEN 'New'
        WHEN Tenure BETWEEN 2 AND 4 THEN 'Mid-Term'
        ELSE 'Long-Term'
    END AS Tenure_Bucket,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Churned_Customers
FROM Bank_Churn
GROUP BY Tenure_Bucket;

-- 4. Segment by Product Holdings
SELECT 
    NumOfProducts,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Churned_Customers
FROM Bank_Churn
GROUP BY NumOfProducts;

-- 5. Segment by Activity Status
SELECT 
    IsActiveMember,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Churned_Customers
FROM Bank_Churn
GROUP BY IsActiveMember;

-- 6. Segment by Balance and Salary Range
SELECT 
    CASE 
        WHEN Balance < 50000 THEN 'Low Balance'
        WHEN Balance BETWEEN 50000 AND 100000 THEN 'Medium Balance'
        ELSE 'High Balance'
    END AS Balance_Range,
    CASE 
        WHEN EstimatedSalary < 50000 THEN 'Low Salary'
        WHEN EstimatedSalary BETWEEN 50000 AND 100000 THEN 'Mid Salary'
        ELSE 'High Salary'
    END AS Salary_Range,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Churned_Customers
FROM Bank_Churn b
JOIN CustomerInfo c ON b.CustomerId = c.CustomerId
GROUP BY Balance_Range, Salary_Range;

-- 7. Full Segmentation: Combine Key Dimensions
SELECT 
    GenderCategory as Gender,
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+' 
    END AS Age_Bucket,
    CASE 
        WHEN Tenure <= 1 THEN 'New'
        WHEN Tenure BETWEEN 2 AND 4 THEN 'Mid-Term'
        ELSE 'Long-Term'
    END AS Tenure_Bucket,
    NumOfProducts,
    IsActiveMember,
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Churned_Customers
FROM Bank_Churn b
JOIN CustomerInfo c ON b.CustomerId = c.CustomerId
JOIN Gender g on c.GenderID = g.GenderID
GROUP BY Gender, Age_Bucket, Tenure_Bucket, NumOfProducts, IsActiveMember
ORDER BY Total_Customers DESC;


-- Q.14 Rename “HasCrCard” column to “Has_creditcard”.
alter table Bank_Churn
rename column HasCrCard to Has_creditcard;

select * from Bank_Churn;