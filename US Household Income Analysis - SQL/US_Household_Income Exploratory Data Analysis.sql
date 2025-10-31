# US Household Income Exploratory Data Analysis

SELECT *
FROM us_project.us_household_income;
;
SELECT *
FROM us_project.us_household_income_statistics;
;
SELECT State_Name, County, City, ALand, AWater
FROM us_project.us_household_income;
;


SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10;

# checking states for land mass and water and grabbing the top 10 largest states

SELECT *
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	ON u.id = us.id;

# join to combine the 2 tables of statistics and the income table

SELECT *
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0;

# Filtering out empty data that i noticed from previous query
SELECT u.State_Name, Round(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_name
ORDER BY 2
;

# Finding the average household income for every state



SELECT Type, COUNT(TYPE),Round(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 2
;

# Finding out if the type of community has any correlation to average income 
# also using count to see if there is enough data where the data isnt skewed

SELECT *
FROM us_household_income
WHERE Type = 'Community'
;

# Was curious to see why the community type of community had such a low avg salary 


SELECT Type, COUNT(TYPE),Round(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY 1
HAVING COUNT(Type) > 100
ORDER BY 2
;

# filtering out types of communities with inssufienct data through the count function
# basically a process to remove outliers 


SELECT u.State_Name, City, ROUND(AVG(Mean),1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
GROUP BY u.State_Name, City
ORDER BY 3 DESC
;

# I want to try narrow it down to the cities within the states


SELECT 
  u.State_Name,
  MIN(Mean) AS min_income,
  MAX(Mean) AS max_income,
  ROUND(AVG(Mean),1) AS avg_income,
  ROUND(STDDEV(Mean),1) AS std_dev_income
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
  ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY avg_income DESC;

# Using the STDDEV function to show income inequality based off avg income

SELECT 
  u.State_Name,
  ROUND(AVG(Mean - Median),1) AS avg_income_gap
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
  ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY avg_income_gap DESC;

# subtracting the avg from the median in an attempt to narrow down income inequality within each state
