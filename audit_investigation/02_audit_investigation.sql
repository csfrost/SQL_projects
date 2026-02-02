/*
================================================================================
 MAJI NDOGO AUDIT INVESTIGATION
 Part 3: Weaving the Data Threads of Maji Ndogo's Narrative
================================================================================
 
 Project: Maji Ndogo Water Crisis Analysis
 Database: md_water_services
 Author: Data Analysis Team
 
 PURPOSE:
 This script integrates an independent auditor's report with the existing
 water services database to verify data integrity, identify discrepancies,
 and investigate potential corruption among field surveyors.
 
 SECTIONS:
 1. Setup - Create auditor_report table
 2. Data Validation - Compare auditor vs surveyor scores
 3. Employee Investigation - Link errors to specific employees
 4. Evidence Gathering - Build case against suspected employees
 
================================================================================
*/

USE md_water_services;

-- ============================================================================
-- SECTION 1: SETUP - CREATE AUDITOR REPORT TABLE
-- ============================================================================
/*
 The auditor visited 1,620 locations and independently measured water quality.
 Their findings are stored in a CSV file that we import into this table.
*/

DROP TABLE IF EXISTS `auditor_report`;

CREATE TABLE `auditor_report` (
    `location_id` VARCHAR(32),
    `type_of_water_source` VARCHAR(64),
    `true_water_source_score` INT DEFAULT NULL,
    `statements` VARCHAR(255)
);

-- After creating table, import CSV using:
-- MySQL Workbench: Table Data Import Wizard
-- Or: LOAD DATA INFILE command

-- Verify import
SELECT COUNT(*) AS total_audited_sites FROM auditor_report;
-- Expected: 1620 records


-- ============================================================================
-- SECTION 2: DATA VALIDATION - COMPARE SCORES
-- ============================================================================
/*
 Goal: Compare the auditor's "true" scores with our surveyors' scores
 
 Challenge: The auditor_report uses location_id, but water_quality uses record_id
 Solution: Use the visits table as a bridge (it has both location_id and record_id)
 
 Table Relationships:
 auditor_report.location_id --> visits.location_id
 visits.record_id --> water_quality.record_id
*/

-- Step 2a: Basic score comparison
-- Join auditor_report --> visits --> water_quality

SELECT
    ar.location_id,
    ar.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score
FROM 
    auditor_report AS ar
JOIN
    visits AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
WHERE
    v.visit_count = 1  -- Only first visits to avoid duplicates
LIMIT 10;


-- Step 2b: Count MATCHING records (scores are equal)
SELECT 
    COUNT(*) AS matching_records
FROM 
    auditor_report AS ar
JOIN 
    visits AS v ON ar.location_id = v.location_id
JOIN 
    water_quality AS wq ON v.record_id = wq.record_id
WHERE 
    v.visit_count = 1
    AND ar.true_water_source_score = wq.subjective_quality_score;
-- Result: 1518 matching records (94% accuracy!)


-- Step 2c: Count NON-MATCHING records (discrepancies)
SELECT 
    COUNT(*) AS incorrect_records
FROM 
    auditor_report AS ar
JOIN 
    visits AS v ON ar.location_id = v.location_id
JOIN 
    water_quality AS wq ON v.record_id = wq.record_id
WHERE 
    v.visit_count = 1
    AND ar.true_water_source_score <> wq.subjective_quality_score;
-- Result: 102 incorrect records


