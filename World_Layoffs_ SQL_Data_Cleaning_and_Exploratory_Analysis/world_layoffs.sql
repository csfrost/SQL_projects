
-- Viewing the rows in the table
SELECT *
FROM
	world_layoffs;

-- Checking for duplicates in the table
WITH duplicate_cte AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS occurences
FROM
	world_layoffs
)

SELECT *
FROM
	duplicate_cte
WHERE
	occurences > 1;
-- 5 row(s) returned 

-- Creating a copy of the data table with occurence column for manipulation purposes
CREATE TABLE `world_layoffs_copy` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `occurences` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting data from the original table to the duplicate
INSERT INTO world_layoffs_copy
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS occurences
FROM
	world_layoffs;

-- Checking data in the "world_layoffs_copy" table
SELECT *
FROM
	world_layoffs_copy;

-- Deleting duplicate data from the "world_layoffs_copy"
DELETE
FROM
	world_layoffs_copy
WHERE
	occurences > 1;
-- 5 row(s) affected

-- Removing leading and trailing spaces in columns
UPDATE world_layoffs_copy
SET 
	company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    stage = TRIM(stage),
    country = TRIM(country);
-- 11 row(s) affected Rows matched: 2356  Changed: 11  Warnings: 0

-- Standardising the date column
UPDATE world_layoffs_copy
SET
	`date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- 2355 row(s) affected Rows matched: 2356  Changed: 2355  Warnings: 0

-- Updating the data type for some columns
ALTER TABLE world_layoffs_copy
MODIFY COLUMN percentage_laid_off FLOAT;

ALTER TABLE world_layoffs_copy
MODIFY COLUMN `date` DATE;
    
ALTER TABLE world_layoffs_copy
MODIFY COLUMN total_laid_off INT;

ALTER TABLE world_layoffs_copy
MODIFY COLUMN funds_raised_millions INT;

-- REPLACING BLANK SPACES 
SELECT *
FROM
	world_layoffs_copy
WHERE
	industry = '';
-- 3 row(s) returned 

UPDATE world_layoffs_copy
SET
	industry = NULL
WHERE
	industry = '';
-- 3 row(s) affected Rows matched: 3  Changed: 3  Warnings: 0

-- Populating industry with null values with their respective type
UPDATE world_layoffs_copy AS l1
JOIN world_layoffs_copy AS l2
	ON l1.company = l2.company
SET
	l1.industry = l2.industry
WHERE
	l1.industry IS NULL
    AND
		l2.industry IS NOT NULL;
-- 3 row(s) affected Rows matched: 3  Changed: 3  Warnings: 0

-- Table after data cleaning
SELECT
	*
FROM
	world_layoffs_copy;
 
 
 
 -- EXPLORATORY DATA ANALYSIS
 
-- Checking the timeline for the data
SELECT 
	MIN(`date`) AS Survey_start_date,
    MAX(`date`) AS Survey_end_date
FROM
	world_layoffs_copy;
	-- '2020-03-11'  to '2023-03-06'

-- Total layoff during the time period
SELECT
	SUM(total_laid_off)
FROM
	world_layoffs_copy;
    -- A total of 383,659 people where laid off.

-- Select the maximum layoff per day
SELECT
	MAX(total_laid_off)
FROM
	world_layoffs_copy;
	-- 12,000 staffs where laid of in a single day.

-- checking companies with a 100% layoff
SELECT
	*
FROM
	world_layoffs_copy
WHERE
	percentage_laid_off = 1;
	-- 116 companies laid off 100% of their staff.

-- filtering companies with the highest number of lay off.
SELECT
	company,
    SUM(total_laid_off)
FROM
	world_layoffs_copy
GROUP BY
	company
ORDER BY
	2 DESC;
    /* From year 2020 to 2023, the company with the highest staffs layoff
    is Amazon with 18,150, followed by Google with 12,000 and Meta with 11000 */


-- Filtering the industry with the highest layoffs during the time period
SELECT
	industry,
    SUM(total_laid_off) AS Total_staff_layoff
FROM
	world_layoffs_copy
GROUP BY
	1
ORDER BY
	2 DESC;
    /* The Consumer	industry had the highest layoff of 45,182 followed 
    by the Retail in dustry with 43,613. Transportation laidoff 33,748. 
    Since this period concide with Covid pandemic, it's understandable 
    to see these industries as the highest affected */


-- Filtering the countries with the highest layoffs during the time period
SELECT
	country,
    SUM(total_laid_off) AS Total_staff_layoff
FROM
	world_layoffs_copy
GROUP BY
	1
ORDER BY
	2 DESC;
    /* United States has the highest number of layoff with 254,874 (66.43%),
    followed by India with 35,993(9.38%) and Netherlands with 17,220 (4.49%) */


-- Filtering the year with the highest layoof
SELECT
	YEAR(`date`) AS Years,
    SUM(total_laid_off) AS Total_staff_layoff
FROM
	world_layoffs_copy
WHERE
	YEAR(`date`) IS NOT NULL
GROUP BY
	1
ORDER BY
	2 DESC;
    /* In the year 2022, 160661 were laidoff, followed by 
    the year 2023 with 125677, and year 2020 with 80998. */
    

-- Monthly Progression of layoff
WITH Cummulative_layoff_cte AS (
	SELECT
		SUBSTRING(`date`, 1, 7) AS Dates,
		SUM(total_laid_off) AS Total_staff_layoff
	FROM
		world_layoffs_copy
	WHERE
		`date` IS NOT NULL
	GROUP BY
		Dates
	ORDER BY 1 ASC
    )
SELECT
	Dates,
    Total_staff_layoff,
    SUM(Total_staff_layoff) OVER(ORDER BY Dates) AS Cummulative_layoff
FROM
	Cummulative_layoff_cte;
    

-- Company with the most layoff per year.
WITH Yearly_progression(company, Years, Total_staff_layoff) AS (
	SELECT
		company,
		YEAR(`date`),
		SUM(total_laid_off)
	FROM
		world_layoffs_copy
	GROUP BY
		company,
		YEAR(`date`)
	ORDER BY
		3 DESC
	)
SELECT
	*,
    DENSE_RANK() OVER(PARTITION BY Years ORDER BY Total_staff_layoff DESC) AS Ranking
FROM
	Yearly_progression
WHERE
	Years IS NOT NULL
ORDER BY Ranking ASC;

/* In 2020 Uber	had the most layoff with 7525, while Bytedance had the most 
layoff in 2021 with	3600, and Meta had the highest layoff in 2022 with 11000 */.












































































































































































































































