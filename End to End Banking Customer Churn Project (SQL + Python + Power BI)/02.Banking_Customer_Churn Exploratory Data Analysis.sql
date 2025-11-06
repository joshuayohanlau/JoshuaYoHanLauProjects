# banking customer churn exploratory data analysis

SELECT *
FROM bank_churn
;

# so just to detail my thinking, I want to first find the overall churn rate then find out how churn differs by every category
# so it would be like churn rate by gender then churn rate by balance or age group ect ect 

SELECT 
    COUNT(*) AS total_customers,
    SUM(exited) AS churned_customers,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn;

# so our overall churn rate is 20.37% with 2037 customers leaving out of a total 10000
# so about 1 in 5 customers have left 
# I am actually interested to see if churn rate between genders will be helpful to know

SELECT 
    gender,
    COUNT(*) AS total,
    SUM(exited) AS churned,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn
GROUP BY gender
ORDER BY churn_rate_percent DESC;

# so from what I can see, there seems to be about 1000 more males 
# there was 1139 females churned with 898 males churned so pretty similar
# but if you put it into percentages the female churn percentage is alot higher at 25% than the male 16%


SELECT 
    customer_age_group,
    COUNT(*) AS total,
    SUM(exited) AS churned,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn
GROUP BY customer_age_group
ORDER BY churn_rate_percent DESC;

# now taking a look at the churn by age group, our higest group of customer is in the 30-44 age bracket
# something interesting to note is that despite having 1/3 of the number of customers, 
# the age group of 45-59 has the same amount of churn as 30-44 age group
# and according to the percentages it seems the older generation has a higher chance to leave 
# with a churn rate of 50% for ages 45-59 and 28% for 60+ compared to the 14% of 30-44 and 8% of 18-29

SELECT 
    balance_category,
    COUNT(*) AS total,
    SUM(exited) AS churned,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn
GROUP BY balance_category
ORDER BY churn_rate_percent DESC;

# now we look at churn rate to balance category, the churn rate looks relativley even across the cateogries 
# with the medium having the highest churn rate at 25% with low being at 20% and zero at 14%
# I would say the zero balance category doesnt seem engaged while high and low seem to be more loyal 
# Id say its quite expected that the bulk of the customers being at medium would lead to a higher churn rate


SELECT 
    CASE 
        WHEN creditscore < 500 THEN 'Very Low (<500)'
        WHEN creditscore BETWEEN 500 AND 649 THEN 'Low (500–649)'
        WHEN creditscore BETWEEN 650 AND 749 THEN 'Medium (650–749)'
        ELSE 'High (750+)'
    END AS credit_score_group,
    COUNT(*) AS total,
    SUM(exited) AS churned,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn
GROUP BY credit_score_group
ORDER BY churn_rate_percent DESC;

# so as expected customers with a lower credit score are less likley to stay
#the churn rate goes from 19% for meidum to 23% for very low
#the biggest problem area is the low group as they have the highest number and a high churn rate 
# but actually churn rate is pretty high over all groups, so maybe credit score isnt a strong indicator 

SELECT 
    numofproducts,
    COUNT(*) AS total,
    SUM(exited) AS churned,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn
GROUP BY numofproducts
ORDER BY numofproducts;

# single product customers are the bulk of the customers but a churn rate of 27% incidates a retention opportunity 
# it seems that 2 product customers have a dramatically low churn rate of 7% which shows cross selling increases retention
# 3 or more products seems to be where there is a major issue which indicates a product or service issue

SELECT 
    isactivemember,
    COUNT(*) AS total,
    SUM(exited) AS churned,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn
GROUP BY isactivemember;

# as expected active memebers churn at half the rate, so engagment is a strong predictor of retention

SELECT 
    geography,
    COUNT(*) AS total,
    SUM(exited) AS churned,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn
GROUP BY geography
ORDER BY churn_rate_percent DESC;

# out of the 3 countries spain and france have a generally healthy churn rate
# germany has about both spain and frances churn rate at 32% compared to 16%
# france is the largest and most stable market and spain has low churn compared to its total
# so germany needs to be investigated for its pricing, competition, service quality, or cultural fit to see where the issue is

SELECT 
    exited AS churn,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(AVG(creditscore), 2) AS avg_credit_score,
    ROUND(AVG(age), 2) AS avg_age
FROM bank_churn
GROUP BY churn;
# so just off the bat we can see that customers that churn have higher balances - maybe something is skewing it in the data
# as earlier higher balance customers seemed to churn less
# credit score as mentioned earlier doesnt seem to matter too much
# and in line with what we found earlier, the avg age for customers that churn is higher at 45 compared to 37

SELECT 
    customer_age_group,
    balance_category,
    COUNT(*) AS total,
    SUM(exited) AS churned,
    ROUND(SUM(exited) / COUNT(*) * 100, 2) AS churn_rate_percent
FROM bank_churn
GROUP BY customer_age_group, balance_category
ORDER BY churn_rate_percent DESC;

# so actually from comparing the customer age group and their balance
# younger customers with zero or low balances are the most loyal at a 4% churn
# this may explain the query ealier we found that when customers that churn have generally higher balances
# the 30-44 medium balance group is a slight increase but remains at a strong retention level
# the mid to high age group (45-59) is where customers bleed the most
# with an average of 54% churn for mid to high value older customers despite significant size

# so overall we can conclude that balance engagment matters more the older customers age 
# younger customers at a zero or low balance stay loyal
# while older customers with zero or low balances churn at around 40%

