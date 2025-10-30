# World Life Expectancy Project (Data Cleaning)



SELECT *
FROM world_life_expectancy
;

SELECT Country, Year, CONCAT(Country,Year),COUNT(CONCAT(Country,Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country,Year)
HAVING COUNT(CONCAT(Country,Year)) > 1
;


SELECT *
FROM(
	SELECT Row_ID, 
	CONCAT(Country,Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
    ) AS Row_table
WHERE Row_Num > 1
;


DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
FROM(
	SELECT Row_ID, 
	CONCAT(Country,Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country,Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
    ) AS Row_table
WHERE Row_Num > 1
)
;


SELECT *
FROM world_life_expectancy
WHERE Status = ''
;

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE NOT Status = ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'

UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN ( 
	SELECT DISTINCT(Country)
	FROM world_life_expectancy
	WHERE Status = 'Developing'
    )
;

UPDATE world_life_expectancy t1 
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

SELECT *
FROM world_life_expectancy
WHERE Country = 'United States of America'
;

UPDATE world_life_expectancy t1 
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

SELECT Country,Year, `Life expectancy`
FROM world_life_expectancy
;



SELECT t1.Country,t1.Year, t1.`Life expectancy`,
t2.Country,t2.Year, t2.`Life expectancy`,
t3.Country,t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
FROM world_life_expectancy t1 
JOIN world_life_expectancy t2 
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
JOIN world_life_expectancy t3 
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
WHERE t1.`Life expectancy` = ''
;



UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
JOIN world_life_expectancy t3 
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = ''
;


SELECT *
FROM world_life_expectancy
;