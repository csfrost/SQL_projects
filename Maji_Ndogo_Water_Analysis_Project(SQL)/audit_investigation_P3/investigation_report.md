# 🔍 Investigation Report

## Data Integrity Audit - Maji Ndogo Water Services

**Report Date:** 2024  
**Auditor:** Tendai Mubarak, Chief Auditor  
**Analysis:** Data Analytics Team  
**Recipient:** President Aziza Naledi

---

## Executive Summary

An independent audit of the Maji Ndogo water services database has revealed evidence of potential data tampering by four field surveyors. While 94% of records were accurate, 102 discrepancies were identified, with a statistically significant concentration among four employees who also face bribery allegations from local residents.

### Key Findings

| Finding | Details |
|---------|---------|
| Sites Audited | 1,620 |
| Accurate Records | 1,518 (93.7%) |
| Discrepant Records | 102 (6.3%) |
| Employees with Errors | 17 |
| Suspects Identified | 4 |

---

## 1. Background

### 1.1 Audit Commission

Following concerns raised by the data team led by Chidi Kunto, President Naledi commissioned an independent audit of the water services database. The objective was to verify:

1. **Data Accuracy** - Are the recorded water quality scores correct?
2. **Data Integrity** - Has any data been tampered with?
3. **Source Verification** - Are water source classifications accurate?

### 1.2 Methodology

Chief Auditor Tendai Mubarak's team:
- Re-visited 1,620 water source locations
- Independently measured water quality scores
- Verified water source types
- Collected statements from local residents
- Compiled findings in a structured CSV report

---

## 2. Data Integration

### 2.1 Database Structure

The audit report was integrated using the following table relationships:

```
auditor_report
    │
    └──► visits (via location_id)
            │
            ├──► water_quality (via record_id)
            │
            └──► employee (via assigned_employee_id)
```

### 2.2 Technical Challenges

**Challenge:** The auditor used `location_id` while quality scores use `record_id`.

**Solution:** Used the `visits` table as a bridge, filtering on `visit_count = 1` to avoid duplicate entries.

---

## 3. Validation Results

### 3.1 Overall Accuracy

| Category | Count | Percentage |
|----------|-------|------------|
| Matching Scores | 1,518 | 93.7% |
| Non-Matching Scores | 102 | 6.3% |
| **Total Audited** | **1,620** | **100%** |

### 3.2 Source Type Verification

**Critical Finding:** Even for records with mismatched scores, the water source types matched perfectly between auditor and surveyor records.

**Implication:** Previous analyses based on source types remain valid. Only quality scores were manipulated.

### 3.3 Error Distribution

```
Number of Employees with Errors: 17
Total Errors: 102
Average Errors per Employee: 6

Distribution:
├── Bello Azibo:      26 ████████████████████████████ (25.5%)
├── Malachi Mavuso:   21 ███████████████████████ (20.6%)
├── Zuriel Matembo:   17 ██████████████████ (16.7%)
├── Lalitha Kaburi:    7 ████████ (6.9%)
├── Other 13 employees: 31 (combined) (30.4%)
```

---

## 4. Suspect Identification

### 4.1 Statistical Analysis

Using the criterion of **above-average errors**, four employees were flagged:

| Rank | Employee | Errors | vs Average |
|------|----------|--------|------------|
| 1 | Bello Azibo | 26 | +333% |
| 2 | Malachi Mavuso | 21 | +250% |
| 3 | Zuriel Matembo | 17 | +183% |
| 4 | Lalitha Kaburi | 7 | +17% |
| - | *Average* | *6* | *baseline* |

### 4.2 Query Used

```sql
WITH error_count AS (
    SELECT employee_name, COUNT(*) AS mistakes
    FROM Incorrect_records
    GROUP BY employee_name
)
SELECT employee_name, mistakes
FROM error_count
WHERE mistakes > (SELECT AVG(mistakes) FROM error_count);
```

---

## 5. Evidence Analysis

### 5.1 Statement Analysis

The auditor collected statements from local residents at each site. Analysis revealed a pattern:

**Keyword Search:** "cash"

| Employee | Statements Mentioning "cash" |
|----------|------------------------------|
| Bello Azibo | Multiple |
| Malachi Mavuso | Multiple |
| Zuriel Matembo | Multiple |
| Lalitha Kaburi | Multiple |
| **Other Employees** | **None** |

