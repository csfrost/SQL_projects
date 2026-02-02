/*
================================================================================
 WATER SERVICES ANALYSIS - MAJI NDOGO REGION
================================================================================
 Project:     Water Infrastructure Assessment
 Database:    md_water_services
 Author:      csfrost
 Repository:  https://github.com/csfrost/water_services_analysis
 
 Description: Comprehensive SQL analysis examining water sources, quality 
              metrics, queue times, and data integrity for the Maji Ndogo 
              region. Includes data cleaning and correction queries.
================================================================================
*/


-- ============================================================================
-- SECTION 1: DATA EXPLORATION
-- Purpose: Establish reference CTEs for core tables
-- ============================================================================

-- 1.1 Unique water source types in the region
WITH Unique_water_source AS (
    SELECT DISTINCT type_of_water_source
    FROM md_water_services.water_source
),

-- 1.2 Employee data
Employee AS (
    SELECT * 
    FROM md_water_services.employee
),

-- 1.3 Location data
Location AS (
    SELECT * 
    FROM md_water_services.location
),

-- 1.4 Visits data
Visits AS (
    SELECT *
    FROM md_water_services.visits
),

-- 1.5 Water quality data
Water_quality AS (
    SELECT *
    FROM md_water_services.water_quality
),

-- 1.6 Water source data
Water_source AS (
    SELECT *
    FROM md_water_services.water_source
),

-- 1.7 Well pollution data
Well_pollution AS (
    SELECT *
    FROM md_water_services.well_pollution
),


-- ============================================================================
-- SECTION 2: QUEUE TIME ANALYSIS
-- Purpose: Identify high-traffic water sources with excessive wait times
-- Finding: Shared taps have the highest queue times
-- ============================================================================

Greater_than_500_mins_queue_time AS (
    SELECT
        record_id,
        location_id,
        source_id,
        time_in_queue,
        assigned_employee_id
    FROM md_water_services.visits
    WHERE visit_count > 1
      AND time_in_queue > 500
),


-- ============================================================================
-- SECTION 3: SOURCE TYPE VERIFICATION
-- Purpose: Cross-reference specific source IDs to verify water source types
-- ============================================================================

Selected_sourceId_sources AS (
    SELECT
        source_id,
        type_of_water_source,
        number_of_people_served
    FROM md_water_services.water_source
    WHERE source_id IN (
        'AkKi00881224', 
        'SoRu37635224', 
        'SoRu36096224', 
        'AkRu05234224', 
        'HaZa21742224'
    )
),


-- ============================================================================
-- SECTION 4: WATER QUALITY ASSESSMENT
-- Purpose: Analyze home taps with perfect quality scores requiring follow-ups
-- Criteria: Score = 10, Multiple visits, Tap-in-home sources
-- ============================================================================

Tap_in_home_water_quality AS (
    SELECT
        wq.record_id,
        ws.type_of_water_source,
        wq.subjective_quality_score,
        wq.visit_count
    FROM md_water_services.water_source AS ws
    LEFT JOIN Visits AS v
        ON ws.source_id = v.source_id
    LEFT JOIN Water_quality AS wq
        ON wq.record_id = v.record_id
    WHERE wq.subjective_quality_score = 10
      AND wq.visit_count > 1
      AND ws.type_of_water_source LIKE 'tap_in%'
),


-- ============================================================================
-- SECTION 5: DATA INTEGRITY AUDIT - POLLUTION RECORDS
-- Purpose: Identify misclassified pollution records
-- Issue: "Clean" results where biological > 0.01
-- Root Cause: Descriptions starting with "Clean" caused misclassification
-- ============================================================================

-- 5.1 Identify records marked clean despite contamination
Well_pollution_result_issue AS (
    SELECT
        source_id,
        description,
        pollutant_ppm,
        biological,
        results
    FROM Well_pollution
    WHERE results = 'Clean'
      AND biological > 0.01
),

-- 5.2 Confirm issue: Check for "Clean" prefix in descriptions
-- Result: 38 erroneous records identified
Well_pollution_issue_check AS (
    SELECT *
    FROM Well_pollution_result_issue
    WHERE description LIKE '%Clean%'
)


-- ============================================================================
-- SECTION 6: DATA CORRECTION
-- Purpose: Fix misclassified pollution records
-- WARNING: Uncomment UPDATE statement only after backup
-- ============================================================================

/*
-- CORRECTION QUERY (commented for safety)
-- Removes "Clean" prefix from descriptions
-- Updates results to "Contaminated: Biological" where biological > 0.01

UPDATE well_pollution
SET 
    description = CASE
        WHEN description = 'Clean Bacteria: Giardia Lamblia'
            THEN 'Bacteria: Giardia Lamblia'
        WHEN description = 'Clean Bacteria: E. coli'
            THEN 'Bacteria: E. coli'
        ELSE description
    END,
    results = CASE
        WHEN biological > 0.01
            THEN 'Contaminated: Biological'
        ELSE results
    END
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);
*/


-- ============================================================================
-- SECTION 7: VALIDATION
-- Purpose: Verify corrections have been applied
-- Expected: Zero rows returned after successful update
-- ============================================================================

SELECT
    source_id,
    description,
    pollutant_ppm,
    biological,
    results
FROM well_pollution
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);


-- ============================================================================
-- END OF ANALYSIS
-- ============================================================================
