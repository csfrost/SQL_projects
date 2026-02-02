# 📊 ERD Notes

## Entity Relationship Diagram - md_water_services Database

This document explains the database structure and relationships critical to the audit investigation.

---

## Database Overview

The `md_water_services` database contains survey data from the Maji Ndogo water project. The central table is `visits`, which links all other entities.

---

## Table Relationships

### Central Hub: visits

The `visits` table acts as the central junction table, connecting:

```
                    ┌─────────────┐
                    │   employee  │
                    │─────────────│
                    │ assigned_   │
                    │ employee_id │◄─────┐
                    │ (PK)        │      │
                    └─────────────┘      │
                                         │
┌─────────────┐     ┌─────────────┐      │     ┌─────────────┐
│  location   │     │   visits    │      │     │water_quality│
│─────────────│     │─────────────│      │     │─────────────│
│ location_id │◄────│ location_id │      │     │ record_id   │
│ (PK)        │     │ (FK)        │      │     │ (FK)        │
│             │     │             │      │     │ subjective_ │
└─────────────┘     │ source_id   │──────┼────►│ quality_    │
                    │ (FK)        │      │     │ score       │
                    │             │      │     └─────────────┘
┌─────────────┐     │ assigned_   │──────┘            ▲
│water_source │     │ employee_id │                   │
│─────────────│     │ (FK)        │                   │
│ source_id   │◄────│             │              1:1 Relationship
│ (PK)        │     │ record_id   │───────────────────┘
│ type_of_    │     │ (PK)        │
│ water_source│     │             │
└─────────────┘     │ visit_count │
                    │ time_of_    │
                    │ record      │
                    └─────────────┘
```

---

## Relationship Types

### One-to-Many Relationships

| Parent Table | Child Table | Relationship |
|--------------|-------------|--------------|
| location | visits | One location → Many visits |
| water_source | visits | One source → Many visits |
| employee | visits | One employee → Many visits |

### One-to-One Relationship

| Table 1 | Table 2 | Notes |
|---------|---------|-------|
| visits | water_quality | Each visit has exactly one quality score |

**Important:** The ERD tool may show this as many-to-one by default. Verify by checking that `record_id` is unique in both tables, then manually set cardinality to 1:1.

---

## Key Fields for Audit Investigation

### Primary Keys (PK)

| Table | Primary Key |
|-------|-------------|
| visits | record_id |
| location | location_id |
| water_source | source_id |
| employee | assigned_employee_id |
| water_quality | (uses record_id as FK) |

### Foreign Keys (FK) in visits

| Field | References |
|-------|------------|
| location_id | location.location_id |
| source_id | water_source.source_id |
| assigned_employee_id | employee.assigned_employee_id |

---

## Auditor Report Integration

The `auditor_report` table was added to store independent audit results:

```
┌─────────────────┐
│ auditor_report  │
│─────────────────│
│ location_id     │───────► joins to visits.location_id
│ type_of_water_  │
│ source          │
│ true_water_     │───────► compared with water_quality.subjective_quality_score
│ source_score    │
│ statements      │───────► analyzed for keywords like "cash"
└─────────────────┘
```

### Join Path for Investigation

```
auditor_report
       │
       │ location_id = location_id
       ▼
    visits
       │
       ├──► record_id ──► water_quality (compare scores)
       │
       └──► assigned_employee_id ──► employee (identify surveyor)
```

---

## ERD Best Practices

### 1. Verify Cardinality

Before analysis, verify relationships match logical expectations:

```sql
-- Check if record_id is unique in both visits and water_quality
SELECT COUNT(*) AS total, COUNT(DISTINCT record_id) AS unique_ids
FROM visits;

SELECT COUNT(*) AS total, COUNT(DISTINCT record_id) AS unique_ids
FROM water_quality;
```

### 2. Understand visit_count

Some locations were visited multiple times:
- `visit_count = 1`: First visit
- `visit_count = 2, 3, ...`: Re-visits (often for failed sources)

For the audit, we only use `visit_count = 1` to avoid duplicates.

### 3. Use Table Aliases

With many joins, aliases keep queries readable:

```sql
FROM auditor_report AS ar
JOIN visits AS v ON ar.location_id = v.location_id
JOIN water_quality AS wq ON v.record_id = wq.record_id
JOIN employee AS e ON e.assigned_employee_id = v.assigned_employee_id
```

---

## Generating ERD in MySQL Workbench

### Steps:

1. Open MySQL Workbench
2. Connect to the `md_water_services` database
3. Go to **Database** → **Reverse Engineer**
4. Select the schema and tables
5. Review and adjust the generated diagram

### Manual Adjustments:

1. Right-click on relationship lines
2. Select **Edit Relationship**
3. Go to **Foreign Key** tab
4. Adjust **Cardinality** as needed (e.g., 1:1 for visits ↔ water_quality)

---

## Data Flow for Investigation

```
┌─────────────────────────────────────────────────────────────┐
│                    INVESTIGATION DATA FLOW                   │
└─────────────────────────────────────────────────────────────┘

Step 1: Import Audit Data
┌──────────────┐
│ CSV File     │
│ (Auditor's   │──────────────────┐
│ Report)      │                  │
└──────────────┘                  ▼
                          ┌──────────────┐
                          │auditor_report│
                          │ (new table)  │
                          └──────┬───────┘
                                 │
Step 2: Join to Database         │
                                 ▼
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│   employee   │◄─────────│    visits    │─────────►│water_quality │
└──────────────┘          └──────────────┘          └──────────────┘
       │                         │                         │
       │                         │                         │
       ▼                         ▼                         ▼
Step 3: Compare & Analyze
┌─────────────────────────────────────────────────────────────┐
│                    Incorrect_records VIEW                    │
│  Combines: location, employee name, both scores, statements │
└─────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
Step 4: Identify Suspects
┌─────────────────────────────────────────────────────────────┐
│                  Statistical Analysis                        │
│  - Count errors per employee                                │
│  - Calculate average                                        │
│  - Filter above-average                                     │
│  - Search for "cash" in statements                          │
└─────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
Step 5: Conclusions
┌─────────────────────────────────────────────────────────────┐
│  4 Suspects Identified:                                     │
│  • Bello Azibo (26 errors, cash allegations)               │
│  • Malachi Mavuso (21 errors, cash allegations)            │
│  • Zuriel Matembo (17 errors, cash allegations)            │
│  • Lalitha Kaburi (7 errors, cash allegations)             │
└─────────────────────────────────────────────────────────────┘
```

---

## References

- MySQL Workbench Documentation: [Reverse Engineering](https://dev.mysql.com/doc/workbench/en/wb-reverse-engineer-live.html)
- Parts 1 & 2 of this project series for original database setup