-- Step 2d: Verify water source types match (even if scores don't)
-- This confirms our previous analyses based on source types are still valid

SELECT
    ar.location_id,
    ar.type_of_water_source AS auditor_source,
    ws.type_of_water_source AS surveyor_source,
    ar.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score
FROM 
    auditor_report AS ar
JOIN
    visits AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
JOIN
    water_source AS ws ON v.source_id = ws.source_id
WHERE
    v.visit_count = 1
    AND ar.true_water_source_score <> wq.subjective_quality_score
LIMIT 10;
-- Result: Source types match even when scores differ - previous analyses valid!


-- ============================================================================
-- SECTION 3: EMPLOYEE INVESTIGATION
-- ============================================================================
/*
 Goal: Identify which employees made the incorrect records
 
 Two possibilities:
 1. Human error - normal mistakes
 2. Deliberate falsification - corruption
 
 Approach: Link incorrect records to employees and look for patterns
*/

-- Step 3a: Create VIEW for incorrect records with employee names
-- Using VIEW instead of CTE for reusability across multiple queries

CREATE OR REPLACE VIEW Incorrect_records AS
SELECT
    ar.location_id,
    v.record_id,
    e.employee_name AS surveyor_name,
    ar.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score,
    ar.type_of_water_source AS auditor_source_type,
    ar.statements AS auditor_statement
FROM 
    auditor_report AS ar
JOIN
    visits AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
JOIN
    employee AS e ON e.assigned_employee_id = v.assigned_employee_id
WHERE
    v.visit_count = 1
    AND ar.true_water_source_score <> wq.subjective_quality_score;

-- Verify the view
SELECT * FROM Incorrect_records LIMIT 10;
-- Should return 102 records total


-- Step 3b: Count unique employees with errors
SELECT COUNT(DISTINCT surveyor_name) AS employees_with_errors
FROM Incorrect_records;
-- Result: 17 employees made at least one error


-- Step 3c: Count mistakes per employee
SELECT
    surveyor_name,
    COUNT(*) AS number_of_mistakes
FROM
    Incorrect_records
GROUP BY
    surveyor_name
ORDER BY
    number_of_mistakes DESC;


-- Step 3d: Calculate average mistakes per employee
SELECT 
    AVG(mistake_count) AS avg_mistakes_per_employee
FROM (
    SELECT
        surveyor_name,
        COUNT(*) AS mistake_count
    FROM
        Incorrect_records
    GROUP BY
        surveyor_name
) AS error_counts;
-- Result: ~6 mistakes on average


-- ============================================================================
-- SECTION 4: EVIDENCE GATHERING - IDENTIFY SUSPECTS
-- ============================================================================
/*
 Goal: Find employees with ABOVE-AVERAGE mistakes and corroborating evidence
 
 Methodology:
 1. Calculate error_count per employee (CTE)
 2. Compare to average (subquery)
 3. Filter for above-average (suspect_list CTE)
 4. Search for incriminating statements
*/

-- Step 4a: Complete investigation query with nested CTEs
WITH 
-- CTE 1: Count mistakes per employee
error_count AS (
    SELECT
        surveyor_name,
        COUNT(surveyor_name) AS number_of_mistakes
    FROM
        Incorrect_records
    /*  
        Incorrect_records is a VIEW that joins:
        auditor_report --> visits --> water_quality --> employee
        for records where auditor and surveyor scores differ
    */
    GROUP BY
        surveyor_name
),

-- CTE 2: Identify employees with above-average mistakes
suspect_list AS (
    SELECT
        surveyor_name,
        number_of_mistakes
    FROM
        error_count
    WHERE
        number_of_mistakes > (
            SELECT AVG(number_of_mistakes) FROM error_count
        )
)

-- Main query: Get suspect names and mistake counts
SELECT * FROM suspect_list ORDER BY number_of_mistakes DESC;

/*
 RESULTS - SUSPECTED EMPLOYEES:
 +------------------+---------------------+
 | surveyor_name    | number_of_mistakes  |
 +------------------+---------------------+
 | Bello Azibo      | 26                  |
 | Malachi Mavuso   | 21                  |
 | Zuriel Matembo   | 17                  |
 | Lalitha Kaburi   | 7                   |
 +------------------+---------------------+
 Average is ~6, so these 4 are significantly above average
*/


-- Step 4b: Examine statements for suspects
-- Look for patterns in what locals said about these employees

WITH 
error_count AS (
    SELECT
        surveyor_name,
        COUNT(surveyor_name) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        surveyor_name
),
suspect_list AS (
    SELECT
        surveyor_name,
        number_of_mistakes
    FROM
        error_count
    WHERE
        number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)

-- Filter incorrect records for suspects only
SELECT
    surveyor_name,
    location_id,
    auditor_statement
FROM
    Incorrect_records
WHERE
    surveyor_name IN (SELECT surveyor_name FROM suspect_list)
ORDER BY
    surveyor_name;


-- Step 4c: Search for "cash" mentions in statements
-- The word "cash" appears in statements suggesting bribery

WITH 
error_count AS (
    SELECT
        surveyor_name,
        COUNT(surveyor_name) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        surveyor_name
),
suspect_list AS (
    SELECT
        surveyor_name,
        number_of_mistakes
    FROM
        error_count
    WHERE
        number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)

-- Find records mentioning "cash" for suspects
SELECT
    location_id,
    surveyor_name,
    auditor_statement
FROM
    Incorrect_records
WHERE
    auditor_statement LIKE '%cash%'
    AND surveyor_name IN (SELECT surveyor_name FROM suspect_list);


-- Step 4d: CRITICAL CHECK - Are there "cash" mentions for NON-suspects?
-- This verifies the allegations are EXCLUSIVE to our suspects

WITH 
error_count AS (
    SELECT
        surveyor_name,
        COUNT(surveyor_name) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        surveyor_name
),
suspect_list AS (
    SELECT
        surveyor_name,
        number_of_mistakes
    FROM
        error_count
    WHERE
        number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)

-- Check for "cash" mentions NOT in suspect list
SELECT
    location_id,
    surveyor_name,
    auditor_statement
FROM
    Incorrect_records
WHERE
    auditor_statement LIKE '%cash%'
    AND surveyor_name NOT IN (SELECT surveyor_name FROM suspect_list);

-- Result: EMPTY! No other employees have "cash" allegations


-- ============================================================================
-- SUMMARY OF EVIDENCE
-- ============================================================================
/*
 INVESTIGATION FINDINGS:
 
 1. STATISTICAL EVIDENCE:
    - 4 employees have above-average error rates
    - Bello Azibo: 26 mistakes (4x average)
    - Malachi Mavuso: 21 mistakes
    - Zuriel Matembo: 17 mistakes
    - Lalitha Kaburi: 7 mistakes (above avg of 6)
 
 2. WITNESS STATEMENTS:
    - Multiple statements mention "cash" payments
    - These allegations appear ONLY for the 4 suspects
    - No other employees have bribery allegations
 
 3. PATTERN ANALYSIS:
    - All incorrect scores were inflated to 10 (maximum)
    - Source types were NOT changed (preserving some truth)
    - Suggests intentional score manipulation
 
 CONCLUSION:
 While not definitive proof, the combination of:
 - Statistical anomalies
 - Exclusive bribery allegations
 - Consistent inflation pattern
 
 ...provides sufficient evidence to flag these employees for further
 investigation by President Naledi's anti-corruption team.
 
 SUSPECTED EMPLOYEES:
 - Bello Azibo
 - Malachi Mavuso  
 - Zuriel Matembo
 - Lalitha Kaburi
*/

-- End of investigation script
