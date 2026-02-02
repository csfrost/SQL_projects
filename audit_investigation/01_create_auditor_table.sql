/*
================================================================================
 CREATE AUDITOR REPORT TABLE
 Maji Ndogo Audit Investigation - Part 3
================================================================================

 PURPOSE:
 Creates the auditor_report table to store results from the independent
 audit conducted by Chief Auditor Tendai Mubarak.
 
 USAGE:
 1. Run this script first
 2. Import the Auditor_report.csv file using MySQL Workbench's 
    Table Data Import Wizard or LOAD DATA INFILE
 
================================================================================
*/

USE md_water_services;

-- Drop existing table if it exists (for clean re-runs)
DROP TABLE IF EXISTS `auditor_report`;

-- Create the auditor_report table
CREATE TABLE `auditor_report` (
    `location_id` VARCHAR(32) COMMENT 'Links to visits.location_id and location.location_id',
    `type_of_water_source` VARCHAR(64) COMMENT 'Water source type as verified by auditor',
    `true_water_source_score` INT DEFAULT NULL COMMENT 'Independent quality score (0-10)',
    `statements` VARCHAR(255) COMMENT 'Statements collected from local residents'
) COMMENT = 'Independent audit results from Chief Auditor Tendai Mubarak - 1620 sites revisited';

-- Verify table creation
DESCRIBE auditor_report;

-- After importing CSV, run this to verify data
-- SELECT COUNT(*) FROM auditor_report; -- Should return 1620

/*
 IMPORT INSTRUCTIONS:
 
 Option 1: MySQL Workbench GUI
 ─────────────────────────────
 1. Right-click on the auditor_report table in the Navigator
 2. Select "Table Data Import Wizard"
 3. Browse to Auditor_report.csv
 4. Follow the wizard, ensuring columns map correctly
 5. Click "Next" and "Finish"
 
 Option 2: LOAD DATA INFILE (Command Line)
 ─────────────────────────────────────────
 LOAD DATA INFILE '/path/to/Auditor_report.csv'
 INTO TABLE auditor_report
 FIELDS TERMINATED BY ','
 OPTIONALLY ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS
 (location_id, type_of_water_source, true_water_source_score, statements);
 
 Option 3: LOAD DATA LOCAL INFILE
 ────────────────────────────────
 If the file is on your local machine (not the server):
 LOAD DATA LOCAL INFILE '/path/to/Auditor_report.csv'
 INTO TABLE auditor_report
 FIELDS TERMINATED BY ','
 OPTIONALLY ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 ROWS;
*/
