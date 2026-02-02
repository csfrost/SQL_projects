# 📖 Data Dictionary

## Overview

This document provides detailed descriptions of all tables and fields in the `md_water_services` database used for the Clustering Water Crisis Analysis.

---

## Tables

### 1. `employee`

Field staff information and contact details.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `assigned_employee_id` | INT | Primary key - unique employee identifier |
| `employee_name` | VARCHAR | Employee's full name |
| `phone_number` | VARCHAR | Contact phone number (12 characters after cleaning) |
| `email` | VARCHAR | Email address (format: first.last@ndogowater.gov) |
| `province_name` | VARCHAR | Province where employee is assigned |
| `town_name` | VARCHAR | Town where employee is based |

**Data Cleaning Applied:**
- Email generated using: `CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov')`
- Phone numbers trimmed to remove trailing spaces

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

**Key Statistics:**
- Rural: 60% of all records
- Urban: 40% of all records

---

### 3. `visits`

Records of field visits to water sources.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `record_id` | INT | Primary key - unique visit record |
| `location_id` | INT | FK → location table |
| `source_id` | VARCHAR | FK → water_source table |
| `time_of_record` | DATETIME | Timestamp of visit |
| `visit_count` | INT | Number of visits to this source |
| `time_in_queue` | INT | Queue time in minutes (0 for home taps) |
| `assigned_employee_id` | INT | FK → employee table |

**Key Statistics:**
- Survey duration: 924 days (2021-2023)
- Average queue time: 123 minutes (excluding zeros)

---

### 4. `water_source`

Information about water sources and capacity.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `source_id` | VARCHAR | Primary key - unique source identifier |
| `type_of_water_source` | VARCHAR | Classification of water source |
| `number_of_people_served` | INT | Population dependent on source |

**Water Source Types:**

| Type | % Population | Avg People/Source | Notes |
|------|-------------|-------------------|-------|
| `shared_tap` | 43% | 2,071 | Highest priority |
| `well` | 18% | 279 | Only 28% are clean |
| `tap_in_home` | 17% | 644* | *Represents ~100 taps (grouped households) |
| `tap_in_home_broken` | 14% | - | Infrastructure issues |
| `river` | 9% | 699 | Needs permanent solution |

---

### 5. `water_quality`

Subjective quality assessments from field visits.

| Field | Data Type | Description |
|-------|-----------|-------------|
| `record_id` | INT | PK/FK → links to visits table |
| `subjective_quality_score` | INT | Quality rating (1-10, 10 = best) |
| `visit_count` | INT | Visit number when assessed |

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

| Value | Meaning | Solution |
|-------|---------|----------|
| `Clean` | Safe (biological ≤ 0.01) | No action needed |
| `Contaminated: Biological` | Biological contamination | Install UV filters |
| `Contaminated: Chemical` | Chemical contamination | Install reverse osmosis |

---

## Key Relationships

```
employee.assigned_employee_id ←── visits.assigned_employee_id
location.location_id ←───────── visits.location_id
water_source.source_id ←─────── visits.source_id
water_source.source_id ←─────── well_pollution.source_id
visits.record_id ←────────────── water_quality.record_id
```

---

## DateTime Functions Used

| Function | Purpose | Example |
|----------|---------|---------|
| `DAYNAME()` | Extract day name | Returns 'Monday', 'Tuesday', etc. |
| `TIME_FORMAT()` | Format time display | `'%H:00'` → '06:00', '07:00' |
| `DATEDIFF()` | Calculate date difference | Survey duration in days |
| `DATE()` | Extract date from datetime | Survey start/end dates |

---

## Window Functions Used

| Function | Purpose |
|----------|---------|
| `RANK()` | Ranking with gaps for ties |
| `DENSE_RANK()` | Ranking without gaps |
| `ROW_NUMBER()` | Unique sequential numbers |
| `SUM() OVER()` | Running totals for percentages |

---

## Queue Time Patterns

### By Day of Week

| Day | Avg Queue (min) | Interpretation |
|-----|-----------------|----------------|
| Saturday | 246 | Weekly supply collection |
| Monday | 137 | Post-weekend rush |
| Friday | 120 | Pre-weekend preparation |
| Tuesday | 108 | Normal weekday |
| Thursday | 105 | Normal weekday |
| Wednesday | 97 | Mid-week low |
| Sunday | 82 | Cultural/family day |

### By Hour of Day

| Time Period | Queue Pattern |
|-------------|---------------|
| 06:00 - 08:00 | Morning rush (high) |
| 09:00 - 15:00 | Mid-day (moderate) |
| 16:00 - 19:00 | Evening rush (high) |

---

*Last Updated: 2025*
