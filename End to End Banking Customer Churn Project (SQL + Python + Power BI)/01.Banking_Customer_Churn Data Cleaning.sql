#Banking customer churn data cleaning 

SELECT *
FROM bank_churn
;
#I want to take a look at duplicate values and try to remove them if there are any 

SELECT customerid, COUNT(customerid)
FROM bank_churn
GROUP BY customerid 
HAVING COUNT(customerid) > 1
;

# There is no duplicate rows based off the customer id 
#id like to take a look at missing or null data now

SELECT *
FROM bank_churn
WHERE coalesce(customerid,surname,creditscore,geography,gender,
	age,tenure,balance,numofproducts,hascrcard,isactivemember,estimatedsalary,exited) IS NULL
;

#once again there is no null data so it seems the dataset is relativley clean already
# doing a quick scan of the database there doesnt seem to be any inconsistent formatting 
# id like to just add additional columns to make the next exploratory data analysis section a bit easier

ALTER TABLE bank_churn ADD COLUMN customer_age_group VARCHAR(20);

ALTER TABLE bank_churn ADD COLUMN balance_category VARCHAR(20);


SELECT *
FROM bank_churn
;

#Id like to now populate the columns and ill start with the easiest one which is the age group 

UPDATE bank_churn
SET customer_age_group = CASE
    WHEN age < 18 THEN 'Under 18'
    WHEN age BETWEEN 18 AND 29 THEN '18-29'
    WHEN age BETWEEN 30 AND 44 THEN '30-44'
    WHEN age BETWEEN 45 AND 59 THEN '45-59'
    WHEN age >= 60 THEN '60+'
    ELSE 'Unknown'
END;

# now i will try to populate the balance category and split the balances between low, medium and high
# but first im gonna use a simple statistical concept to define what our low, medium, and high values are

WITH stats AS (
    SELECT
        AVG(balance) AS avg_balance,
        STD(balance) AS std_balance
    FROM bank_churn
)

UPDATE bank_churn
SET balance_category = CASE
    WHEN balance < (SELECT avg_balance - std_balance FROM stats) THEN 'Low'
    WHEN balance BETWEEN (SELECT avg_balance - std_balance FROM stats)
                     AND (SELECT avg_balance + std_balance FROM stats) THEN 'Medium'
    WHEN balance > (SELECT avg_balance + std_balance FROM stats) THEN 'High'
    ELSE 'Unknown'
END;

#looking at the data the amount of 0 balances is skewing the data
# so im going to rewrite the previous section of code to filter out the zeros

WITH stats AS (
    SELECT 
        AVG(balance) AS avg_balance,
        STD(balance) AS std_balance
    FROM bank_churn
    WHERE balance > 0
)
UPDATE bank_churn AS b
JOIN stats AS s
SET b.balance_category = CASE
    WHEN b.balance = 0 THEN 'Zero'
    WHEN b.balance < s.avg_balance - s.std_balance THEN 'Low'
    WHEN b.balance BETWEEN s.avg_balance - s.std_balance AND s.avg_balance + s.std_balance THEN 'Medium'
    WHEN b.balance > s.avg_balance + s.std_balance THEN 'High'
    ELSE 'Unknown'
END;

SELECT *
FROM bank_churn
;

# so already the data looks alot better, with the zeros being defined and bank balance categories being more accurate 
