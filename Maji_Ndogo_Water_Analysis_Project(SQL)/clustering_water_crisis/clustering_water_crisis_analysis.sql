/*
================================================================================
 CLUSTERING DATA TO UNVEIL MAJI NDOGO'S WATER CRISIS
================================================================================
 Project:     Maji Ndogo Water Infrastructure Analysis - Part 2
 Database:    md_water_services
 Author:      csfrost
 Repository:  https://github.com/csfrost/clustering_water_crisis
 
 Description: Advanced SQL analysis that clusters and aggregates water 
              infrastructure data to reveal patterns, optimize queue times,
              and develop practical solutions for Maji Ndogo's water crisis.
              
 Key Topics:  Data Cleaning, Employee Analysis, Location Analysis,
              Water Source Evaluation, Queue Time Optimization, Window Functions
================================================================================
*/


-- ============================================================================
-- SECTION 1: DATA CLEANING - Employee Information
-- Purpose: Standardize employee contact information for communication
-- ============================================================================

-- 1.1 Generate standardized email addresses
-- Format: first.last@ndogowater.gov
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');


-- 1.2 Identify phone number formatting issues
-- Problem: Phone numbers have trailing spaces (13 chars instead of 12)
SELECT
    phone_number,
    LENGTH(phone_number) AS current_length,
    LENGTH(TRIM(phone_number)) AS correct_length
FROM
    employee;


-- 1.3 Fix phone number formatting
UPDATE employee
SET phone_number = TRIM(phone_number);


-- ============================================================================
-- SECTION 2: EMPLOYEE ANALYSIS - Honouring the Workers
-- Purpose: Identify top performing field surveyors
-- ============================================================================

-- 2.1 Count employees per town (with province differentiation for same-named towns)
SELECT
    province_name,
    town_name,
    COUNT(assigned_employee_id) AS employees_per_town
FROM
    employee
GROUP BY
    province_name,
    town_name;


-- 2.2 Find top 3 employees with most location visits
-- Uses CTE with window function for ranking
WITH Top_visiting_employees AS (
    SELECT
        assigned_employee_id,
        COUNT(visit_count) AS number_of_visits,
        DENSE_RANK() OVER (ORDER BY COUNT(visit_count) DESC) AS rank_position
    FROM
        visits
    GROUP BY
        assigned_employee_id
    LIMIT 3
)
-- Extract contact information for top performers
SELECT
    t.assigned_employee_id,
    e.employee_name,
    e.phone_number,
    e.email,
    t.number_of_visits
FROM
    Top_visiting_employees AS t
JOIN
    employee AS e
    ON t.assigned_employee_id = e.assigned_employee_id;
-- Result: Top 3 are 'Bello Azibo', 'Pili Zola', 'Rudo Imani'


-- ============================================================================
-- SECTION 3: LOCATION ANALYSIS - Geographic Distribution
-- Purpose: Understand where water sources are located
-- ============================================================================

-- 3.1 Count records per town and province
SELECT
    province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM
    location
GROUP BY
    province_name,
    town_name
ORDER BY
    province_name,
    records_per_town DESC;


-- 3.2 Analyze urban vs rural distribution
-- Finding: Rural = 60%, Urban = 40%
WITH location_type_record AS (
    SELECT
        location_type,
        COUNT(location_type) AS records_per_location,
        SUM(COUNT(location_type)) OVER () AS total_records
    FROM
        location
    GROUP BY
        location_type
)
SELECT
    location_type,
    records_per_location,
    ROUND(records_per_location * 100 / total_records) AS pct_records_per_location
FROM
    location_type_record;


-- ============================================================================
-- SECTION 4: WATER SOURCE ANALYSIS - Scope of the Problem
-- Purpose: Quantify the water crisis across different source types
-- ============================================================================

-- 4.1 Total surveyed population
SELECT
    SUM(number_of_people_served) AS total_people_served
FROM
    water_source;
-- Result: ~27 million citizens


-- 4.2 Count water sources by type with average people served
SELECT
    type_of_water_source,
    COUNT(type_of_water_source) AS number_of_sources,
    ROUND(AVG(number_of_people_served)) AS avg_people_served
FROM
    water_source
GROUP BY
    type_of_water_source
ORDER BY
    number_of_sources DESC;


-- 4.3 Average people served per source type
-- Note: tap_in_home shows 644 but actually represents ~100 taps (644/6 people per home)
SELECT
    type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS avg_people_per_source
FROM
    water_source
GROUP BY
    type_of_water_source
ORDER BY
    avg_people_per_source DESC;
-- Finding: Shared tap averages 2000 persons/tap


-- 4.4 Population percentage and ranking by water source type
SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS people_served,
    ROUND(
        SUM(number_of_people_served) * 100 / SUM(SUM(number_of_people_served)) OVER()
    ) AS pct_population,
    RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS rank_by_population
FROM
    water_source
GROUP BY
    type_of_water_source
ORDER BY
    people_served DESC;
-- Finding: Shared tap serves 43% of population


-- 4.5 Priority ranking for each source_id
SELECT
    source_id,
    type_of_water_source,
    SUM(number_of_people_served) AS people_served,
    DENSE_RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS priority_rank
FROM
    water_source
GROUP BY
    source_id,
    type_of_water_source
ORDER BY
    people_served DESC;


