/* ============================================================================
   PHASE 3 - VIEWS
   University Management System
   DBMS: Microsoft SQL Server 2025

   File : views/01_views.sql
   Contains 2 complex Views:
     1. vw_StudentAcademicReport  – per-student academic overview
     2. vw_CourseEnrollmentReport – per-course enrollment and performance
   ============================================================================ */

GO
/* ────────────────────────────────────────────────────────────────────────────
   VIEW 1
   Name    : vw_StudentAcademicReport
   Purpose : Provides a single, denormalized view of every student's complete
             academic profile.  Consumers (reporting tools, dashboards) can
             query this view like a simple table without knowing the underlying
             join complexity.

   Tables joined:
     Student → UserAccount → Department → Faculty
     Transcript (LEFT JOIN – not all students may have a transcript yet)
     UserAccount_Scholarship → Scholarship (LEFT JOIN)
     Internship (LEFT JOIN – some students have no internship)

   Computed columns:
     • dbo.fn_GetStudentGPA()        – extracted GPA via Phase 3 UDF
     • dbo.fn_GetTotalScholarship()  – total scholarship via Phase 3 UDF
     • Age                           – computed column from Student table
     • InternshipDuration            – computed column from Internship table

   Why a View and not a query?
     Views hide complexity from application developers and business analysts.
     Security can be applied at the view level (GRANT SELECT ON view, not on
     base tables), and query execution plans are cached.
   ──────────────────────────────────────────────────────────────────────────── */
CREATE OR ALTER VIEW dbo.vw_StudentAcademicReport
AS
SELECT
    s.StudentId,
    s.StudentName,
    s.BirthDate,
    s.Age                                   AS AgeYears,
    ua.Username,
    ua.Email,
    d.DepartmentName,
    f.FacultyName,
    t.ScoreInfo                             AS TranscriptRaw,
    dbo.fn_GetStudentGPA(s.StudentId)       AS GPA,
    dbo.fn_GetTotalScholarship(ua.UserAccountId) AS TotalScholarship,
    sc.ValidityPeriod                       AS ScholarshipPeriod,
    i.CompanyName                           AS InternshipCompany,
    i.StartDate                             AS InternshipStart,
    i.EndDate                               AS InternshipEnd,
    i.InternshipDuration                    AS InternshipDays,
    ir.ReportGrade                          AS InternshipGrade
FROM Student               AS s
INNER JOIN UserAccount     AS ua  ON ua.UserAccountId  = s.UserAccountId
INNER JOIN Department      AS d   ON d.DepartmentId    = ua.DepartmentId
INNER JOIN Faculty         AS f   ON f.FacultyId       = d.FacultyId
LEFT  JOIN Transcript      AS t   ON t.StudentId       = s.StudentId
LEFT  JOIN UserAccount_Scholarship AS us
                           ON us.UserAccountId = ua.UserAccountId
LEFT  JOIN Scholarship     AS sc  ON sc.ScholarshipId  = us.ScholarshipId
LEFT  JOIN Internship      AS i   ON i.UserAccountId   = ua.UserAccountId
LEFT  JOIN InternshipReport AS ir ON ir.InternshipId   = i.InternshipId;
GO


/* ────────────────────────────────────────────────────────────────────────────
   VIEW 2
   Name    : vw_CourseEnrollmentReport
   Purpose : A management-level reporting view showing, for every course,
             its classroom, the instructor(s) teaching it, total enrolled
             users, number of exams, average exam score, upcoming assignments
             (due date in the future), and the book resources available in
             the linked library / classroom department.

   Tables joined:
     Course → Classroom
     UserAccount_Course (LEFT JOIN) → UserAccount (LEFT JOIN) → Student (LEFT JOIN)
     UserAccount_Course → Instructor (inferred via UserAccount)
     Exam (LEFT JOIN)
     Assignment (LEFT JOIN, filtered to upcoming)
     Classroom.ClassroomDepart → Library (LEFT JOIN via matching LibraryName pattern)

   Aggregations:
     • COUNT(DISTINCT enrolled users)   → TotalEnrolled
     • COUNT(DISTINCT student rows)     → TotalStudents
     • AVG(exam score)                  → AvgExamScore
     • COUNT(upcoming assignments)      → UpcomingAssignments

   Why a View?
     Department heads and registrars can SELECT from this view to monitor
     course health without writing complex JOIN chains every time.
   ──────────────────────────────────────────────────────────────────────────── */
CREATE OR ALTER VIEW dbo.vw_CourseEnrollmentReport
AS
SELECT
    c.CourseAccount,
    cl.ClassroomName,
    cl.ClassroomDepart,
    COUNT(DISTINCT uc.UserAccountId)             AS TotalEnrolled,
    COUNT(DISTINCT s.StudentId)                  AS TotalStudents,
    COUNT(DISTINCT e.ExamId)                     AS TotalExams,
    AVG(e.AverageScore)                          AS AvgExamScore,
    MAX(e.AverageScore)                          AS BestExamScore,
    COUNT(DISTINCT
        CASE
            WHEN a.DueDate >= CAST(GETDATE() AS DATE)
            THEN CAST(a.AssignmentId AS VARCHAR(10)) + a.CourseAccount
        END
    )                                            AS UpcomingAssignments
FROM Course             AS c
INNER JOIN Classroom          AS cl ON cl.ClassroomId   = c.ClassroomId
LEFT  JOIN UserAccount_Course AS uc ON uc.CourseAccount = c.CourseAccount
LEFT  JOIN UserAccount        AS ua ON ua.UserAccountId = uc.UserAccountId
LEFT  JOIN Student            AS s  ON s.UserAccountId  = ua.UserAccountId
LEFT  JOIN Exam               AS e  ON e.CourseAccount  = c.CourseAccount
LEFT  JOIN Assignment         AS a  ON a.CourseAccount  = c.CourseAccount
GROUP BY
    c.CourseAccount,
    cl.ClassroomName,
    cl.ClassroomDepart;
GO

-- END OF VIEWS FILE
