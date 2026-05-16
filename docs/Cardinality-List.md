# Cardinality List

This document lists all relationships in the University Management System
with their cardinality and participation constraints.

## Relationship Table

| # | Relationship | Cardinality | Participation Notes |
|---|--------------|-------------|---------------------|
| 1  | Instructor – Project (Supervises)              | 1:N | Partial |
| 2  | Staff – Instructor (Disjoint specialization)   | 1:1 | — |
| 3  | Staff – NonAcademicStaff (Disjoint)            | 1:1 | — |
| 4  | Staff – UserAccount (Belongs)                  | 1:1 | — |
| 5  | Department – UserAccount (Belongs)             | 1:N | — |
| 6  | Faculty – Department (BelongsTo)               | 1:N | **Total** on both sides |
| 7  | UserAccount – Internship (WorksOn)             | 1:N | — |
| 8  | Internship – InternshipReport (Has)            | 1:1 | — |
| 9  | UserAccount – Scholarship (Belongs)            | M:N | — |
| 10 | Dormitory – Scholarship (StaysIn)              | 1:N | — |
| 11 | Scholarship – Payment (Receives)               | 1:N | — |
| 12 | UserAccount – Feedback (Submits)               | 1:N | — |
| 13 | UserAccount – LoginSession (Has)               | 1:N | — |
| 14 | UserAccount – Notification (Receives)          | 1:N | — |
| 15 | UserAccount – Course (Belongs)                 | M:N | — |
| 16 | Course – CourseContent (Has)                   | 1:N | CourseContent is **weak entity** |
| 17 | Classroom – Course (HeldIn)                    | 1:N | **Total** on Course side |
| 18 | Course – Exam (Makes)                          | 1:N | Exam is **weak entity**, **Total** on Exam side |
| 19 | Course – Assignment (Contains)                 | 1:N | Assignment is **weak entity** |
| 20 | UserAccount – Library (Belongs)                | M:N | — |
| 21 | Library – Book (Receives)                      | 1:N | — |
| 22 | Publisher – Book (PublishBy)                   | 1:N | **Total** on Book side |
| 23 | Book – Review (Has)                            | 1:N | — |
| 24 | Student – Event (Arranges)                     | M:N | — |
| 25 | Student – Club (Joins)                         | M:N | — |
| 26 | Student – Transcript (Has)                     | 1:1 | **Total** on Student side |
| 27 | UserAccount – Student (OwnedBy)                | 1:1 | **Total** on Student side |
| 28 | UserAccount – Gym (Belongs)                    | M:N | — |
| 29 | Gym – Trainer (Has)                            | 1:N | **Total** on both sides |
| 30 | Gym – Equipment (Contains)                     | 1:N | — |

## Generalization / Specialization

- **Staff** is the superclass
- **Instructor** and **NonAcademicStaff** are subclasses
- Constraint: **Disjoint (d)** — a Staff member is either an Instructor or NonAcademicStaff, not both