-- ============================================================================
-- SECTION 5: SURVEY TIMELINE ANALYSIS
-- Purpose: Understand the scope and duration of data collection
-- ============================================================================

-- 5.1 Calculate survey duration
SELECT
    MIN(DATE(time_of_record)) AS survey_start_date,
    MAX(DATE(time_of_record)) AS survey_end_date,
    DATEDIFF(MAX(DATE(time_of_record)), MIN(DATE(time_of_record))) AS survey_duration_days
FROM
    visits;
-- Result: Survey lasted 924 days (~2.5 years), from 2021 to 2023


-- ============================================================================
-- SECTION 6: QUEUE TIME ANALYSIS
-- Purpose: Analyze when citizens collect water to optimize solutions
-- ============================================================================

-- 6.1 Average overall queue time (excluding zero queue times)
SELECT
    ROUND(AVG(NULLIF(time_in_queue, 0))) AS avg_queue_time_minutes
FROM
    visits;
-- Result: Average queue time is 123 minutes


-- 6.2 Average queue time by day of week
SELECT
    DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(NULLIF(time_in_queue, 0))) AS avg_queue_time
FROM
    visits
GROUP BY
    day_of_week
ORDER BY
    avg_queue_time DESC;
-- Finding: Saturdays have longest queues (246 min), Sundays shortest (82 min)


-- 6.3 Average queue time by hour of day
SELECT
    TIME_FORMAT(time_of_record, '%H:00') AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue, 0))) AS avg_queue_time
FROM
    visits
GROUP BY
    hour_of_day
ORDER BY
    avg_queue_time DESC;
-- Finding: Peak times are 5pm-7pm and 6am-8am


-- 6.4 PIVOT TABLE: Queue times by hour and day of week
-- Creates a comprehensive view of queue patterns
SELECT
    TIME_FORMAT(time_of_record, '%H:00') AS hour_of_day,
    
    -- Sunday
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Sunday'
        THEN time_in_queue
        ELSE NULL
    END), 0) AS 'Sunday',
    
    -- Monday
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Monday'
        THEN time_in_queue
        ELSE NULL
    END), 0) AS 'Monday',
    
    -- Tuesday
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Tuesday'
        THEN time_in_queue
        ELSE NULL
    END), 0) AS 'Tuesday',
    
    -- Wednesday
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Wednesday'
        THEN time_in_queue
        ELSE NULL
    END), 0) AS 'Wednesday',
    
    -- Thursday
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Thursday'
        THEN time_in_queue
        ELSE NULL
    END), 0) AS 'Thursday',
    
    -- Friday
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Friday'
        THEN time_in_queue
        ELSE NULL
    END), 0) AS 'Friday',
    
    -- Saturday
    ROUND(AVG(CASE
        WHEN DAYNAME(time_of_record) = 'Saturday'
        THEN time_in_queue
        ELSE NULL
    END), 0) AS 'Saturday'
    
FROM
    visits
WHERE 
    time_in_queue <> 0  -- Excludes sources with zero queue times
GROUP BY
    hour_of_day
ORDER BY
    hour_of_day;

/*
PIVOT TABLE INSIGHTS:
1. Monday mornings and evenings have very long queues (people rush for water)
2. Wednesday has lowest weekday queues, but long evening queues
3. Saturday queues are ~2x longer than weekdays (weekly supply collection)
4. Sunday has shortest queues (cultural/family day in Maji Ndogo)
*/


-- ============================================================================
-- SECTION 7: SUMMARY INSIGHTS
-- ============================================================================

/*
================================================================================
WATER ACCESSIBILITY AND INFRASTRUCTURE SUMMARY REPORT
================================================================================

KEY INSIGHTS:
-------------
1. Most water sources are rural (60%)

2. 43% of population uses shared taps
   - Average 2,000 people share one tap
   
3. 31% have home water infrastructure
   - BUT 45% of these systems are non-functional (broken pipes, pumps, reservoirs)
   
4. 18% use wells
   - Only 28% of wells are clean (4,916 of 17,383)
   
5. Average queue time: 120+ minutes

6. Queue patterns:
   - Saturdays: Very long queues
   - Mornings/Evenings: Peak times
   - Wednesdays/Sundays: Shortest queues


PROPOSED ACTION PLAN:
---------------------
1. Focus on improvements affecting most people:
   - Priority 1: Improve shared taps first (43% impact)
   - Priority 2: Fix contaminated wells (18% impact)
   - Priority 3: Repair broken infrastructure (14% impact)
   - Priority 4: Low queue time sources - defer for now

2. Rural focus required:
   - 60% of sources are rural
   - Teams need to prepare for challenging road conditions
   - Supply and labor logistics more difficult


PRACTICAL SOLUTIONS:
--------------------
1. RIVERS: Deploy water trucks temporarily + drill wells for permanent solution

2. WELLS:
   - Biological contamination → Install UV filters
   - Chemical pollution → Install reverse osmosis filters
   - Long-term: Investigate pollution sources

3. SHARED TAPS:
   - Short-term: Send tankers during peak times (use pivot table data)
   - Long-term: Install additional taps to get queue times < 30 min (UN standard)

4. BROKEN INFRASTRUCTURE:
   - High impact per repair (one fix benefits many)
   - Identify commonly affected areas
   - Fix reservoirs and pipes serving multiple taps

================================================================================
*/


-- ============================================================================
-- END OF ANALYSIS
-- ============================================================================
