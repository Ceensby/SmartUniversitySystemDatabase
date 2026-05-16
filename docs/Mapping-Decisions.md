# ER → Relational Mapping Decisions

This document records the design decisions made when converting the EER diagram
into relational tables (following Chapter 9: ER-to-Relational Mapping).

## 1. Strong Entities

Each strong entity becomes its own table with its declared primary key:

Faculty, Department, UserAccount, Student, Staff, Project, Transcript,
Classroom, Course, Library, Publisher, Book, Review, Club, Event, Gym,
Trainer, Equipment, Dormitory, Scholarship, Payment, Internship,
InternshipReport, Feedback, LoginSession, Notification.

## 2. Weak Entities

Weak entities use a composite primary key consisting of the owner's PK plus a
partial key, with `ON DELETE CASCADE` on the FK to the owner:

| Weak Entity   | Owner   | Partial Key      | Composite PK                       |
|---------------|---------|------------------|------------------------------------|
| CourseContent | Course  | LectureId        | (CourseAccount, LectureId)         |
| Exam          | Course  | ExamId           | (CourseAccount, ExamId)            |
| Assignment    | Course  | AssignmentId     | (CourseAccount, AssignmentId)      |

## 3. 1:1 Relationships → FK + UNIQUE

| Relationship                    | FK placed on  | UNIQUE? | NOT NULL? (total side) |
|---------------------------------|---------------|---------|------------------------|
| Student – UserAccount           | Student       | ✓       | ✓ (Student is total)   |
| Staff – UserAccount             | Staff         | ✓       | ✓                      |
| Student – Transcript            | Transcript    | ✓       | ✓ (Student is total)   |
| Internship – InternshipReport   | InternshipReport | ✓    | ✓                      |

## 4. 1:N Relationships → FK on the N side

| Relationship                  | FK placed on   | NOT NULL? |
|-------------------------------|----------------|-----------|
| Faculty – Department          | Department     | ✓ (total) |
| Department – UserAccount      | UserAccount    | —         |
| Instructor – Project          | Project        | —         |
| Classroom – Course            | Course         | ✓ (total on Course) |
| Publisher – Book              | Book           | ✓ (total on Book) |
| Library – Book                | Book           | —         |
| Book – Review                 | Review         | —         |
| Gym – Trainer                 | Trainer        | ✓ (total both) |
| Gym – Equipment               | Equipment      | —         |
| Dormitory – Scholarship       | Scholarship    | —         |
| Scholarship – Payment         | Payment        | —         |
| UserAccount – Internship      | Internship     | —         |
| UserAccount – Feedback        | Feedback       | —         |
| UserAccount – LoginSession    | LoginSession   | —         |
| UserAccount – Notification    | Notification   | —         |

## 5. M:N Relationships → Junction Tables

| Relationship                | Junction Table             | Composite PK                   |
|-----------------------------|----------------------------|--------------------------------|
| UserAccount ⨯ Scholarship   | UserAccount_Scholarship    | (UserAccountId, ScholarshipId) |
| UserAccount ⨯ Course        | UserAccount_Course         | (UserAccountId, CourseAccount) |
| UserAccount ⨯ Library       | UserAccount_Library        | (UserAccountId, LibraryId)     |
| UserAccount ⨯ Gym           | UserAccount_Gym            | (UserAccountId, GymId)         |
| Student ⨯ Event             | Student_Event              | (StudentId, EventTag)          |
| Student ⨯ Club              | Student_Club               | (StudentId, ClubId)            |

## 6. Multivalued Attributes → Separate Tables

| Owner Entity      | Multivalued Attribute | Table Name                     |
|-------------------|------------------------|-------------------------------|
| Instructor        | ExpertiseArea          | Instructor_ExpertiseArea       |
| NonAcademicStaff  | PhoneNumber            | NonAcademicStaff_PhoneNumber   |
| Equipment         | TargetMuscle           | Equipment_TargetMuscle         |
| Student           | PhoneNumber            | Student_PhoneNumber            |
| Book              | Author                 | Book_Author                    |
| Assignment        | AssignmentTitle        | Assignment_Title               |
| Dormitory         | DormitoryPhone         | Dormitory_Phone                |
| Gym               | RegistrationNumber     | Gym_RegistrationNumber         |

## 7. Derived Attributes → Computed Columns

| Entity      | Attribute           | Computation                                   |
|-------------|---------------------|-----------------------------------------------|
| Student     | Age                 | `DATEDIFF(YEAR, BirthDate, GETDATE())`        |
| Internship  | InternshipDuration  | `DATEDIFF(DAY, StartDate, EndDate)`           |

Note: `Scholarship.CompletionRate` is stored as a regular DECIMAL column,
not derived.

## 8. Specialization (Disjoint)

`Staff` is the superclass. `Instructor` and `NonAcademicStaff` are subclasses
with the **disjoint** constraint.

The mapping uses the **shared-PK approach**:
- Each subclass table has `StaffId` as both its primary key AND a foreign key
  back to `Staff.StaffId`, with `ON DELETE CASCADE`.
- This guarantees that a subclass row cannot exist without its corresponding
  Staff row.
- The disjoint constraint itself is enforced at the application level (or
  optionally via a trigger in Phase 3).
