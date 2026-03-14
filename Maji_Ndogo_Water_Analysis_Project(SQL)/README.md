# Maji Ndogo Water Source Analysis & Improvement Project

> A multi-part SQL project analysing water access, infrastructure quality, and service delivery across the Maji Ndogo region — from raw data exploration through to actionable improvement planning.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Repository Structure](#repository-structure)
- [Part 1 — Water Services](#part-1--water-services)
- [Part 2 — Clustering the Water Crisis](#part-2--clustering-the-water-crisis)
- [Part 3 — Audit Investigation](#part-3--audit-investigation)
- [Part 4 — Audits to Actions](#part-4--audits-to-actions)
- [Project Goals](#project-goals)
- [Usage](#usage)
- [Future Work](#future-work)

---

## Project Overview

This project applies SQL-driven analysis to a real-world water services dataset from Maji Ndogo. Across four progressive parts, it tackles data cleaning, employee performance assessment, data integrity investigation, and infrastructure improvement planning. The end goal is to provide decision-makers with reliable, evidence-based insights to prioritise water access interventions.

**Core themes addressed:**
- Water source distribution and quality across provinces and towns
- Queue time patterns and their social implications
- Discrepancies between field surveyors and independent auditors
- Targeted, data-driven improvement plans for degraded infrastructure

---

## Repository Structure

```
Maji_Ndogo_Water_Analysis_Project(SQL)/
│
├── water_services_P1/           # Data exploration & quality correction
├── clustering_water_crisis_P2/  # Employee analysis & source aggregation
├── audit_investigation_P3/      # Surveyor vs. auditor discrepancy analysis
└── audits_to_actions_P4/        # Project planning & progress tracking
```

---

## Part 1 — Water Services

**Folder:** `water_services_P1`

The foundation of the project. This part focuses on understanding the database schema, performing initial data exploration, and resolving critical data quality issues.

**Scope:**
- Queries across the `employee`, `location`, `visits`, `water_quality`, `water_source`, and `well_pollution` tables
- Detection of anomalous queue times exceeding 500 minutes at shared tap sources
- Quality assessment of home taps with suspiciously high subjective scores on repeat visits
- Correction of mislabelled well pollution records — wells marked as *Clean* despite measurable biological contamination (>0.01 ppm)

**Key Findings:**

| Finding | Detail |
|---|---|
| Highest queue times | Associated with shared taps |
| Mislabelled wells | 38 wells incorrectly classified as Clean |
| Flagged home taps | Identified for further validation |

---

## Part 2 — Clustering the Water Crisis

**Folder:** `clustering_water_crisis_P2`

With clean data established, this part deepens the analysis — profiling employees, segmenting water source usage, and uncovering patterns in service access across the region.

**Scope:**
- Standardisation of employee records: generated official email addresses and stripped extraneous whitespace from phone numbers
- Distribution analysis of employees across towns and provinces
- Identification of top-performing field surveyors by visit count
- Aggregation of water source data by type, including population served and percentage share
- Time-series analysis of queue durations by day of week and hour of day

**Key Findings:**

| Metric | Finding |
|---|---|
| Shared tap reliance | 43% of the population; ~2,000 people per tap on average |
| Home infrastructure | 31% coverage, but 45% of systems non-functional |
| Well usage | 18% of population; only 28% of wells are clean |
| Average queue time | 123 minutes; peak periods on Saturdays, mornings, and evenings |

---

## Part 3 — Audit Investigation

**Folder:** `audit_investigation_P3`

A data integrity investigation comparing independently conducted auditor assessments against field surveyor records, exposing inconsistencies and potential misconduct.

**Scope:**
- Cross-referencing auditor and surveyor water quality scores across all shared locations
- Statistical identification of employees with error rates significantly above the cohort average
- Qualitative analysis of auditor notes — including flagged references to financial transactions ("cash") in field records
- Escalation of specific employees (including Bello Azibo and Malachi Mavuso) for review

**Key Findings:**

| Metric | Finding |
|---|---|
| Matching scores | 1,518 out of 1,620 locations (93.7%) |
| Conflicting scores | 102 discrepancies identified |
| High-error employees | 4 employees flagged for further investigation |

---

## Part 4 — Audits to Actions

**Folder:** `audits_to_actions_P4`

The culmination of the project. Insights from the preceding analysis are translated into a structured, trackable improvement plan for Maji Ndogo's water infrastructure.

**Scope:**
- Province- and town-level breakdown of water source type percentages using joined data from `location`, `water_source`, `visits`, and `well_pollution`
- Identification of towns with critically broken infrastructure (e.g., Amina, where only 3% of home taps remain functional)
- Creation of a `project_progress` table to systematically record and track required interventions
- Specification of targeted solutions per source type: tanker deployment, UV/RO filter installation, well drilling, and infrastructure repair

**Key Findings:**

| Area | Issue | Proposed Intervention |
|---|---|---|
| Sokoto (rural) | Heavy river water reliance | Well drilling programme |
| Amina | 97% broken home tap infrastructure | Urgent infrastructure repair |
| Rural Amanzi | Significant broken infrastructure | Prioritised repair & tanker deployment |
| Contaminated wells (region-wide) | Biological contamination | UV/RO filter installation |

---

## Project Goals

1. **Improve Water Access** — Systematically reduce reliance on shared taps and contaminated sources through targeted interventions.
2. **Prioritise Rural Regions** — Direct well-drilling and filtration resources to underserved areas such as Sokoto.
3. **Ensure Data Integrity** — Identify and address surveyor errors to maintain the reliability of ongoing data collection.
4. **Enable Progress Tracking** — Leverage the `project_progress` table as a living record of infrastructure improvement efforts.

---

## Usage

1. **Run parts in sequence** (`P1` → `P4`) — later parts depend on cleaned data and structures established in earlier ones.
2. **Review insights per part** — each folder contains annotated SQL with embedded commentary on findings and methodology.
3. **Use `project_progress`** — the table created in Part 4 serves as the operational tracking layer for all recommended interventions.

---

## Future Work

- **Cost modelling** — Integrate estimated repair and installation costs to support budget planning.
- **Automated QA** — Build automated checks to flag surveyor–auditor discrepancies in real time.
- **Dashboard development** — Create interactive visualisations for executive reporting on water source status and project progress.
- **Longitudinal tracking** — Extend the dataset over time to measure the impact of completed interventions.
