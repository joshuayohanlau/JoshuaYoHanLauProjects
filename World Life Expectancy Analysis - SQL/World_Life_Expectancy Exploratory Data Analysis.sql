# World Life Expectancy Project (Exploratory Data Analysis) 

SELECT *
FROM world_life_expectancy
;

SELECT country, 
MIN(`Life expectancy`),
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING  MIN(`Life expectancy`) <> 0 AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years DESC
;

# Finding the the max and the min life expectancy for each country and how much it increased over 15 years
# also removing any that have zero 

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;

# Finding the average life expectancy of the whole world from each year 
# so from here we can see data of how much the life expectancy increase should be and the overall average 

SELECT *
FROM world_life_expectancy
;



SELECT Country,ROUND(AVG( `Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country 
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP DESC
;

# finding the avaerage life expectancy per country to see if GDP has any correlation 
# from the data there is a loose correlation that higher gdp = higher life expectancy 
# most likely to better social infrastructure and maybe a better health care system


SELECT 
sum(CASE 
    WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
AVG(CASE 
    WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) AS High_GDP_Life_Expectancy,
sum(CASE 
    WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
AVG(CASE 
    WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) AS Low_GDP_Life_Expectancy
FROM world_life_expectancy
ORDER BY GDP
;

# Finding the number of contries with a high GDP based on the halfway GDP mark in the table (1500)
#Then finding the average life expectancy of the high GDP countries
# Doing the same for the low GDP countries 


SELECT Status, ROUND( AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;

SELECT Status, COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status
;

# taking a look at avg life expectancy of developed vs developing countries and amount of countries per status

SELECT Country,ROUND(AVG( `Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country 
HAVING Life_Exp > 0 AND BMI > 0
ORDER BY BMI ASC
;

# comparing BMI To life expectancy 


SELECT Country,Year, 
`Life expectancy`, 
`Adult Mortality`, 
sum(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
;
# Looking at adult mortality rate and comparing life expectancy and year




