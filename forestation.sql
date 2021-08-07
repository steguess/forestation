	# Forestation View

CREATE VIEW forestation as
(SELECT
	f.country_code as code,
    f.country_name as country,
    r.region as region,
    r.income_group as income_group,
    f.year as year,
    f.forest_area_sqkm as f_area_sqkm,
    l.total_area_sq_mi as l_area_sq_mi,
    (f.forest_area_sqkm/(l.total_area_sq_mi*2.59))*100 as 	percentage_forest
FROM Forest_area f
	JOIN land_area l
	ON f.Country_code = l.country_code AND f.year = l.year
 	JOIN regions r
 	ON f.country_code = r.country_code);


	#	Question 1a: What was the total forest area (in sq km) of the world in 1990?

SELECT Sum(f_area_Sqkm)
FROM forestation
WHERE country= 'World' AND year='1990';



	# Question 1b: What was the total forest area (in sq km) of the world in 2016?

SELECT Sum(f_area_Sqkm)
FROM forestation
WHERE country= 'World' AND year='2016';


	# Question 1c: What was the change (in sq km) in the forest area of the world from 1990 to 2016?

WITH a1 AS
	(SELECT *
     	FROM forestation
		WHERE country= 'World' AND year='2016'
		UNION
	SELECT *
    	FROM forestation
		WHERE country= 'World' AND year='1990')

SELECT  f_area_sqkm AS Forest_area,
	     year,
	     LEAD(f_area_sqkm) OVER (ORDER BY year) AS lead,
        	     LEAD(f_area_sqkm) OVER (ORDER BY year) - f_area_sqkm AS lead_differ,
( (LEAD(f_area_sqkm) OVER (ORDER BY year) - f_area_sqkm)/(f_area_sqkm))*100  AS change
FROM a1;


# Question 1d: What was the percent change in forest area of the world between 1990 and 2016?

WITH a1 AS
	(SELECT *
     	FROM forestation
		WHERE country= 'World' AND year='2016'
		UNION
	SELECT *
    	FROM forestation
		WHERE country= 'World' AND year='1990'),

a2 AS
	(SELECT  f_area_sqkm AS Forest_area,
	     	     year,
	     	     LEAD(f_area_sqkm) OVER (ORDER BY year) AS lead,
        	     	     LEAD(f_area_sqkm) OVER (ORDER BY year) - f_area_sqkm AS lead_differ,
((LEAD(f_area_sqkm) OVER (ORDER BY year)-f_area_sqkm)/(f_area_sqkm))*100  AS change
FROM a1)

 SELECT ROUND(CAST(change as numeric),2) as change_f_area
 FROM a2;

# Question 1 e: If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

SELECT l_area_sq_mi*2.59 as land_area,
	   country
FROM forestation
	WHERE year= '2016' AND (l_area_sq_mi*2.59) <= 1324449
ORDER BY 1 DESC
LIMIT 1;


# 2a) What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?

# World forestation in 2016

SELECT ROUND(CAST(percentage_forest AS NUMERIC),2)
FROM forestation
WHERE year = '2016' AND Country = 'World';

# Highest and lowest Forestation
# Table used for questions below

CREATE TABLE regional_outlook AS(
SELECT 	f.year,
  		r.region,
ROUND(CAST((SUM(f.forest_area_sqkm)*100/SUM(l.total_area_sq_mi *2.59)) AS NUMERIC),2) AS percentage
FROM Forest_area f
	JOIN land_area l
	ON f.Country_code = l.country_code AND f.year = l.year
 	JOIN regions r
 	ON f.country_code = r.country_code
WHERE f.year IN (1990, 2016) AND f.forest_area_sqkm IS NOT NULL AND l.total_area_sq_mi IS NOT NULL
GROUP BY 1,2);

SELECT *
FROM regional_outlook
WHERE year = 2016  AND NOT region='World'
ORDER BY percentage DESC
LIMIT 1

SELECT *
FROM regional_outlook
WHERE year = 2016  AND NOT region='World'
ORDER BY percentage ASC
LIMIT 1

# b) What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places
# c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?


# HIGEST and LOWEST percent forest

SELECT *
FROM regional_outlook
WHERE year = 1990  AND NOT region='World'
ORDER BY percentage DESC
LIMIT 1

