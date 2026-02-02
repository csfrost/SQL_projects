-- ============================================================================
-- MAJI NDOGO WATER CRISIS PROJECT
-- Part 4A: Combined Analysis View — Joining Pieces Together
-- ============================================================================
-- Author:       [Your Name]
-- Database:     md_water_services
-- Tools:        MySQL 8.0+
-- Description:  Assembles data from location, water_source, visits, and
--               well_pollution into a single view for streamlined analysis.
--               This view serves as the foundation for all downstream
--               provincial and town-level pivot analyses.
-- ============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- COMBINED ANALYSIS VIEW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Key design decisions:
--   • visits is the anchor table — it maps source_id ↔ location_id.
--   • well_pollution uses LEFT JOIN because it only contains data for wells;
--     non-well sources will have NULL in the results column.
--   • Filtered to visit_count = 1 to avoid double-counting locations that
--     received multiple surveyor visits.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE VIEW combined_analysis_table AS
SELECT
    water_source.type_of_water_source   AS source_type,
    location.town_name,
    location.province_name,
    location.location_type,
    water_source.number_of_people_served AS people_served,
    visits.time_in_queue,
    well_pollution.results
FROM
    visits
LEFT JOIN
    well_pollution ON well_pollution.source_id = visits.source_id
INNER JOIN
    location       ON location.location_id     = visits.location_id
INNER JOIN
    water_source   ON water_source.source_id   = visits.source_id
WHERE
    visits.visit_count = 1;
