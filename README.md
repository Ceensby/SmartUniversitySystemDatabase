<div align="center">
  <h1>University Management System</h1>
  <h3>Istanbul Topkapı University &bull; Computer Engineering</h3>
  <p><em>A comprehensive, three-phase database management system project.</em></p>
</div>

---

## 📌 Project Abstract

This project is a complete, end-to-end relational database implementation of a **University Management System**. It encompasses the entire database development lifecycle, starting from conceptual Entity-Relationship (ER) modeling, advancing through physical schema definitions and data population, and culminating in advanced programmatic SQL operations. The system is designed to handle complex university operations, including academic administration, student life, financial tracking, and career services.

---

## 🏗️ Project Architecture & Schema Overview

The database schema employs a highly normalized, centralized hub-and-spoke architecture.

### The `UserAccount` Hub
A critical design decision in this schema is the use of `UserAccount` as the central linking entity. Rather than creating disjointed systems for different roles, both `Student` and `Staff` (including its disjoint subclasses `Instructor` and `NonAcademicStaff`) are firmly linked to a unified `UserAccount` table. 
* **Academic Flow**: To find a student's department, the relationship traces through `Student` &rarr; `UserAccount` &rarr; `Department`.
* **Staff Flow**: To find an instructor's assigned courses, the path flows through `Instructor` &rarr; `Staff` &rarr; `UserAccount` &rarr; `UserAccount_Course`.

### Relationship Mapping Highlights
* **Disjoint Specialization**: A `Staff` member is exclusively either an `Instructor` or `NonAcademicStaff`, enforced via a shared primary key approach.
* **Weak Entities**: Entities like `CourseContent`, `Exam`, and `Assignment` depend entirely on the `Course` entity and utilize composite primary keys mapped directly to their parent course.
* **M:N Junctions**: Complex many-to-many relationships (e.g., students joining clubs, users enrolling in courses, users receiving scholarships) are resolved using dedicated junction tables.

---

## 📂 Folder & File Structure

<details>
<summary><b>Click to expand the project tree</b></summary>

```text
DatabaseManagement-Project/
│
├── docs/
│   ├── Cardinality-List.md           # Documentation of relationship cardinalities
│   └── Mapping-Decisions.md          # ER-to-Relational mapping rules and constraints
│
├── phase1-erd/                       # Conceptual ER diagrams and logical models
│   └── (ERD artifacts)
│
├── phase2-tables/
│   ├── 01_create_tables.sql          # DDL: Table creation with PK/FK and constraints
│   ├── 02_insert_sample_data.sql     # DML: Comprehensive sample data insertion
│   └── full_script.sql               # Combined Phase 2 execution script
│
├── phase3-sql-operations/
│   ├── functions/
│   │   └── 01_udfs.sql               # Scalar User-Defined Functions (e.g., GPA parsing)
│   ├── procedures/
│   │   └── 01_stored_procedures.sql  # Stored procedures with transactional logic
│   ├── queries/
│   │   └── 01_complex_queries.sql    # Advanced JOINs, subqueries, and aggregations
│   ├── triggers/
│   │   └── 01_triggers.sql           # Data validation and automated event triggers
│   └── views/
│       └── 01_views.sql              # Denormalized reporting views
│
└── screenshots/                      # Project demonstration and execution screenshots
```
</details>

---

## 🚀 Phase Breakdown

### Phase 1: Conceptual & Logical Design
* **Entity-Relationship Modeling**: Defined all strong and weak entities, multivalued attributes, and inter-entity relationships.
* **Relational Mapping**: Translated the conceptual ER model into a strict relational schema, establishing primary and foreign key constraints, resolving M:N relationships into bridging tables, and successfully mapping the disjoint `Staff` specialization hierarchy.

### Phase 2: Physical Design
* **DDL Implementation**: Authored `CREATE TABLE` statements establishing strict referential integrity (`ON DELETE CASCADE`), identity columns, and composite keys across 30+ tables.
* **DML Operations**: Populated the database with rich, realistic sample data across all tables to accurately simulate a live university environment.

### Phase 3: Advanced SQL Operations
* **Complex Queries**: Developed 5 sophisticated analytical queries utilizing `INNER`/`LEFT JOIN` chains, `GROUP BY`/`HAVING`, and correlated/non-correlated subqueries (e.g., Department KPI Dashboards, Full Student Profiles).
* **User-Defined Functions (UDFs)**: Created robust scalar functions for complex string parsing (safely extracting GPA data from free-text transcripts) and dynamic financial calculations (total scholarship aggregations).
* **Stored Procedures**: Built atomic, transactional procedures utilizing `TRY/CATCH` blocks, `ROLLBACK` logic, and output parameters to safely handle critical operations like student course enrollment and scholarship processing.
* **Triggers**: Implemented `AFTER` and `INSTEAD OF` triggers to enforce complex business rules, including date overlap prevention for internships, user account audit logging, score range validations, and automated system notifications.
* **Views**: Constructed complex, denormalized views aggregating data from up to 9 different tables to simplify reporting for academic advisors and department heads.

---

## ⚙️ Setup & Execution Guide

To successfully replicate this database environment for evaluation, please follow these precise execution steps.

### Prerequisites
* Microsoft SQL Server 2025
* SQL Server Management Studio (SSMS) or Azure Data Studio

### Execution Order
Execute the SQL scripts strictly in the following order to prevent dependency errors and foreign key violations.

<details open>
<summary><b>Step-by-Step Instructions</b></summary>

1. **Create the Database Environment**
   Open your SQL editor, connect to your server, and execute:
   ```sql
   CREATE DATABASE UniversityManagement;
   GO
   USE UniversityManagement;
   GO
   ```

2. **Phase 2: Build the Schema and Insert Data**
   * Execute <kbd>phase2-tables/01_create_tables.sql</kbd> to build the relational structure.
   * Execute <kbd>phase2-tables/02_insert_sample_data.sql</kbd> to populate the tables with sample records.

3. **Phase 3: Deploy Advanced Operations**
   *The execution sequence here is critical, as Views depend on UDFs, and Queries depend on both the underlying schema and the generated Views.*
   * Execute <kbd>phase3-sql-operations/functions/01_udfs.sql</kbd>
   * Execute <kbd>phase3-sql-operations/procedures/01_stored_procedures.sql</kbd>
   * Execute <kbd>phase3-sql-operations/triggers/01_triggers.sql</kbd>
   * Execute <kbd>phase3-sql-operations/views/01_views.sql</kbd>
   * *Optional:* Execute <kbd>phase3-sql-operations/queries/01_complex_queries.sql</kbd> to test the analytical reporting queries.

</details>

---

## 💻 Technologies Used
* **RDBMS**: Microsoft SQL Server 2025
* **Language**: T-SQL (Transact-SQL)
* **Modeling & Design**: Entity-Relationship Diagrams (ERD), Relational Mapping Techniques