### 5.2 Critical Verification

**Query:** Are there ANY employees with "cash" allegations who are NOT in the suspect list?

```sql
SELECT * FROM Incorrect_records
WHERE statements LIKE '%cash%'
  AND employee_name NOT IN (SELECT employee_name FROM suspect_list);
```

**Result:** Empty set (0 rows)

**Conclusion:** Bribery allegations exist ONLY for the four identified suspects.

### 5.3 Score Manipulation Pattern

All 102 incorrect records share a common trait:

| Actual Score (Auditor) | Recorded Score (Surveyor) |
|------------------------|---------------------------|
| 1-9 (varies) | 10 (always maximum) |

**Implication:** Scores were systematically inflated to the maximum, not randomly altered.

---

## 6. Evidence Summary

### 6.1 Against Each Suspect

#### Bello Azibo
- ❌ 26 incorrect records (highest)
- ❌ Multiple "cash" allegations
- ❌ All scores inflated to 10

#### Malachi Mavuso
- ❌ 21 incorrect records
- ❌ Multiple "cash" allegations
- ❌ All scores inflated to 10

#### Zuriel Matembo
- ❌ 17 incorrect records
- ❌ Multiple "cash" allegations
- ❌ All scores inflated to 10

#### Lalitha Kaburi
- ❌ 7 incorrect records (above average)
- ❌ Multiple "cash" allegations
- ❌ All scores inflated to 10

### 6.2 Corroborating Factors

1. **Statistical Anomaly:** Error rates significantly above peers
2. **Exclusive Allegations:** Only suspects have "cash" mentions
3. **Consistent Pattern:** All inflated to maximum score
4. **Multiple Sources:** Independent resident statements corroborate

---

## 7. Conclusions

### 7.1 Findings

1. **Data Integrity Issue Confirmed:** 102 records were falsified
2. **Corruption Pattern Identified:** Four employees systematically inflated scores
3. **Bribery Allegations:** Witness statements suggest cash payments
4. **Limited Scope:** Source type data remains accurate and reliable

### 7.2 Confidence Level

| Evidence Type | Strength |
|---------------|----------|
| Statistical Analysis | Strong |
| Witness Statements | Moderate-Strong |
| Pattern Analysis | Strong |
| Exclusivity Test | Strong |
| **Overall Case** | **Strong** |

### 7.3 Limitations

- This is circumstantial evidence, not definitive proof
- Statements are unsworn accounts from anonymous residents
- Further investigation by appropriate authorities recommended

---

## 8. Recommendations

### 8.1 Immediate Actions

1. **Suspend Suspects:** Pending formal investigation
2. **Preserve Evidence:** Lock database access for suspects
3. **Formal Inquiry:** Refer to anti-corruption unit

### 8.2 Corrective Measures

1. **Data Correction:** Update 102 records with auditor's true scores
2. **Re-analysis:** Recalculate any metrics using quality scores
3. **Audit Trail:** Implement change logging for future modifications

### 8.3 Preventive Measures

1. **Dual Entry:** Require second surveyor verification for scores
2. **Random Audits:** Implement ongoing spot-check program
3. **Anomaly Detection:** Deploy statistical monitoring for unusual patterns

---

## 9. Appendix

### A. Sample Locations with Discrepancies

| Location ID | Auditor Score | Surveyor Score | Employee |
|-------------|---------------|----------------|----------|
| AkRu05215 | 3 | 10 | Rudo Imani |
| KiRu29290 | 3 | 10 | Bello Azibo |
| KiHa22748 | 9 | 10 | Bello Azibo |
| SoRu37841 | 6 | 10 | Rudo Imani |
| KiRu27884 | 1 | 10 | Bello Azibo |

### B. SQL Views Created

- `Incorrect_records` - All discrepant records with employee data
- `Employee_error_summary` - Error counts per employee
- `Suspect_employees` - Above-average error makers

### C. Files Delivered

- `01_create_auditor_table.sql` - Table creation script
- `02_audit_investigation.sql` - Complete analysis queries
- `03_create_views.sql` - Reusable view definitions

---

**Report Prepared By:** Data Analytics Team  
**Reviewed By:** Chidi Kunto, Data Team Lead  
**Submitted To:** President Aziza Naledi

---

*"Accountability is not a burden—it is a gift we give to the people we serve."*  
— President Aziza Naledi
