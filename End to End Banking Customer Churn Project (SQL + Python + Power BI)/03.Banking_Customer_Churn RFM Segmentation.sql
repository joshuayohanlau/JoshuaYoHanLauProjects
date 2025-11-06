# banking customer churn RFM Segmentation

#I want to try Calculate RFM metrics and score them from 1–5 but 
#I will use a proxy seeing as there isnt individual transaction dates or purchase histroy

WITH rfm_base AS (
    SELECT
        CustomerId,
        Tenure,
        IsActiveMember,
        NumOfProducts,
        HasCrCard,
        Balance,
        EstimatedSalary,
        Exited
    FROM bank_churn
),
rfm_scored AS (
    SELECT
        CustomerId,
        Tenure,
        IsActiveMember,
        NumOfProducts,
        HasCrCard,
        Balance,
        EstimatedSalary,
        Exited,

	# so for recency i will use Active and tenure as a proxy so higher is more recent engagment
        NTILE(5) OVER (ORDER BY (Tenure + (IsActiveMember * 5)) DESC) AS r_score,

    # for frequency ill use num of products and if the customer has a card so higher is more frequent
        NTILE(5) OVER (ORDER BY (NumOfProducts + HasCrCard) DESC) AS f_score,

	# for monetary i will use balance and salary which higher is more value 
        NTILE(5) OVER (ORDER BY (Balance + EstimatedSalary) DESC) AS m_score

    FROM rfm_base
)

# now we just simply map it out on a mini table
SELECT
    CustomerId,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CONCAT(r_score, f_score, m_score) AS rfm_code,
    Exited
FROM rfm_scored
ORDER BY rfm_total DESC;

# now I want to segment the customers into their own groups 
# ill reuse the rfm_scored and then split the customers into groups using different scores as the logic


WITH rfm_scored AS (
    SELECT
        CustomerId,
        Tenure,
        IsActiveMember,
        NumOfProducts,
        HasCrCard,
        Balance,
        EstimatedSalary,
        Exited,
        NTILE(5) OVER (ORDER BY (Tenure + (IsActiveMember * 5)) DESC) AS r_score,
        NTILE(5) OVER (ORDER BY (NumOfProducts + HasCrCard) DESC) AS f_score,
        NTILE(5) OVER (ORDER BY (Balance + EstimatedSalary) DESC) AS m_score
    FROM bank_churn
)
SELECT
    CustomerId,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Inactive'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Potential Loyal Customers'
        ELSE 'Others'
    END AS rfm_segment,
    Exited
FROM rfm_scored
ORDER BY rfm_total DESC;

# The logic behind the champion and loyal customers is that those are the bread and butter customers so they will have generally high scores
# the rest is where i made some assumtions on the data but its still logical and structured 
# for "at risk" is went with the idea that the customer used to be active so the frequency
# is still decent but recency is low.
# for inactive, its the same idea but both frequency and recency are low
# and potential loyal customer is based on the idea that recency would be high due to new movement 
# but they still havent been too frequent of a user

# now we combine everything and make a table with all the segments

WITH rfm_scored AS (
    SELECT
        CustomerId,
        Exited,
        NTILE(5) OVER (ORDER BY (Tenure + (IsActiveMember * 5)) DESC) AS r_score,
        NTILE(5) OVER (ORDER BY (NumOfProducts + HasCrCard) DESC) AS f_score,
        NTILE(5) OVER (ORDER BY (Balance + EstimatedSalary) DESC) AS m_score
    FROM bank_churn
),
rfm_segmented AS (
    SELECT
        CustomerId,
        (r_score + f_score + m_score) AS rfm_total,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Inactive'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'Potential Loyal Customers'
            ELSE 'Others'
        END AS rfm_segment,
        Exited
    FROM rfm_scored
)
SELECT 
    rfm_segment,
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    ROUND(AVG(Exited) * 100, 2) AS churn_rate_percent,
    ROUND(AVG(rfm_total), 2) AS avg_rfm_score
FROM rfm_segmented
GROUP BY rfm_segment
ORDER BY churn_rate_percent DESC;

#so taking a look at the churn rate and rfm scores we see theres actually an inverse in expectations
# we actually see that high rfm and top tier segments such as champions or loyal customers have a higher churn than the lower tiers 
# we see that churn actually rises the higher the rfm score is 
# this actually is in line with our findings from the exploratory data analysis phase
# where we found that there was a higher churn among older more high value customers
# we also saw the more products a customer was using the more likley they were to churn
# this indicates that there is something wrong with the services/products the bank is providing 
# and we see that the low value customers are more stable but it could also be an indication of inactivity

CREATE TABLE customer_rfm_segments AS
WITH rfm_scored AS (
    SELECT
        CustomerId,
        Exited,
        NTILE(5) OVER (ORDER BY (Tenure + (IsActiveMember * 5)) DESC) AS r_score,
        NTILE(5) OVER (ORDER BY (NumOfProducts + HasCrCard) DESC) AS f_score,
        NTILE(5) OVER (ORDER BY (Balance + EstimatedSalary) DESC) AS m_score
    FROM bank_churn
)
SELECT
    CustomerId,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Inactive'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Potential Loyalist'
        ELSE 'Others'
    END AS rfm_segment,
    Exited
FROM rfm_scored;

# I just wanted to keep the table for use later when I need to make visualisations in power bi
