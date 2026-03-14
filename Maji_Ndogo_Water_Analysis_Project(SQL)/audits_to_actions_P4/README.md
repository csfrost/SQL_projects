# 💧 Maji Ndogo Water Crisis — From Analysis to Action

[![SQL](https://img.shields.io/badge/SQL-MySQL-blue?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Complete-success.svg)]()
[![Parts](https://img.shields.io/badge/Project_Parts-3_&_4-orange.svg)]()

A data-driven investigation into Maji Ndogo's water infrastructure — spanning corruption detection, regional water-access analysis, and the creation of a 25,398-task engineering action plan. Built entirely in SQL.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Database Schema](#-database-schema)
- [Key Analysis Areas](#-key-analysis-areas)
- [Corruption Investigation](#-corruption-investigation)
- [Regional Water Access Analysis](#-regional-water-access-analysis)
- [Engineering Action Plan](#-engineering-action-plan)
- [Key Insights](#-key-insights)
- [Technologies Used](#-technologies-used)
- [Getting Started](#-getting-started)
- [File Structure](#-file-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Project Overview

Access to clean water is a fundamental human right, yet the citizens of Maji Ndogo face a severe water crisis across five provinces. This project analyses **60,000+ water source records** to:

- **Validate** surveyor data against independent auditor reports
- **Detect** corruption among field workers using statistical and qualitative evidence
- **Analyse** water source distribution by province and town
- **Quantify** infrastructure failures and queue-time bottlenecks
- **Generate** a prioritised task list for engineering repair teams

> *This project is Part 3 (Auditor Integrity Check) and Part 4 (From Analysis to Action) of the Maji Ndogo integrated project series by [ExploreAI Academy](https://www.explore.ai/).*

---

## 🗄️ Database Schema

The analysis uses the `md_water_services` database with the following tables:

| Table | Description |
|-------|-------------|
| `employee` | Field staff information and assignments |
| `location` | Geographic data — address, town, province, location type |
| `visits` | Field visit records including queue times and visit counts |
| `water_quality` | Subjective quality score assessments |
| `water_source` | Water source types and population served |
| `well_pollution` | Pollution test results for wells (biological & chemical) |
| `auditor_report` | Independent auditor scores, source types, and statements |

### Entity Relationship Diagram

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   employee   │     │   location   │     │  water_quality  │     │ auditor_report  │
│──────────────│     │──────────────│     │─────────────────│     │─────────────────│
│ employee_id  │     │ location_id  │     │ record_id       │     │ location_id     │
│ name         │     │ address      │     │ quality_score   │     │ true_score      │
│ position     │     │ province     │     │ visit_count     │     │ statements      │
└──────┬───────┘     │ town         │     └────────┬────────┘     └────────┬────────┘
       │             └──────┬───────┘              │                       │
       │                    │                      │                       │
       ▼                    ▼                      ▼                       ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                                   visits                                         │
│──────────────────────────────────────────────────────────────────────────────────│
│ record_id | location_id | source_id | time_in_queue | visit_count               │
│ assigned_employee_id                                                             │
└─────────────────────────────────┬────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              water_source                                        │
│──────────────────────────────────────────────────────────────────────────────────│
│ source_id | type_of_water_source | number_of_people_served                       │
└─────────────────────────────────┬────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             well_pollution                                       │
│──────────────────────────────────────────────────────────────────────────────────│
│ source_id | description | pollutant_ppm | biological | results                   │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔍 Key Analysis Areas

### 1. Auditor Integrity Check *(Part 3)*
Cross-references independent auditor field reports with surveyor records to detect scoring discrepancies, identify employees with above-average error rates, and flag corruption through qualitative statement analysis.

### 2. Combined Analysis View *(Part 4)*
Assembles data from `location`, `water_source`, `visits`, and `well_pollution` into a single VIEW — the foundation for all downstream analysis.

### 3. Provincial & Town-Level Pivot Analysis *(Part 4)*
Builds pivot tables breaking down water source usage as a percentage of each region's population. Handles duplicate town names (e.g. Harare exists in both Akatsi and Kilimani) using composite keys.

### 4. Engineering Action Plan *(Part 4)*
Creates the `Project_progress` table and populates it with 25,398 prioritised improvement tasks using CASE-based logic to assign the right intervention to each source.

---

## 🕵️ Corruption Investigation

### The Audit Process

The independent auditor visited **1,620 locations** and re-scored each water source.

```sql
-- 1,518 scores matched (93.7%) — 102 scores conflicted
SELECT surveyor_score, auditor_score
FROM records
WHERE surveyor_score <> auditor_score;
```

### Suspects Identified

Employees whose error count exceeded the average were flagged, then cross-referenced with auditor statements mentioning **"cash"** — a strong indicator of bribery.

| Employee | Incorrect Inputs | Cash Statements |
|----------|:----------------:|:---------------:|
| Bello Azibo | 26 | ✅ |
| Malachi Mavuso | 21 | ✅ |
| Zuriel Matembo | 17 | ✅ |
| Lalitha Kaburi | 7 | ✅ |

> **Outcome:** All four suspects had incriminating statements at their mismatched locations. No other employees appeared in these results. They were subsequently arrested.

---

## 🌍 Regional Water Access Analysis

### Province-Level Breakdown

Using the `combined_analysis_table` VIEW, a pivot table calculates the percentage of each province's population relying on each water source type:

| Pattern | Detail |
|---------|--------|
| 🔴 **Sokoto** | Highest % of people drinking river water — drilling wells here is the top priority |
| 🟠 **Amanzi** | Majority have tap infrastructure but ~50% is non-functional |
| 🟡 **Kilimani** | High proportion of contaminated wells |

### Town-Level Deep Dive

| Town (Province) | Finding |
|-----------------|---------|
| Amina (Amanzi) | Only 3% have working taps — 56% have broken tap infrastructure |
| Dahabu (Amanzi) | 55% have working taps — former politicians ensured their own supply |
| Rural Sokoto | Highest river-water dependence; large wealth disparity |

---

## 🛠️ Engineering Action Plan

### Improvement Logic

Each water source is assigned a specific intervention based on its type and condition:

| Source Type | Condition | Improvement |
|-------------|-----------|-------------|
| `river` | — | Drill well |
| `well` | Contaminated: Chemical | Install RO filter |
| `well` | Contaminated: Biological | Install UV and RO filter |
| `shared_tap` | Queue ≥ 30 min | Install ⌊queue_time / 30⌋ taps nearby |
| `tap_in_home_broken` | — | Diagnose local infrastructure |

### The Project_progress Table

```sql
-- 25,398 tasks generated for engineering teams
SELECT Source_type, Improvement, COUNT(*) AS tasks
FROM Project_progress
GROUP BY Source_type, Improvement;
```

**Table design features:**
- `Source_status` defaults to `'Backlog'` and is constrained to `('Backlog', 'In progress', 'Complete')`
- `source_id` is a foreign key to `water_source` for referential integrity
- `Date_of_completion` and `Comments` fields allow engineers to log progress

---

## 💡 Key Insights

| # | Finding | Impact |
|---|---------|--------|
| 1 | **43%** of citizens rely on shared taps (~2,000 people per tap) | Prioritise new tap installations in high-traffic areas |
| 2 | **45%** of home tap infrastructure is broken | Send repair teams to Amina, Lusaka, Zuri, Djenne first |
| 3 | Only **28%** of wells are clean | Install RO/UV filters across Hawassa, Kilimani, Akatsi |
| 4 | Average queue time exceeds **120 min** (worst on Saturdays) | Deploy water tankers on peak days while taps are installed |
| 5 | **4 employees** linked to corruption via auditor statements | Arrested — data integrity restored |
| 6 | Sokoto has high river dependence **and** high home-tap access | Severe wealth inequality; drilling wells is priority #1 |

---

## 🧰 Technologies Used

- **MySQL 8.0+** — Database management system
- **SQL** — CTEs, window functions, CASE expressions, VIEWs, temporary tables
- **Multi-table JOINs** — INNER, LEFT joins with composite keys
- **Data Integrity** — Foreign keys (CASCADE), CHECK constraints, DEFAULT values

---

## 🚀 Getting Started

### Prerequisites
- MySQL 8.0 or compatible database system
- Access to the `md_water_services` database

### Running the Analysis

1. **Clone the repository:**
   ```bash
   git clone https://github.com/csfrost/Maji_Ndogo.git
   cd Maji_Ndogo
   ```

2. **Connect to your MySQL database:**
   ```bash
   mysql -u your_username -p
   ```

3. **Execute scripts in order:**
   ```sql
   SOURCE 01_auditor_integrity_check.sql;
   SOURCE 02_combined_analysis_view.sql;
   SOURCE 03_provincial_town_analysis.sql;
   SOURCE 04_project_progress.sql;
   ```

---

## 📁 File Structure

```
Maji_Ndogo/
│
├── README.md                              # Project documentation
├── LICENSE                                # MIT License
├── .gitignore                             # Git ignore rules
│
├── 01_auditor_integrity_check.sql         # Auditor vs. surveyor comparison & corruption detection
├── 02_combined_analysis_view.sql          # VIEW joining location, water_source, visits & well_pollution
├── 03_provincial_town_analysis.sql        # Pivot tables: water source % by province and town
└── 04_project_progress.sql               # Project_progress table creation & task population
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/NewAnalysis`)
3. Commit your changes (`git commit -m 'Add new analysis query'`)
4. Push to the branch (`git push origin feature/NewAnalysis`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**csfrost**

- GitHub: [@csfrost](https://github.com/csfrost)

---

<p align="center">
  <i>This project is part of the Maji Ndogo integrated project series by ExploreAI Academy — turning data into action for communities in need.</i>
</p>