SELECT *
FROM regional_outlook
WHERE year = 1990  AND NOT region='World'
ORDER BY percentage ASC
LIMIT 1

# PERCENT forest of the entire world and Difference of forest percentage

WITH year_1990 AS
(SELECT year,
 		region,
 		percentage as Forest_Area_1990
 FROM regional_outlook
 WHERE year= 1990),

 year_2016 AS
 (SELECT year,
  		 region,
  		 percentage AS Forest_Area_2016
 FROM regional_outlook
 WHERE year= 2016)

SELECT y1.region,
	   y2.Forest_Area_2016,
      	   y1.Forest_Area_1990,
     	  y2.Forest_Area_2016-y1.Forest_Area_1990 AS period_Difference
 FROM year_1990 y1
 	JOIN year_2016 y2
 	ON y1.region= y2.region
ORDER BY 4

# 3) COUNTRY LEVEL DETAIL

SUCCESS
ABSOLUTE TOP 2

WITH f_2016 AS
(SELECT code,
 		country,
 		region,
 		year,
 		f_area_sqkm AS forest_Area_2016,
 		l_area_sq_mi as l_area_2016
 FROM forestation
WHERE year='2016' AND f_area_sqkm IS NOT NULL AND NOT country='World'),

f_1990 AS
(SELECT code,
 		country,
 		region,
 		year,
 		f_area_sqkm AS forest_Area_1990,
 		l_area_sq_mi as l_area_1990
FROM forestation
        WHERE year='1990'AND f_area_sqkm IS NOT NULL AND NOT country='World')

SELECT 	f16.code,
		f16.country,
        		f16.region,
       		f90.l_area_1990,
        		f16.l_area_2016,
        		f90.forest_Area_1990,
        		f16.forest_Area_2016,
(f16.forest_Area_2016-f90.forest_Area_1990) AS Change, ROUND(CAST(((f16.forest_Area_2016-f90.forest_Area_1990)*100/f90.forest_Area_1990) AS NUMERIC),2) AS percentage
FROM f_2016 f16
	JOIN f_1990 f90
	ON f16.code = f90.code
ORDER BY change DESC
LIMIT 2


# PERCENTAGE CHANGE TOP 1

WITH f_2016 AS
(SELECT code,
 		country,
 		region,
 		year,
 		f_area_sqkm AS forest_Area_2016,
 		l_area_sq_mi as l_area_2016
 FROM forestation
WHERE year='2016' AND f_area_sqkm IS NOT NULL AND NOT country='World'),

f_1990 AS
(SELECT code,
 		country,
 		region,
 		year,
 		f_area_sqkm AS forest_Area_1990,
 		l_area_sq_mi as l_area_1990
FROM forestation
WHERE year='1990'AND f_area_sqkm IS NOT NULL AND NOT country='World')

SELECT	f16.code,
		f16.country,
        		f16.region,
        		f90.l_area_1990,
       		f16.l_area_2016,
        		f90.forest_Area_1990,
       		f16.forest_Area_2016,
(f16.forest_Area_2016-f90.forest_Area_1990) AS Change, ROUND(CAST(((f16.forest_Area_2016-f90.forest_Area_1990)*100/f90.forest_Area_1990) AS NUMERIC),2) AS percentage
FROM f_2016 f16
	JOIN f_1990 f90
	ON f16.code = f90.code
ORDER BY percentage DESC
LIMIT 1



# CONCERNS
# a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
# Table 3.1

WITH f_2016 AS
(SELECT	code,
 		country,
 		region,
 		year,
 		f_area_sqkm AS forest_Area_2016
 FROM forestation
	WHERE year='2016' AND f_area_sqkm IS NOT NULL AND NOT country='World'),

f_1990 AS
(SELECT code,
 		country,
 		region,
 		year,
 		f_area_sqkm AS forest_Area_1990
FROM forestation
        WHERE year='1990'AND f_area_sqkm IS NOT NULL AND NOT country='World')

SELECT 	f16.code,
		f16.country,
        		f16.region,
        		f90.forest_Area_1990,
        		f16.forest_Area_2016,
(f16.forest_Area_2016-f90.forest_Area_1990) AS Change, ROUND(CAST(((f16.forest_Area_2016-f90.forest_Area_1990)*100/f90.forest_Area_1990) AS NUMERIC),2) AS percentage
FROM f_2016 f16
	JOIN f_1990 f90
	ON f16.code = f90.code
