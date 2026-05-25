/* ============================================================================
   PHASE 3 - QUERIES
   University Management System
   DBMS: Microsoft SQL Server 2025

   File : queries/01_complex_queries.sql
   Contains 5 complex SELECT queries demonstrating:
     - INNER / LEFT OUTER JOINs
     - Aggregation functions  (COUNT, AVG, MAX)
     - GROUP BY / HAVING
     - Subqueries (correlated and non-correlated)
   ============================================================================ */


/* ────────────────────────────────────────────────────────────────────────────
   QUERY 1
   Title  : Student Enrollment Summary per Course
   Purpose: For each course, show the total number of enrolled users,
            the average exam score across all exams of that course, and
            the classroom it is held in.
   Techniques used:
     • INNER JOIN  – links Course → Classroom, Course → UserAccount_Course,
                     Course → Exam
     • LEFT JOIN   – keeps courses that have no exams (AverageScore is NULL
                     instead of dropping the course row)
     • COUNT()     – counts distinct enrolled users
     • AVG()       – averages exam scores per course
     • GROUP BY    – aggregates at course level
     • HAVING      – filters to courses with at least 1 enrolled user
                      (BUG FIX: was > 1, now > 0 so single-student courses appear)
   ──────────────────────────────────────────────────────────────────────────── */
SELECT
    c.CourseAccount                         AS Course,
    cl.ClassroomName                        AS Classroom,
    COUNT(DISTINCT uc.UserAccountId)        AS TotalEnrolled,
    AVG(e.AverageScore)                     AS AvgExamScore,
    MAX(e.AverageScore)                     AS HighestExamScore
FROM Course          AS c
INNER JOIN Classroom            AS cl ON cl.ClassroomId   = c.ClassroomId
INNER JOIN UserAccount_Course   AS uc ON uc.CourseAccount = c.CourseAccount
LEFT  JOIN Exam                 AS e  ON e.CourseAccount  = c.CourseAccount
GROUP BY c.CourseAccount, cl.ClassroomName
HAVING COUNT(DISTINCT uc.UserAccountId) > 0   -- BUG FIX: was > 1; now shows courses with ANY enrollment
ORDER BY TotalEnrolled DESC;


/* ────────────────────────────────────────────────────────────────────────────
   QUERY 2
   Title  : Full Student Profile with Scholarships, Internships & Clubs
   Purpose: Produce a comprehensive report card for every student, showing
            their department, any scholarship they hold, their internship
            company, and a count of clubs they belong to.
   Techniques used:
     • Chain of INNER JOINs – Student → UserAccount → Department
     • LEFT JOINs – students without scholarships / internships still appear
     • Subquery (scalar, correlated) – counts the clubs for each student
       inline without an extra GROUP BY on the outer query
   ──────────────────────────────────────────────────────────────────────────── */
SELECT
    s.StudentId,
    s.StudentName,
    ua.Username,
    ua.Email,
    d.DepartmentName,
    f.FacultyName,
    sc.Amount          AS ScholarshipAmount,
    sc.ValidityPeriod  AS ScholarshipPeriod,
    i.CompanyName      AS InternshipCompany,
    i.InternshipDuration AS InternshipDays,
    /* Correlated subquery: count clubs for this specific student */
    (
        SELECT COUNT(*)
        FROM   Student_Club AS sc2
        WHERE  sc2.StudentId = s.StudentId
    )                  AS ClubCount
FROM Student             AS s
INNER JOIN UserAccount           AS ua  ON ua.UserAccountId  = s.UserAccountId
INNER JOIN Department            AS d   ON d.DepartmentId    = ua.DepartmentId
INNER JOIN Faculty               AS f   ON f.FacultyId       = d.FacultyId
LEFT  JOIN UserAccount_Scholarship AS us ON us.UserAccountId = ua.UserAccountId
LEFT  JOIN Scholarship           AS sc  ON sc.ScholarshipId  = us.ScholarshipId
LEFT  JOIN Internship            AS i   ON i.UserAccountId   = ua.UserAccountId
ORDER BY s.StudentName;


/* ────────────────────────────────────────────────────────────────────────────
   QUERY 3
   Title  : Instructor Workload – Courses, Projects & Expertise Areas
   Purpose: Show each instructor together with their department, how many
            courses they teach, how many projects they supervise, and all
            their listed expertise areas.
   Techniques used:
     • INNER JOIN chain – Instructor → Staff → UserAccount → Department
     • LEFT JOINs – instructors with 0 courses / projects are still included
     • STRING_AGG()  – concatenates multiple expertise areas into one cell
     • COUNT()       – counts courses and projects per instructor
     • GROUP BY      – groups at instructor level
     • HAVING        – limits output to instructors with at least 1 expertise
   ──────────────────────────────────────────────────────────────────────────── */
SELECT
    st.StaffName                                       AS InstructorName,
    st.AcademicTitles,
    dep.DepartmentName,
    COUNT(DISTINCT uc.CourseAccount)                   AS CoursesTeaching,
    COUNT(DISTINCT p.ProjectId)                        AS ProjectsSupervised,
    STRING_AGG(iea.ExpertiseArea, ', ')
        WITHIN GROUP (ORDER BY iea.ExpertiseArea)      AS ExpertiseAreas
