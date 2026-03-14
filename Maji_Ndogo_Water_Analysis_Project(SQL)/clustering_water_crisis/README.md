# 💧 Clustering Data to Unveil Maji Ndogo's Water Crisis

[![SQL](https://img.shields.io/badge/SQL-MySQL-blue?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-success.svg)]()
[![Part](https://img.shields.io/badge/Project-Part%202-orange.svg)]()

An advanced SQL analysis project that clusters and aggregates water infrastructure data to reveal patterns in Maji Ndogo's water crisis. This project builds on foundational analysis to uncover actionable insights through data cleaning, employee performance tracking, location analysis, water source evaluation, and queue time optimization.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Project Workflow](#-project-workflow)
- [Database Schema](#-database-schema)
- [Analysis Sections](#-analysis-sections)
- [Key Findings](#-key-findings)
- [Practical Solutions](#-practical-solutions)
- [Technologies Used](#-technologies-used)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Project Overview

This project represents **Part 2** of the Maji Ndogo water crisis analysis, focusing on clustering data to gain a panoramic understanding of the water situation. The analysis moves beyond isolated data points to discern larger patterns and trends that will inform infrastructure improvement decisions.

### Objectives

- **Clean & standardize** employee data for effective communication
- **Honor top performers** by identifying field surveyors with highest contributions
- **Analyze locations** to understand geographic distribution of water sources
- **Dive into sources** to quantify the scope of the water crisis
- **Analyze queue patterns** to optimize water collection times
- **Develop practical solutions** based on data-driven insights

---

## 🔄 Project Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  1. Data        │     │  2. Employee    │     │  3. Location    │
│  Cleaning       │────▶│  Analysis       │────▶│  Analysis       │
│  • Email format │     │  • Top workers  │     │  • Rural/Urban  │
│  • Phone trim   │     │  • Visit counts │     │  • Distribution │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                                               │
         ▼                                               ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  6. Solution    │     │  5. Queue       │     │  4. Source      │
│  Planning       │◀────│  Analysis       │◀────│  Analysis       │
│  • Priorities   │     │  • Time patterns│     │  • Types        │
│  • Action items │     │  • Day/hour     │     │  • Population   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## 🗄️ Database Schema

The analysis uses the `md_water_services` database:

| Table | Description | Key Columns |
|-------|-------------|-------------|
| `employee` | Field staff information | employee_id, employee_name, email, phone_number |
| `location` | Geographic data | location_id, province_name, town_name, location_type |
| `visits` | Field visit records | record_id, time_of_record, time_in_queue, assigned_employee_id |
| `water_source` | Source information | source_id, type_of_water_source, number_of_people_served |
| `water_quality` | Quality assessments | record_id, subjective_quality_score |
| `well_pollution` | Pollution test results | source_id, biological, results |

---

## 🔍 Analysis Sections

### 1. 🧹 Data Cleaning
**Updating Employee Data**

- Generated standardized email addresses: `first.last@ndogowater.gov`
- Trimmed whitespace from phone numbers (13 → 12 characters)
- Used `REPLACE()`, `LOWER()`, `CONCAT()`, and `TRIM()` functions

```sql
-- Email generation pattern
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');
```

### 2. 🏆 Honouring the Workers
**Finding Top Performers**

- Identified employees per town distribution
- Found top 3 field surveyors by visit count
- **Top performers:** Bello Azibo, Pili Zola, Rudo Imani

### 3. 📍 Analysing Locations
**Understanding Geographic Distribution**

- Counted records per town and province
- Analyzed urban vs rural distribution
- **Finding:** 60% of water sources are in rural areas

### 4. 💧 Diving into the Sources
**Scope of the Problem**

- Total surveyed population: ~27 million citizens
- Water source type distribution and usage
- Average people served per source type
- Population percentage by source type

### 5. 🚰 Start of a Solution
**Priority Ranking**

- Created priority rankings using window functions
- Excluded `tap_in_home` (already optimal)
- Used `RANK()`, `DENSE_RANK()`, and `ROW_NUMBER()` for different use cases

### 6. ⏱️ Analysing Queues
**Time Pattern Analysis**

- Survey duration: **924 days** (~2.5 years)
- Average queue time: **123 minutes**
- Built pivot table showing queue times by day and hour
- Identified peak and off-peak collection times

---

## 💡 Key Findings

### Water Source Distribution

| Source Type | Population % | Avg People/Source | Priority |
|-------------|-------------|-------------------|----------|
| Shared Tap | 43% | 2,071 | 1 |
| Well | 18% | 279 | 2 |
| Tap in Home | 17% | 6* | N/A |
| Tap in Home (Broken) | 14% | - | 3 |
| River | 9% | 699 | 4 |

*Adjusted for household grouping (644 ÷ 6 people/home)

### Infrastructure Issues

- **31%** have home water infrastructure
- **45%** of home systems are non-functional
- **Only 28%** of wells are clean (4,916 of 17,383)

### Queue Time Patterns

| Day | Avg Queue (min) | Observation |
|-----|-----------------|-------------|
| Saturday | 246 | Highest - weekly supply collection |
| Monday | 137 | Post-weekend rush |
| Sunday | 82 | Lowest - cultural/family day |
| Wednesday | 97 | Mid-week low |

### Peak Hours
- **Morning rush:** 6:00 AM - 8:00 AM
- **Evening rush:** 5:00 PM - 7:00 PM
- **Off-peak:** Mid-day (10:00 AM - 3:00 PM)

---

## 🛠️ Practical Solutions

### Short-Term Actions

| Source Type | Intervention |
|-------------|--------------|
| Rivers | Deploy water trucks while drilling wells |
| Wells (Biological) | Install UV filters |
| Wells (Chemical) | Install reverse osmosis filters |
| Shared Taps | Send tankers during peak times |

### Long-Term Goals

1. **Install additional shared taps** to reduce queue times below 30 minutes (UN standard)
2. **Repair broken infrastructure** (reservoirs, pipes) for maximum impact
3. **Investigate pollution sources** for contaminated wells
4. **Home tap installation** as resources allow

### Priority Framework

```
Priority 1: Shared taps (43% population impact)
Priority 2: Wells - contamination fixes (18% population)
Priority 3: Broken infrastructure (14% population)
Priority 4: Rivers - temporary + permanent solutions (9% population)
```

---

## 🛠️ Technologies Used

- **MySQL 8.0+** - Database management
- **SQL** - Query language
- **Window Functions** - RANK(), DENSE_RANK(), ROW_NUMBER()
- **DateTime Functions** - DAYNAME(), TIME_FORMAT(), DATEDIFF()
- **Control Flow** - CASE statements for pivot tables
- **String Functions** - CONCAT(), REPLACE(), LOWER(), TRIM()

---

## 🚀 Getting Started

### Prerequisites
- MySQL 8.0 or compatible database
- Access to the `md_water_services` database

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/csfrost/clustering_water_crisis.git
   cd clustering_water_crisis
   ```

2. **Connect to MySQL:**
   ```bash
   mysql -u your_username -p
   ```

3. **Run the analysis:**
   ```sql
   SOURCE clustering_water_crisis_analysis.sql;
   ```

---

## 📁 Project Structure

```
clustering_water_crisis/
│
├── README.md                              # Project documentation
├── LICENSE                                # MIT License
├── .gitignore                             # Git ignore rules
│
├── clustering_water_crisis_analysis.sql  # Main analysis queries
│
└── docs/
    ├── data_dictionary.md                 # Table & field descriptions
    └── insights_report.md                 # Detailed findings report
```

---

## 📊 Sample Pivot Table Output

Queue times by hour and day of week:

| Hour | Sun | Mon | Tue | Wed | Thu | Fri | Sat |
|------|-----|-----|-----|-----|-----|-----|-----|
| 06:00 | 79 | 190 | 134 | 112 | 134 | 153 | 247 |
| 07:00 | 82 | 186 | 128 | 111 | 139 | 156 | 247 |
| 08:00 | 86 | 183 | 130 | 119 | 129 | 153 | 247 |
| 09:00 | 84 | 127 | 105 | 94 | 99 | 107 | 252 |
| ... | ... | ... | ... | ... | ... | ... | ... |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/NewAnalysis`)
3. Commit your changes (`git commit -m 'Add queue optimization query'`)
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

## 🔗 Related Projects

- [Maji_Ndogo](https://github.com/csfrost/Maji_Ndogo) - Original project repository
- [water_services_analysis](https://github.com/csfrost/water_services_analysis) - Part 1 analysis

---

<p align="center">
  <i>"Mambo yatakuwa sawa" - Things will be okay</i><br>
  <sub>This project is part of a data-driven initiative to improve water access in Maji Ndogo.</sub>
</p>