ORDER BY change
LIMIT 5

# 3b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?

# Table 3.2.


WITH f_2016 AS
(SELECT code,
 		country,
 		region,
 		year,
 		f_area_sqkm AS forest_Area_2016
 FROM forestation
	WHERE year='2016' AND f_area_sqkm IS NOT NULL AND NOT country='World'),

f_1990 AS
(SELECT 	code,
 		country,
 		region,
 		year,
 		f_area_sqkm AS forest_Area_1990
FROM forestation
        WHERE year='1990'AND f_area_sqkm IS NOT NULL AND NOT country='World')

SELECT 	f16.code,
		f16.country,
        		f16.region,
        		f90.forest_Area_1990,
        		f16.forest_Area_2016,
(f16.forest_Area_2016-f90.forest_Area_1990) AS Change, ROUND(CAST(((f16.forest_Area_2016-f90.forest_Area_1990)*100/f90.forest_Area_1990) AS NUMERIC),2) AS percentage
FROM f_2016 f16
	JOIN f_1990 f90
	ON f16.code = f90.code
ORDER BY percentage
LIMIT 5



# 3c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

# Count of Quartiles

WITH sub AS
(SELECT 	country,
 		percentage_forest
 FROM forestation
	WHERE year='2016' AND f_area_sqkm IS NOT NULL AND NOT country ='World'),


sub_quartiles AS
(SELECT country,
CASE
WHEN percentage_forest>=75 then '4th quartile'
WHEN percentage_forest BETWEEN 50 AND 75 then '3rd quartile'
WHEN percentage_forest BETWEEN 25 AND 50 then '2nd quartile'
ELSE '1st quartile'
END AS quartile
FROM sub)


SELECT	Count(*),
		quartile
FROM sub_quartiles
GROUP BY 2
ORDER BY 1 DESC

# d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016
# TOP Quartiles

WITH sub AS
(SELECT 	country,
 		region,
 		percentage_forest
 FROM forestation
	WHERE year='2016' AND f_area_sqkm IS NOT NULL AND NOT country ='World'),

sub_quartiles AS
(SELECT 	country,
 		region,
		percentage_forest,
CASE
WHEN percentage_forest>=75 then '4th quartile'
WHEN percentage_forest BETWEEN 50 AND 75 then '3rd quartile'
WHEN percentage_forest BETWEEN 25 AND 50 then '2nd quartile'
ELSE '1st quartile'
END AS quartile
FROM sub)

SELECT	country,
		region,
		ROUND(CAST(percentage_forest AS NUMERIC),2),
        		quartile
FROM sub_quartiles
WHERE quartile = '4th quartile'
ORDER BY 3 DESC
# Additional question
# 3e) How many countries had a percent forestation higher than the United States in 2016?

WITH sub AS
(SELECT country,
 		region,
 		percentage_forest
 FROM forestation
	WHERE year='2016' AND f_area_sqkm is NOT NULL AND NOT country ='World'),

sub_quartiles AS
(SELECT country,
 		region,
		percentage_forest,
CASE
WHEN percentage_forest>=75 then '4th quartile'
WHEN percentage_forest BETWEEN 50 AND 75 then '3rd quartile'
WHEN percentage_forest BETWEEN 25 AND 50 then '2nd quartile'
ELSE '1st quartile'
END AS quartile
FROM sub)

SELECT	country,
		region,
		ROUND(CAST(percentage_forest AS NUMERIC),2) as Percent_forest,
        		quartile
FROM sub_quartiles
WHERE country='United States'


# Result of 33.93 be used to determine the countries

WITH sub AS
(SELECT country,
 		region,
 		percentage_forest
 FROM forestation
	WHERE year='2016' AND f_area_sqkm is NOT NULL AND NOT country ='World'),

sub_quartiles AS
(SELECT country,
 		region,
		percentage_forest,
CASE
WHEN percentage_forest>=75 then '4th quartile'
WHEN percentage_forest BETWEEN 50 AND 75 then '3rd quartile'
WHEN percentage_forest BETWEEN 25 AND 50 then '2nd quartile'
ELSE '1st quartile'
END AS quartile
FROM sub)

SELECT	Count(*)
FROM sub_quartiles
WHERE percentage_forest>33.93
