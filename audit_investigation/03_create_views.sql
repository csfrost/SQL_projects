/*
================================================================================
 REUSABLE VIEWS FOR AUDIT INVESTIGATION
 Maji Ndogo Audit Investigation - Part 3
================================================================================

 PURPOSE:
 Creates persistent VIEWs that can be reused across multiple analysis queries.
 Views simplify complex queries and provide consistent data access.
 
 VIEWS CREATED:
 1. Incorrect_records - All records where auditor/surveyor scores differ
 2. Employee_error_summary - Error counts per employee
 3. Suspect_employees - Employees with above-average errors
 
================================================================================
*/

USE md_water_services;

-- ============================================================================
-- VIEW 1: Incorrect_records
-- ============================================================================
/*
 PURPOSE: Combines auditor report with database to show all discrepancies
 
 JOINS:
 - auditor_report: Independent audit findings
 - visits: Links location_id to record_id and employee
 - water_quality: Original surveyor scores
 - employee: Employee names
 
 FILTERS:
 - visit_count = 1: Avoid duplicate entries from re-visits
 - Scores don't match: Identifies errors/tampering
*/

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
    visits AS v 
    ON ar.location_id = v.location_id
JOIN
    water_quality AS wq 
    ON v.record_id = wq.record_id
JOIN
    employee AS e 
    ON e.assigned_employee_id = v.assigned_employee_id
WHERE
    v.visit_count = 1
    AND ar.true_water_source_score <> wq.subjective_quality_score;

-- Test the view
-- SELECT COUNT(*) FROM Incorrect_records; -- Should return 102


-- ============================================================================
-- VIEW 2: Employee_error_summary
-- ============================================================================
/*
 PURPOSE: Aggregates error counts by employee for easy analysis
 
 INCLUDES:
 - Employee name
 - Number of mistakes
 - Running average (for comparison)
*/

CREATE OR REPLACE VIEW Employee_error_summary AS
SELECT
    surveyor_name,
    COUNT(surveyor_name) AS number_of_mistakes,
    ROUND(AVG(COUNT(surveyor_name)) OVER(), 2) AS average_mistakes
FROM
    Incorrect_records
GROUP BY
    surveyor_name
ORDER BY
    number_of_mistakes DESC;

-- Test the view
-- SELECT * FROM Employee_error_summary;


-- ============================================================================
-- VIEW 3: Suspect_employees
-- ============================================================================
/*
 PURPOSE: Filters employees with above-average error rates
 
 These employees warrant further investigation due to statistically
 anomalous error patterns.
*/

CREATE OR REPLACE VIEW Suspect_employees AS
SELECT
    surveyor_name,
    number_of_mistakes,
    average_mistakes
FROM
    Employee_error_summary
WHERE
    number_of_mistakes > average_mistakes;

-- Test the view
-- SELECT * FROM Suspect_employees;
-- Should return: Bello Azibo (26), Malachi Mavuso (21), 
--                Zuriel Matembo (17), Lalitha Kaburi (7)


-- ============================================================================
-- USAGE EXAMPLES
-- ============================================================================
/*
 After creating these views, you can run simplified queries:
 
 -- Get all incorrect records
 SELECT * FROM Incorrect_records;
 
 -- See error summary by employee
 SELECT * FROM Employee_error_summary;
 
 -- List suspects
 SELECT * FROM Suspect_employees;
 
 -- Find "cash" mentions for suspects only
 SELECT location_id, surveyor_name, auditor_statement
 FROM Incorrect_records
 WHERE surveyor_name IN (SELECT surveyor_name FROM Suspect_employees)
   AND auditor_statement LIKE '%cash%';
 
 -- Verify no "cash" mentions for non-suspects
 SELECT location_id, surveyor_name, auditor_statement
 FROM Incorrect_records
 WHERE surveyor_name NOT IN (SELECT surveyor_name FROM Suspect_employees)
   AND auditor_statement LIKE '%cash%';
 -- (Should return empty result)
*/

-- ============================================================================
-- CLEANUP (if needed)
-- ============================================================================
/*
 To remove these views:
 
 DROP VIEW IF EXISTS Incorrect_records;
 DROP VIEW IF EXISTS Employee_error_summary;
 DROP VIEW IF EXISTS Suspect_employees;
*/
