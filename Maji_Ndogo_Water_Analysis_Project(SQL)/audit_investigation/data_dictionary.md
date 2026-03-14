# 📖 Data Dictionary

## Maji Ndogo Audit Investigation

This document describes all tables, views, and fields used in the audit investigation analysis.

---

## 📊 Tables

### 1. auditor_report (NEW)

Independent audit results from Chief Auditor Tendai Mubarak.

| Field | Type | Description |
|-------|------|-------------|
| `location_id` | VARCHAR(32) | Unique identifier linking to location and visits tables |
| `type_of_water_source` | VARCHAR(64) | Water source type verified by auditor |
| `true_water_source_score` | INT | Independent quality score (0-10 scale) |
| `statements` | VARCHAR(255) | Statements collected from local residents |

**Statistics:**
- Total Records: 1,620 locations revisited
- Matching with surveyors: 1,518 (94%)
- Discrepancies: 102 (6%)

---

### 2. visits

Central table logging all site visits by surveyors.

| Field | Type | Description |
|-------|------|-------------|
| `record_id` | INT (PK) | Unique identifier for each visit |
| `location_id` | VARCHAR(32) (FK) | Links to location table |
| `source_id` | VARCHAR(32) (FK) | Links to water_source table |
| `assigned_employee_id` | INT (FK) | Links to employee table |
| `visit_count` | INT | Number indicating which visit (1st, 2nd, etc.) |
| `time_of_record` | DATETIME | When the visit occurred |

**Key Relationships:**
- `location_id` → `location.location_id`
- `source_id` → `water_source.source_id`
- `assigned_employee_id` → `employee.assigned_employee_id`
- `record_id` → `water_quality.record_id` (1:1)

---

### 3. water_quality

Water quality scores recorded by surveyors.

| Field | Type | Description |
|-------|------|-------------|
| `record_id` | INT (FK) | Links to visits table (1:1 relationship) |
| `subjective_quality_score` | INT | Surveyor's quality assessment (0-10 scale) |
| `visit_count` | INT | Visit number for this record |

**Relationship with visits:**
- One-to-One: Each visit has exactly one quality record

---

### 4. employee

Employee/surveyor information.

| Field | Type | Description |
|-------|------|-------------|
| `assigned_employee_id` | INT (PK) | Unique employee identifier |
| `employee_name` | VARCHAR(100) | Full name of employee |
| `phone_number` | VARCHAR(15) | Contact number |
| `email` | VARCHAR(100) | Email address |
| `address` | VARCHAR(200) | Physical address |
| `town_name` | VARCHAR(50) | Town where employee is based |
| `province_name` | VARCHAR(50) | Province assignment |
| `position` | VARCHAR(50) | Job title |

---

### 5. water_source

Details about each water source.

| Field | Type | Description |
|-------|------|-------------|
| `source_id` | VARCHAR(32) (PK) | Unique source identifier |
| `type_of_water_source` | VARCHAR(64) | Category: well, tap_in_home, shared_tap, etc. |
| `number_of_people_served` | INT | Population dependent on this source |

---

### 6. location

Geographic information for each site.

| Field | Type | Description |
|-------|------|-------------|
| `location_id` | VARCHAR(32) (PK) | Unique location identifier |
| `province_name` | VARCHAR(50) | Province name |
| `town_name` | VARCHAR(50) | Town name |
| `location_type` | VARCHAR(20) | Urban or Rural |
| `address` | VARCHAR(200) | Specific address |

---

## 👁️ Views

### 1. Incorrect_records

Records where auditor and surveyor scores don't match.

| Field | Source | Description |
|-------|--------|-------------|
| `location_id` | auditor_report | Location identifier |
| `record_id` | visits | Visit record identifier |
| `surveyor_name` | employee | Name of surveyor who made the error |
| `auditor_score` | auditor_report | Independent auditor's score |
| `surveyor_score` | water_quality | Original surveyor's score |
| `auditor_source_type` | auditor_report | Verified water source type |
| `auditor_statement` | auditor_report | Local resident statements |

**Filter Conditions:**
- `visit_count = 1` (first visits only)
- `auditor_score <> surveyor_score` (mismatches)

**Row Count:** 102 records

---

### 2. Employee_error_summary

Aggregated error statistics by employee.

| Field | Description |
|-------|-------------|
| `surveyor_name` | Employee name |
| `number_of_mistakes` | Count of incorrect records |
| `average_mistakes` | Average mistakes across all employees (window function) |

**Row Count:** 17 employees with at least one error

---

### 3. Suspect_employees

Employees with above-average error rates.

| Field | Description |
|-------|-------------|
| `surveyor_name` | Employee name |
| `number_of_mistakes` | Their error count |
| `average_mistakes` | Baseline average for comparison |

**Row Count:** 4 suspects identified

---

## 🔍 Quality Score Scale

The water quality scoring system uses a 0-10 scale:

| Score | Quality Level | Description |
|-------|--------------|-------------|
| 0 | Completely Unsafe | Severely contaminated |
| 1-3 | Poor | Significant issues |
| 4-6 | Moderate | Some concerns |
| 7-9 | Good | Minor issues only |
| 10 | Excellent | Clean, safe water |

**Key Finding:** All incorrect scores were inflated TO 10, suggesting deliberate falsification.

---

## 👤 Suspected Employees

| Name | Mistakes | Evidence |
|------|----------|----------|
| **Bello Azibo** | 26 | Multiple "cash" statements |
| **Malachi Mavuso** | 21 | Multiple "cash" statements |
| **Zuriel Matembo** | 17 | Multiple "cash" statements |
| **Lalitha Kaburi** | 7 | Multiple "cash" statements |

**Average mistakes:** ~6 per employee with errors

---

## 📎 Important Notes

### Visit Count Logic
Many locations were visited multiple times. To avoid counting duplicates:
```sql
WHERE visit_count = 1
```
This ensures we only compare first-visit records.

### Score Comparison
The auditor's `true_water_source_score` is compared against the surveyor's `subjective_quality_score`. Differences indicate either:
1. Honest human error
2. Deliberate falsification

### Statement Analysis
The `statements` field contains narratives from local residents. Keywords like "cash" indicate potential bribery allegations.

---

## 🔗 Join Paths

### Auditor Report to Water Quality
```
auditor_report.location_id 
    → visits.location_id
        → visits.record_id 
            → water_quality.record_id
```

### Auditor Report to Employee
```
auditor_report.location_id 
    → visits.location_id
        → visits.assigned_employee_id 
            → employee.assigned_employee_id
```

### Complete Investigation Join
```sql
FROM auditor_report AS ar
JOIN visits AS v ON ar.location_id = v.location_id
JOIN water_quality AS wq ON v.record_id = wq.record_id
JOIN employee AS e ON e.assigned_employee_id = v.assigned_employee_id
```