FROM Instructor             AS ins
INNER JOIN Staff             AS st   ON st.StaffId      = ins.StaffId
INNER JOIN Department        AS dep  ON dep.DepartmentId = ins.DepartmentId
INNER JOIN UserAccount       AS ua   ON ua.UserAccountId = st.UserAccountId
LEFT  JOIN UserAccount_Course AS uc  ON uc.UserAccountId = ua.UserAccountId
LEFT  JOIN Project            AS p   ON p.InstructorId   = ins.StaffId
LEFT  JOIN Instructor_ExpertiseArea AS iea ON iea.StaffId = ins.StaffId
GROUP BY st.StaffName, st.AcademicTitles, dep.DepartmentName
HAVING COUNT(iea.ExpertiseArea) >= 1
ORDER BY CoursesTeaching DESC;


/* ────────────────────────────────────────────────────────────────────────────
   QUERY 4
   Title  : Library Book Availability & Review Statistics
   Purpose: For each library, list every book with its authors, average
            rating, publisher details, and whether it is overdue (return
            date is in the past).
   Techniques used:
     • INNER JOINs – Book → Library, Book → Publisher
     • LEFT JOINs  – books with no reviews or no authors still appear
     • STRING_AGG() – aggregates multiple authors into one column
     • AVG()        – average review rating per book
     • COUNT()      – total reviews per book
     • CASE expression – derives an "Overdue" status flag
     • Subquery (non-correlated, in WHERE) – limits to libraries that
       have at least one registered user (active libraries only)
   ──────────────────────────────────────────────────────────────────────────── */
SELECT
    lib.LibraryName,
    b.BookName,
    b.BookType,
    b.ReturnDate,
    CASE
        WHEN b.ReturnDate < CAST(GETDATE() AS DATE) THEN 'OVERDUE'
        ELSE 'OK'
    END                                         AS ReturnStatus,
    pub.PublisherName,
    pub.PublisherCountry,
    STRING_AGG(ba.Author, ', ')
        WITHIN GROUP (ORDER BY ba.Author)        AS Authors,
    COUNT(r.ReviewId)                            AS TotalReviews,
    AVG(CAST(r.Rating AS DECIMAL(5,2)))          AS AvgRating,
    MAX(r.Rating)                                AS BestRating
FROM Library   AS lib
INNER JOIN Book      AS b   ON b.LibraryId   = lib.LibraryId
INNER JOIN Publisher AS pub ON pub.PublisherId = b.PublisherId
LEFT  JOIN Book_Author AS ba ON ba.BookId     = b.BookId
LEFT  JOIN Review      AS r  ON r.BookId      = b.BookId
WHERE lib.LibraryId IN (
    /* Non-correlated subquery: only active libraries used by at least 1 user */
    SELECT DISTINCT LibraryId
    FROM   UserAccount_Library
)
GROUP BY lib.LibraryName, b.BookName, b.BookType,
         b.ReturnDate, pub.PublisherName, pub.PublisherCountry
ORDER BY lib.LibraryName, AvgRating DESC;


/* ────────────────────────────────────────────────────────────────────────────
   QUERY 5
   Title  : Department-Level KPI Dashboard
   Purpose: High-level academic dashboard showing, per department and
            faculty, the number of students, instructors, active courses,
            and average scholarship amount granted to students in that dept.
   Techniques used:
     • Multiple INNER JOINs spanning Faculty → Department → UserAccount
     • LEFT JOINs – departments with no students / instructors still appear
     • Aggregation: COUNT(DISTINCT …), AVG()
     • Subquery (correlated) in SELECT clause – calculates the average
       scholarship amount only for students belonging to each department,
       without disturbing the outer GROUP BY
     • GROUP BY / HAVING – filters to departments with at least 1 course
   ──────────────────────────────────────────────────────────────────────────── */
SELECT
    f.FacultyName,
    d.DepartmentName,
    COUNT(DISTINCT s.StudentId)                 AS TotalStudents,
    COUNT(DISTINCT ins.StaffId)                 AS TotalInstructors,
    COUNT(DISTINCT uc.CourseAccount)            AS TotalCourses,
    /* Correlated subquery: avg scholarship for students in this department */
    (
        SELECT AVG(sc.Amount)
        FROM   UserAccount_Scholarship AS us2
        JOIN   Scholarship             AS sc  ON sc.ScholarshipId  = us2.ScholarshipId
        JOIN   UserAccount             AS ua2 ON ua2.UserAccountId = us2.UserAccountId
        WHERE  ua2.DepartmentId = d.DepartmentId
    )                                           AS AvgScholarshipAmount
FROM Faculty            AS f
INNER JOIN Department        AS d   ON d.FacultyId      = f.FacultyId
LEFT  JOIN UserAccount       AS ua  ON ua.DepartmentId  = d.DepartmentId
LEFT  JOIN Student           AS s   ON s.UserAccountId  = ua.UserAccountId
LEFT  JOIN Instructor        AS ins ON ins.DepartmentId = d.DepartmentId
LEFT  JOIN UserAccount_Course AS uc ON uc.UserAccountId = ua.UserAccountId
GROUP BY f.FacultyName, d.DepartmentName
HAVING COUNT(DISTINCT uc.CourseAccount) >= 1
ORDER BY f.FacultyName, TotalStudents DESC;

-- END OF QUERIES FILE
