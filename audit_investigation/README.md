# 🔍 Maji Ndogo Audit Investigation

![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue?style=flat&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange?style=flat)
![Status](https://img.shields.io/badge/Status-Completed-success)
![License](https://img.shields.io/badge/License-MIT-green)

> **Part 3 of the Maji Ndogo Water Crisis Analysis Series**  
> Weaving the data threads of Maji Ndogo's narrative - From analysis to action

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Background Story](#-background-story)
- [Database Schema](#-database-schema)
- [Analysis Workflow](#-analysis-workflow)
- [Key Findings](#-key-findings)
- [SQL Techniques Used](#-sql-techniques-used)
- [Repository Structure](#-repository-structure)
- [Setup Instructions](#-setup-instructions)
- [Related Projects](#-related-projects)

---

## 🎯 Project Overview

This project integrates an independent auditor's report into the Maji Ndogo water services database to verify data integrity. Through systematic SQL analysis, we compare surveyor scores against auditor findings to identify discrepancies and investigate potential data tampering or corruption.

### Objectives

1. **Integrate External Data** - Import and link the auditor's CSV report to existing database tables
2. **Validate Data Integrity** - Compare surveyor scores with independent auditor scores
3. **Identify Discrepancies** - Find records where scores don't match (102 out of 1,620)
4. **Investigate Patterns** - Determine if discrepancies are random errors or systematic
5. **Gather Evidence** - Build a case using statistical analysis and witness statements

---

## 📖 Background Story

Following inconsistencies identified by the data team, President Aziza Naledi commissioned an independent audit of the Maji Ndogo water project database. Chief Auditor **Tendai Mubarak** re-visited 1,620 water source locations, independently measuring water quality scores and collecting statements from local residents.

The audit revealed:
- **94% accuracy** (1,518 of 1,620 records matched)
- **102 incorrect records** requiring investigation
- **4 employees** with statistically anomalous error rates
- **Incriminating statements** mentioning "cash" payments

---

## 🗄️ Database Schema

### Entity Relationship Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    employee     │     │     visits      │     │    location     │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ assigned_       │◄────│ assigned_       │────►│ location_id     │
│ employee_id (PK)│     │ employee_id (FK)│     │ (PK)            │
│ employee_name   │     │ location_id (FK)│     │ province_name   │
│ phone_number    │     │ source_id (FK)  │     │ town_name       │
│ email           │     │ record_id (PK)  │     │ location_type   │
└─────────────────┘     │ visit_count     │     └─────────────────┘
                        │ time_of_record  │
                        └────────┬────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
        ▼                        ▼                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  water_source   │     │ water_quality   │     │ auditor_report  │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ source_id (PK)  │     │ record_id (FK)  │     │ location_id     │
│ type_of_water_  │     │ subjective_     │     │ type_of_water_  │
│ source          │     │ quality_score   │     │ source          │
│ number_of_      │     │ visit_count     │     │ true_water_     │
│ people_served   │     └─────────────────┘     │ source_score    │
└─────────────────┘              ▲              │ statements      │
                                 │              └─────────────────┘
                                 │
                        ┌────────┴────────┐
                        │  One-to-One     │
                        │  Relationship   │
                        └─────────────────┘
```

### Auditor Report Table Structure

```sql
CREATE TABLE `auditor_report` (
    `location_id` VARCHAR(32),
    `type_of_water_source` VARCHAR(64),
    `true_water_source_score` INT DEFAULT NULL,
    `statements` VARCHAR(255)
);
```

---

## 🔄 Analysis Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│                    AUDIT INVESTIGATION PIPELINE                   │
└──────────────────────────────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│ 1. GENERATE   │      │ 2. INTEGRATE  │      │ 3. LINK       │
│    ERD        │ ───► │    REPORT     │ ───► │    RECORDS    │
│               │      │               │      │               │
│ Understand    │      │ Import CSV    │      │ JOIN tables   │
│ relationships │      │ Create table  │      │ via visits    │
└───────────────┘      └───────────────┘      └───────────────┘
                                                      │
        ┌─────────────────────────────────────────────┘
        ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│ 4. COMPARE    │      │ 5. IDENTIFY   │      │ 6. GATHER     │
│    SCORES     │ ───► │    SUSPECTS   │ ───► │    EVIDENCE   │
│               │      │               │      │               │
│ Find 102      │      │ Above-average │      │ Filter "cash" │
│ mismatches    │      │ error rates   │      │ statements    │
└───────────────┘      └───────────────┘      └───────────────┘
```

---

## 📊 Key Findings

### Audit Results Summary

| Metric | Value |
|--------|-------|
| Total Sites Audited | 1,620 |
| Matching Records | 1,518 |
| Discrepant Records | 102 |
| Accuracy Rate | 93.7% |
| Employees with Errors | 17 |
| Suspects Identified | 4 |

### Suspected Employees

| Employee Name | Number of Mistakes | Status |
|---------------|-------------------|--------|
| Bello Azibo | 26 | 🔴 Above Average |
| Malachi Mavuso | 21 | 🔴 Above Average |
| Zuriel Matembo | 17 | 🔴 Above Average |
| Lalitha Kaburi | 7 | 🔴 Above Average |
| *Average* | *6* | *Baseline* |

### Evidence Against Suspects

1. **Statistical Anomaly**: All four made significantly more "mistakes" than average
2. **Witness Statements**: Multiple statements mention "cash" payments - **only** for these four employees
3. **Pattern**: All incorrect scores were inflated to 10 (maximum score)
4. **Exclusivity**: No other employees have bribery allegations in statements

---

## 🛠️ SQL Techniques Used

### Core Concepts Demonstrated

| Technique | Description | Use Case |
|-----------|-------------|----------|
| **Multi-table JOINs** | Linking 4+ tables | Connecting auditor report to employee data |
| **CTEs (WITH clause)** | Named temporary result sets | `Incorrect_records`, `error_count`, `suspect_list` |
| **VIEWs** | Saved query definitions | Reusable `Incorrect_records` view |
| **Window Functions** | `AVG() OVER()` | Calculate average mistakes across all employees |
| **Subqueries** | Nested queries in WHERE | Filter employees above average |
| **Pattern Matching** | `LIKE '%cash%'` | Search for incriminating statements |
| **Aggregation** | `COUNT()`, `GROUP BY` | Count mistakes per employee |

### Query Complexity Progression

```
Simple SELECT
    └── JOIN two tables
        └── JOIN multiple tables
            └── Add WHERE conditions
                └── Create CTE
                    └── Nest CTEs
                        └── Subquery in WHERE
                            └── Complex evidence query
```

---

## 📁 Repository Structure

```
maji_ndogo_audit_investigation/
│
├── README.md                           # Project documentation
├── LICENSE                             # MIT License
├── .gitignore                          # Git ignore rules
│
├── sql/
│   ├── 01_create_auditor_table.sql     # Table creation script
│   ├── 02_audit_investigation.sql      # Main analysis queries
│   └── 03_create_views.sql             # Reusable view definitions
│
└── docs/
    ├── data_dictionary.md              # Field descriptions
    ├── investigation_report.md         # Detailed findings
    └── erd_notes.md                    # ERD relationship notes
```

---

## 🚀 Setup Instructions

### Prerequisites

- MySQL 8.0+ or compatible database
- Access to `md_water_services` database (from Parts 1 & 2)
- Auditor report CSV file

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/csfrost/maji_ndogo_audit_investigation.git
   cd maji_ndogo_audit_investigation
   ```

2. **Create the auditor_report table**
   ```bash
   mysql -u username -p md_water_services < sql/01_create_auditor_table.sql
   ```

3. **Import the auditor's CSV data**
   - Use MySQL Workbench's Table Data Import Wizard, or:
   ```sql
   LOAD DATA INFILE '/path/to/auditor_report.csv'
   INTO TABLE auditor_report
   FIELDS TERMINATED BY ','
   ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 ROWS;
   ```

4. **Run the investigation queries**
   ```bash
   mysql -u username -p md_water_services < sql/02_audit_investigation.sql
   ```

---

## 🔗 Related Projects

This is **Part 3** of the Maji Ndogo Water Crisis Analysis series:

| Part | Repository | Focus |
|------|------------|-------|
| 1 | [water_services_analysis](https://github.com/csfrost/water_services_analysis) | Data exploration & quality assessment |
| 2 | [maji_ndogo_data_clustering](https://github.com/csfrost/maji_ndogo_data_clustering) | Clustering, aggregation & queue optimization |
| **3** | **maji_ndogo_audit_investigation** | **Audit integration & corruption detection** |
| 4 | *Coming soon* | Implementation planning |

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **ExploreAI Academy** - Course material and guidance
- **President Aziza Naledi** - Commitment to transparency and accountability
- **Chief Auditor Tendai Mubarak** - Rigorous audit methodology
- **Chidi Kunto** - Data team leadership

---

<p align="center">
  <i>"The data tells a story. Our job is to listen."</i>
</p>

<p align="center">
  Made with 💧 for the people of Maji Ndogo
</p>
