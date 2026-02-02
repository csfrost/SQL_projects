# 📖 Data Dictionary

## Overview

This document provides detailed descriptions of all tables and fields in the `md_water_services` database.

---

## Tables

### 1. `employee`

Field staff information and assignments.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `employee_id` | INT | Primary key - unique employee identifier |
| `name` | VARCHAR | Employee's full name |
| `phone_number` | VARCHAR | Contact phone number |
| `email` | VARCHAR | Email address |
| `position` | VARCHAR | Job title/role |
| `province` | VARCHAR | Assigned province |
| `town` | VARCHAR | Base location |

---

### 2. `location`

Geographic information for water source locations.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `location_id` | INT | Primary key - unique location identifier |
| `address` | VARCHAR | Street address or description |
| `province_name` | VARCHAR | Province name |
| `town_name` | VARCHAR | Town name |
| `location_type` | VARCHAR | Urban or Rural classification |

---

### 3. `visits`

Records of field visits to water sources.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `record_id` | INT | Primary key - unique visit record |
| `location_id` | INT | FK → location table |
| `source_id` | VARCHAR | FK → water_source table |
| `visit_count` | INT | Number of visits to this source |
| `time_in_queue` | INT | Queue time in minutes |
| `assigned_employee_id` | INT | FK → employee table |
| `visit_date` | DATE | Date of visit |

---

### 4. `water_quality`

Subjective quality assessments from field visits.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `record_id` | INT | PK/FK → links to visits table |
| `subjective_quality_score` | INT | Quality rating (1-10, 10 = best) |
| `visit_count` | INT | Visit number when assessed |

---

### 5. `water_source`

Information about water sources and capacity.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `source_id` | VARCHAR | Primary key - unique source identifier |
| `type_of_water_source` | VARCHAR | Classification of water source |
| `number_of_people_served` | INT | Population dependent on source |

**Water Source Types:**

| Type | Description | Risk Level |
|------|-------------|------------|
| `tap_in_home` | Private residential tap | Low |
| `tap_in_home_broken` | Non-functional private tap | High |
| `shared_tap` | Community water point | Medium |
| `well` | Groundwater source | Medium |
| `river` | Surface water | High |

---

### 6. `well_pollution`

Pollution test results for well sources.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `source_id` | VARCHAR | FK → water_source table |
| `description` | VARCHAR | Description of contaminants |
| `pollutant_ppm` | DECIMAL | Chemical pollutant level (ppm) |
| `biological` | DECIMAL | Biological contamination level |
| `results` | VARCHAR | Overall classification |

**Results Classification:**

| Value | Meaning | Threshold |
|-------|---------|-----------|
| `Clean` | Safe for consumption | biological ≤ 0.01 |
| `Contaminated: Biological` | Biological contamination | biological > 0.01 |
| `Contaminated: Chemical` | Chemical contamination | Based on pollutant_ppm |

---

## Source ID Format

Source IDs follow the pattern: `[Province][Town][Number][Type]`

**Example:** `AkKi00881224`
- `Ak` - Province code
- `Ki` - Town code  
- `00881` - Sequential number
- `224` - Type identifier

---

## Data Quality Notes

### Known Issue: Pollution Misclassification

**Affected Records:** 38

**Problem:** Records with `biological > 0.01` were incorrectly marked as "Clean" when the description field started with the word "Clean".

**Examples:**
- "Clean Bacteria: Giardia Lamblia" → Should be "Bacteria: Giardia Lamblia"
- "Clean Bacteria: E. coli" → Should be "Bacteria: E. coli"

---

*Last Updated: 2025*
