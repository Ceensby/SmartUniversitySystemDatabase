# University Management System

A relational database project for the **Database Management** course.
Designed for **Microsoft SQL Server 2025**.

## Project Overview

A university management system that handles students, staff (instructors and non-academic staff),
courses, exams, assignments, dormitories, scholarships, internships, libraries, clubs, events,
gyms, and more — covering more than 30 entities with multiple advanced ERD concepts such as
weak entities, multivalued attributes, derived attributes, and disjoint specialization.

## Project Phases

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 1 | ERD / EERD design (on A3 paper + digital) | ✅ Done |
| Phase 2 | Database table creation + sample data (MSSQL) | ✅ Done |
| Phase 3 | SQL operations (queries, functions, procedures, triggers, views) | ⏳ In progress |

## Repository Structure

```
.
├── README.md
├── .gitignore
├── docs/                          Documentation (cardinality, mapping decisions, assignment PDFs)
├── phase1-erd/                    Phase 1 deliverables: ERD/EERD diagrams
├── phase2-tables/                 Phase 2 deliverables: CREATE TABLE + INSERT scripts
├── phase3-sql-operations/         Phase 3 deliverables: SQL operations
│   ├── queries/
│   ├── functions/
│   ├── procedures/
│   ├── triggers/
│   └── views/
└── screenshots/                   SSMS screenshots for the report
```

## How to Run Phase 2

1. Open **SQL Server Management Studio (SSMS)** and connect to your MSSQL Server 2025 instance.
2. Create a new database:
   ```sql
   CREATE DATABASE UniversityManagement;
   GO
   USE UniversityManagement;
   GO
   ```
3. Open `phase2-tables/01_create_tables.sql`, press **F5** to execute.
4. Open `phase2-tables/02_insert_sample_data.sql`, press **F5** to execute.
5. (Optional) To reset everything, run `phase2-tables/03_drop_all.sql`.

Alternatively, run the bundled script `phase2-tables/full_script.sql` to do all of the above in one go.

## Project Stats

- **Entities:** 31
- **Multivalued attribute tables:** 8
- **M:N junction tables:** 6
- **Total tables:** 45
- **Sample records per table:** 2+

## Tech Stack

- **DBMS:** Microsoft SQL Server 2025
- **Client:** SQL Server Management Studio (SSMS)
- **ERD tool:** ErdPlus

## License

Academic project, free to reference for educational purposes.
