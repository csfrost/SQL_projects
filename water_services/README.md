# 💧 Maji Ndogo Water Services Analysis

[![SQL](https://img.shields.io/badge/SQL-MySQL-blue?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-success.svg)]()

A data-driven analysis of water infrastructure, quality assessment, and accessibility in the Maji Ndogo region. This project uses SQL to uncover insights that support evidence-based decision-making for improving water services to underserved communities.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Database Schema](#-database-schema)
- [Key Analysis Areas](#-key-analysis-areas)
- [Data Quality Findings](#-data-quality-findings)
- [Technologies Used](#-technologies-used)
- [Getting Started](#-getting-started)
- [File Structure](#-file-structure)
- [Key Insights](#-key-insights)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Project Overview

Access to clean water is a fundamental human right. This project analyzes the water services infrastructure in Maji Ndogo to:

- **Classify** different types of water sources serving the population
- **Evaluate** water quality through subjective scoring and pollution testing
- **Analyze** queue times to identify accessibility challenges
- **Detect & correct** data integrity issues in pollution records
- **Support** strategic planning for infrastructure improvements

---

## 🗄️ Database Schema

The analysis uses the `md_water_services` database with the following tables:

| Table | Description |
|-------|-------------|
| `employee` | Field staff information and assignments |
| `location` | Geographic data for water sources |
| `visits` | Field visit records including queue times |
| `water_quality` | Subjective quality assessments |
| `water_source` | Water source types and population served |
| `well_pollution` | Pollution test results for wells |

### Entity Relationship Diagram

```
┌──────────────┐     ┌──────────────┐     ┌─────────────────┐
│   employee   │     │   location   │     │  water_quality  │
│──────────────│     │──────────────│     │─────────────────│
│ employee_id  │◄────│ location_id  │     │ record_id       │
│ name         │     │ address      │     │ quality_score   │
│ position     │     │ province     │     │ visit_count     │
└──────────────┘     │ town         │     └────────┬────────┘
       │             └──────┬───────┘              │
       │                    │                      │
       ▼                    ▼                      ▼
┌─────────────────────────────────────────────────────────┐
│                        visits                            │
│─────────────────────────────────────────────────────────│
│ record_id | location_id | source_id | time_in_queue     │
│ visit_count | assigned_employee_id                       │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│                     water_source                          │
│──────────────────────────────────────────────────────────│
│ source_id | type_of_water_source | number_of_people_served│
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│                     well_pollution                        │
│──────────────────────────────────────────────────────────│
│ source_id | description | pollutant_ppm | biological     │
│ results                                                   │
└──────────────────────────────────────────────────────────┘
```

---

## 🔍 Key Analysis Areas

### 1. Water Source Classification
Identifies the unique types of water sources in the region:
- `tap_in_home` - Private residential taps
- `tap_in_home_broken` - Non-functional private taps
- `shared_tap` - Community water points
- `well` - Groundwater sources
- `river` - Surface water sources

### 2. Queue Time Analysis
Examines locations where residents wait **more than 500 minutes** for water:
- Identifies high-traffic shared taps
- Analyzes patterns in repeat visits
- Evaluates employee assignment efficiency

### 3. Water Quality Assessment
Investigates tap water quality where:
- Subjective quality score = 10 (highest rating)
- Sources required multiple follow-up visits
- Home tap installations need verification

### 4. Pollution Data Integrity Audit
Identifies and corrects records where:
- Results marked "Clean" despite biological contamination > 0.01
- Description fields incorrectly labeled with "Clean" prefix

---

## ⚠️ Data Quality Findings

### Critical Discovery: 38 Erroneous Pollution Records

The analysis uncovered systematic data entry errors in the `well_pollution` table:

**Problem Identified:**
```sql
-- Records incorrectly marked as clean despite contamination
SELECT * FROM well_pollution
WHERE results = 'Clean' AND biological > 0.01;
```

**Root Cause:** 
When the description field began with "Clean" (e.g., "Clean Bacteria: E. coli"), the automated classification system incorrectly marked results as safe.

**Correction Applied:**
| Field | Before | After |
|-------|--------|-------|
| `description` | "Clean Bacteria: E. coli" | "Bacteria: E. coli" |
| `results` | "Clean" | "Contaminated: Biological" |

---

## 🛠️ Technologies Used

- **MySQL 8.0+** - Database management system
- **SQL** - Query language for data analysis
- **Common Table Expressions (CTEs)** - For modular, readable queries

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

3. **Run the analysis script:**
   ```sql
   SOURCE Begining_my_Data_Driven_Journey_in_Maji_Ndogo.sql;
   ```

---

## 📁 File Structure

```
Maji_Ndogo/
│
├── README.md                                              # Project documentation
├── LICENSE                                                # MIT License
├── .gitignore                                             # Git ignore rules
│
├── Begining_my_Data_Driven_Journey_in_Maji_Ndogo.sql     # Main analysis queries
│
└── docs/
    └── data_dictionary.md                                 # Table & field descriptions
```

---

## 💡 Key Insights

| Finding | Impact |
|---------|--------|
| Shared taps have highest queue times | Prioritize new tap installations in high-traffic areas |
| 38 pollution records misclassified | Public health risk from unreported contamination |
| Multiple visits needed for some taps | Quality assessment process needs standardization |

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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**csfrost**

- GitHub: [@csfrost](https://github.com/csfrost)

---

<p align="center">
  <i>This project is part of a data-driven initiative to improve water access in underserved communities.</i>
</p>
