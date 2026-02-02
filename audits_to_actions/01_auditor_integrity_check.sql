-- ============================================================================
-- MAJI NDOGO WATER CRISIS PROJECT
-- Part 3: Auditor Integrity Check — Weaving the Data Threads
-- ============================================================================
-- Author:       [Your Name]
-- Database:     md_water_services
-- Tools:        MySQL 8.0+
-- Description:  Cross-references auditor field reports with surveyor records
--               to detect scoring discrepancies, identify employees with
--               above-average error rates, and flag those linked to
--               corruption-related statements.
-- ============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- SECTION 1: Compare Auditor vs. Surveyor Scores
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- The independent auditor visited 1,620 locations and re-scored each water
-- source. This CTE isolates the 102 records where the surveyor's subjective
-- quality score DISAGREES with the auditor's true score (first visits only).
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WITH records AS (
    SELECT
        ar.location_id,
        ws.type_of_water_source  AS surveyor_source_type,
        wq.subjective_quality_score AS surveyor_score,
        ar.type_of_water_source  AS auditor_source_type,
        ar.true_water_source_score  AS auditor_score
    FROM
        water_quality AS wq
    JOIN visits        AS v  ON v.record_id   = wq.record_id
    JOIN auditor_report AS ar ON ar.location_id = v.location_id
    JOIN water_source   AS ws ON ws.source_id   = v.source_id
    WHERE
        v.visit_count = 1
        AND wq.subjective_quality_score <> ar.true_water_source_score
),
-- KEY FINDING:
--   • 1,518 of 1,620 surveyor scores match the auditor scores (93.7 %).
--   • 102 conflicting scores warrant further investigation.


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- SECTION 2: Attribute Errors to Individual Surveyors
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Joins the employee table to attach the surveyor's name to every
-- mismatched record, while also pulling the auditor's free-text statement
-- for qualitative analysis.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Incorrect_records AS (
    SELECT
        ar.location_id,
        e.employee_name                AS surveyor_name,
        wq.subjective_quality_score    AS surveyor_score,
        ar.type_of_water_source        AS auditor_source_type,
        ar.true_water_source_score     AS auditor_score,
        ar.statements                  AS auditor_statement
    FROM
        water_quality  AS wq
    JOIN visits         AS v  ON v.record_id            = wq.record_id
    JOIN auditor_report AS ar ON ar.location_id         = v.location_id
    JOIN employee       AS e  ON e.assigned_employee_id = v.assigned_employee_id
    WHERE
        v.visit_count = 1
        AND wq.subjective_quality_score <> ar.true_water_source_score
),


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- SECTION 3: Identify Employees with Above-Average Mistakes
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Uses a window function to compute the overall average mistake count,
-- then filters for employees who exceed that threshold.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suspected_employees AS (
    SELECT
        surveyor_name,
        COUNT(surveyor_name)                    AS number_of_mistakes,
        ROUND(AVG(COUNT(surveyor_name)) OVER()) AS average_mistake
    FROM
        Incorrect_records
    GROUP BY
        surveyor_name
    ORDER BY
        number_of_mistakes DESC
),

Top_suspects AS (
    SELECT
        surveyor_name,
        number_of_mistakes
    FROM
        Suspected_employees
    WHERE
        number_of_mistakes > average_mistake
)
-- KEY FINDING — Employees exceeding the average error rate:
--   • Bello Azibo    — 26 incorrect inputs
--   • Malachi Mavuso — 21 incorrect inputs
--   • Zuriel Matembo — 17 incorrect inputs
--   • Lalitha Kaburi —  7 incorrect inputs


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- SECTION 4: Corroborate with Auditor Statements (Corruption Flag)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Narrows the suspect list to employees whose mismatched locations also
-- have auditor statements mentioning "cash" — a strong indicator of bribery.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT
    location_id,
    surveyor_name,
    auditor_statement
FROM
    Incorrect_records
WHERE
    auditor_statement LIKE '%cash%'
    AND surveyor_name IN (
        SELECT surveyor_name
        FROM   Top_suspects
    );

-- CONCLUSION:
--   All four suspects — Bello Azibo, Lalitha Kaburi, Zuriel Matembo, and
--   Malachi Mavuso — have incriminating "cash" references in auditor
--   statements at locations where their scores diverged. No other employees
--   appear in these results, strengthening the case for targeted misconduct.
-- ============================================================================
