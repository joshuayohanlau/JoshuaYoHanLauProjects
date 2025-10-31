# US Household Income DATA Cleaning

SELECT *
FROM us_project.us_household_income
;

SELECT *
FROM us_project.us_household_income_statistics
;

ALTER TABLE  us_project.us_household_income_statistics RENAME COLUMN `ï»¿id` To `id`;

# changing the column titles to something more readable

SELECT COUNT(id)
FROM us_project.us_household_income
;

SELECT COUNT(id)
FROM us_project.us_household_income_statistics
;

# checking count for missing rows 

SELECT id, COUNT(id)
from us_project.us_household_income
GROUP BY id
HAVING COUNT(id) > 1
;
# checking from duplicates using the id and counting to see if the id shows up more than once


SELECT *
FROM (
	SELECT row_id, id, 
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
	FROM us_project.us_household_income
    ) AS row_table
WHERE row_num > 1
;

# identify the duplicate rows by using a subquery to show the 2nd duplicate row

DELETE FROM us_household_income
	WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id, id, 
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		FROM us_project.us_household_income
		) AS row_table
	WHERE row_num > 1 )
;

# now deleting the targeted rows using another subquery and using delete from


SELECT id, COUNT(id)
from us_project.us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1
;

# checking for duplicates in the statistics table

SELECT DISTINCT State_Name
FROM us_household_income
GROUP BY 1
;
# noticed issue with state names so going to check the distinct names

UPDATE us_project.us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

UPDATE us_project.us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;
# fixing the issues found 



SELECT *
FROM us_household_income
WHERE Place = ''
;
# noticed blank in place column, so checking for more

SELECT *
FROM us_household_income
WHERE County = 'Autauga County'
ORDER BY 1
;

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;

# fixed issues found for missing data


SELECT Type,Count(Type)
FROM us_project.us_household_income
GROUP BY Type

;

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

# fixing issue found with type
SELECT* 
FROM us_project.us_household_income
;

SELECT ALand, AWater
FROM us_project.us_household_income
WHERE (AWater = 0 OR AWater = '' OR AWater IS NULL)
AND (ALand = 0 OR ALand = '' OR ALand IS NULL)
;

# no real issue with the ALand and AWater, data looks reliable