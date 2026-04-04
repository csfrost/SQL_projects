# World Layoffs — SQL Data Cleaning & Exploratory Analysis
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql)](https://www.mysql.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A structured SQL project performing end-to-end data cleaning and exploratory data analysis (EDA) on a global tech layoffs dataset spanning March 2020 to March 2023.

## Project Overview

This project takes a raw dataset of worldwide company layoffs and transforms it into a clean, analysis-ready table using MySQL. Following the cleaning phase, a series of EDA queries uncover trends in layoffs by company, industry, country, and time period — covering the Covid-19 pandemic era through to the 2022–2023 tech downturn.

**Key Findings:**
- **Survey Period:** March 2020 – March 2023
- **Total Layoffs Recorded:** 383,659 people
- **Companies with 100% Staff Layoff:** 116 companies
- **Highest Single-Day Layoff:** 12,000 employees
- **Hardest Hit Country:** United States (254,874 — 66.43% of total)
- **Worst Year:** 2022 with 160,661 layoffs

## Dataset

The raw dataset (`world_layoffs.csv`) contains company-level layoff records from around the world.

| Column | Description |
|---|---|
| `company` | Company name |
| `location` | City of the company |
| `industry` | Industry sector |
| `total_laid_off` | Number of employees laid off |
| `percentage_laid_off` | Proportion of workforce laid off |
| `date` | Date of the layoff event |
| `stage` | Company funding stage (e.g. Series B, Post-IPO) |
| `country` | Country of the company |
| `funds_raised_millions` | Total funds raised in millions USD |

## Project Structure

```
world-layoffs-sql-analysis/
├── README.md
├── LICENSE
├── world_layoffs.csv           # Raw dataset
└── world_layoffs.sql           # Data cleaning + EDA queries
```

## Data Cleaning Process

### 1. Duplicate Detection & Removal
Used a CTE with `ROW_NUMBER()` partitioned across all key columns to identify and remove 5 duplicate records.

```sql
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off,
            percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS occurences
    FROM world_layoffs
)
SELECT * FROM duplicate_cte WHERE occurences > 1;
```

### 2. Whitespace Standardisation
Trimmed leading and trailing spaces across all text columns — affecting 11 rows across 2,356 records.

```sql
UPDATE world_layoffs_copy
SET
    company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    stage = TRIM(stage),
    country = TRIM(country);
```

### 3. Date Standardisation & Type Casting
Converted the `date` column from raw text to a proper `DATE` type using `STR_TO_DATE()`.

```sql
UPDATE world_layoffs_copy
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE world_layoffs_copy MODIFY COLUMN `date` DATE;
```

### 4. Null & Blank Value Handling
Replaced blank `industry` values with `NULL`, then populated them by self-joining on company name where a known industry value existed.

```sql
UPDATE world_layoffs_copy AS l1
JOIN world_layoffs_copy AS l2 ON l1.company = l2.company
SET l1.industry = l2.industry
WHERE l1.industry IS NULL AND l2.industry IS NOT NULL;
```

## Exploratory Data Analysis

### Companies with the Highest Layoffs
```sql
SELECT company, SUM(total_laid_off)
FROM world_layoffs_copy
GROUP BY company
ORDER BY 2 DESC;
```
> Amazon led with 18,150, followed by Google (12,000) and Meta (11,000).

### Industries Most Affected
```sql
SELECT industry, SUM(total_laid_off) AS Total_staff_layoff
FROM world_layoffs_copy
GROUP BY 1
ORDER BY 2 DESC;
```
> Consumer (45,182), Retail (43,613), and Transportation (33,748) — sectors heavily disrupted by the Covid-19 pandemic.

### Layoffs by Year
```sql
SELECT YEAR(`date`) AS Years, SUM(total_laid_off) AS Total_staff_layoff
FROM world_layoffs_copy
WHERE YEAR(`date`) IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
```
> 2022 was the worst year (160,661), followed by 2023 (125,677) and 2020 (80,998).

### Cumulative Monthly Progression
```sql
WITH Cummulative_layoff_cte AS (
    SELECT
        SUBSTRING(`date`, 1, 7) AS Dates,
        SUM(total_laid_off) AS Total_staff_layoff
    FROM world_layoffs_copy
    WHERE `date` IS NOT NULL
    GROUP BY Dates
)
SELECT
    Dates,
    Total_staff_layoff,
    SUM(Total_staff_layoff) OVER(ORDER BY Dates) AS Cummulative_layoff
FROM Cummulative_layoff_cte;
```

### Top Company by Layoffs Per Year
```sql
WITH Yearly_progression AS (
    SELECT company, YEAR(`date`) AS Years, SUM(total_laid_off) AS Total_staff_layoff
    FROM world_layoffs_copy
    GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY Years ORDER BY Total_staff_layoff DESC) AS Ranking
FROM Yearly_progression
WHERE Years IS NOT NULL
ORDER BY Ranking ASC;
```
> Uber led in 2020 (7,525), Bytedance in 2021 (3,600), and Meta in 2022 (11,000).

## Getting Started

1. Clone this repository
2. Import the raw dataset into MySQL
3. Run the SQL script

```bash
# Clone the repository
git clone https://github.com/csfrost/world-layoffs-sql-analysis.git

# Navigate into the project directory
cd world-layoffs-sql-analysis
```

```sql
-- Import the dataset into MySQL, then run:
SOURCE world_layoffs.sql;
```

## Built With

- [MySQL 8.0](https://www.mysql.com/)
- [MySQL Workbench](https://www.mysql.com/products/workbench/)

## Author

**CSFrost**
- GitHub: [@csfrost](https://github.com/csfrost)

## Contact

For questions about this project or collaboration opportunities, please open an issue in this repository or reach out via GitHub.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Portfolio project demonstrating SQL data cleaning and exploratory analysis techniques on real-world layoff data.*
