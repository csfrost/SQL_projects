-- ============================================================================
-- MAJI NDOGO WATER CRISIS PROJECT
-- Part 4C: Project Progress — From Analysis to Action
-- ============================================================================
-- Author:       [Your Name]
-- Database:     md_water_services
-- Description:  Creates the Project_progress table and populates it with
--               data-driven improvement tasks for engineering teams.
--               Each row represents a water source that needs intervention,
--               complete with address, source type, and a specific action.
-- ============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- STEP 1: Create the Project_progress Table
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Design choices:
--   • source_id is a foreign key to water_source for referential integrity.
--   • Source_status defaults to 'Backlog' and is constrained to three values
--     to keep engineer updates clean and consistent.
--   • Comments uses TEXT (unlimited length) for detailed field notes.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE Project_progress (
    Project_id          SERIAL PRIMARY KEY,
    source_id           VARCHAR(20)  NOT NULL
                        REFERENCES water_source(source_id)
                        ON DELETE CASCADE ON UPDATE CASCADE,
    Address             VARCHAR(50),
    Town                VARCHAR(30),
    Province            VARCHAR(30),
    Source_type         VARCHAR(50),
    Improvement         VARCHAR(50),
    Source_status       VARCHAR(50)  DEFAULT 'Backlog'
                        CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
    Date_of_completion  DATE,
    Comments            TEXT
);


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- STEP 2: Populate the Table with Improvement Tasks
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Improvement logic (mirrors the flowchart in the project slides):
--
--   Source Type          | Condition                    | Improvement
--   ---------------------|------------------------------|---------------------------
--   well                 | Contaminated: Chemical       | Install RO filter
--   well                 | Contaminated: Biological     | Install UV and RO filter
--   river                | —                            | Drill well
--   shared_tap           | queue >= 30 min              | Install <X> taps nearby
--   tap_in_home_broken   | —                            | Diagnose local infrastructure
--
-- Filters applied (WHERE clause):
--   1. visit_count = 1   (avoid duplicates)
--   2. Exclude clean wells, working home taps, and short-queue shared taps
--
-- Expected result: 25,398 rows
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

INSERT INTO Project_progress (source_id, Address, Town, Province, Source_type, Improvement)
SELECT
    water_source.source_id,
    location.address,
    location.town_name,
    location.province_name,
    water_source.type_of_water_source,
    CASE
        WHEN well_pollution.results = 'Contaminated: Chemical'
            THEN 'Install RO filter'
        WHEN well_pollution.results = 'Contaminated: Biological'
            THEN 'Install UV and RO filter'
        WHEN water_source.type_of_water_source = 'river'
            THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'shared_tap'
             AND visits.time_in_queue >= 30
            THEN CONCAT('Install ', FLOOR(visits.time_in_queue / 30), ' taps nearby')
        WHEN water_source.type_of_water_source = 'tap_in_home_broken'
            THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM
    water_source
LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits         ON water_source.source_id = visits.source_id
INNER JOIN
    location       ON location.location_id   = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        well_pollution.results != 'Clean'
        OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap'
            AND visits.time_in_queue >= 30)
    );
