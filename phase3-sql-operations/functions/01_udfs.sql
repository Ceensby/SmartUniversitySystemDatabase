/* ============================================================================
   PHASE 3 - USER-DEFINED FUNCTIONS
   University Management System
   DBMS: Microsoft SQL Server 2025

   File : functions/01_udfs.sql
   Contains 2 User-Defined Functions:
     1. fn_GetStudentGPA          – scalar UDF
     2. fn_GetTotalScholarship    – scalar UDF
   ============================================================================ */

GO
/* ────────────────────────────────────────────────────────────────────────────
   FUNCTION 1
   Name    : fn_GetStudentGPA
   Type    : Scalar UDF
   Returns : DECIMAL(4,2)

   Purpose :
     Parses the Transcript.ScoreInfo column for a given student and extracts
     the GPA value that was stored as part of the free-text string
     (e.g. 'GPA: 3.45, Total Credits: 90'  OR  'GPA: 3.45' with no comma).

     FIX (v2): NULLIF + ISNULL guard ensures SUBSTRING never receives a
     zero or negative length when the comma is absent in ScoreInfo.

   Why a UDF?
     • The GPA is embedded in a VARCHAR column – this logic would need to be
       repeated in every query that displays it.  A UDF centralises the
       parsing so future schema changes (e.g. a dedicated GPA column) only
       require one edit.
     • It can be called inline: SELECT dbo.fn_GetStudentGPA(1)
   ──────────────────────────────────────────────────────────────────────────── */
CREATE OR ALTER FUNCTION dbo.fn_GetStudentGPA
(
    @StudentId INT          -- PK of the Student whose GPA we want
)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @ScoreInfo  VARCHAR(500);
    DECLARE @GpaStart   INT;
    DECLARE @GpaEnd     INT;
    DECLARE @GpaString  VARCHAR(20);
    DECLARE @GPA        DECIMAL(4,2);

    -- Fetch the raw score string for this student
    SELECT @ScoreInfo = ScoreInfo
    FROM   Transcript
    WHERE  StudentId = @StudentId;

    -- If no transcript exists, return -1 as a sentinel value
    IF @ScoreInfo IS NULL
        RETURN -1;

    -- Locate 'GPA: ' prefix position
    SET @GpaStart = CHARINDEX('GPA: ', @ScoreInfo);

    -- If 'GPA: ' token is not found at all, return -1
    IF @GpaStart = 0
        RETURN -1;

    -- BUG FIX: CHARINDEX returns 0 when the comma is absent.
    -- NULLIF(0, 0) converts that 0 → NULL.
    -- ISNULL(..., LEN(@ScoreInfo) + 1) then falls back to one position
    -- past the end of the string, so SUBSTRING gets a valid positive length
    -- regardless of whether a comma exists.
    SET @GpaEnd = ISNULL(
                      NULLIF(CHARINDEX(',', @ScoreInfo, @GpaStart), 0),
                      LEN(@ScoreInfo) + 1
                  );

    -- Extract just the numeric part, e.g. '3.45'
    SET @GpaString = LTRIM(RTRIM(
                         SUBSTRING(
                             @ScoreInfo,
                             @GpaStart + LEN('GPA: '),
                             @GpaEnd - (@GpaStart + LEN('GPA: '))
                         )
                     ));

    -- Safely convert; if the string is not numeric return -1
    IF ISNUMERIC(@GpaString) = 1
        SET @GPA = CAST(@GpaString AS DECIMAL(4,2));
    ELSE
        SET @GPA = -1;

    RETURN @GPA;
END;
GO


/* ────────────────────────────────────────────────────────────────────────────
   FUNCTION 2
   Name    : fn_GetTotalScholarship
   Type    : Scalar UDF
   Returns : DECIMAL(12,2)

   Purpose :
     Calculates the total scholarship money a specific user (student or
     staff member) has received.  It joins UserAccount_Scholarship with
     Scholarship to sum the Amount column for that user.

   Why a UDF?
     • Encapsulates the multi-table join for scholarship totalling, which
       is needed in the Stored Procedures, views, and ad-hoc queries.
     • Keeps the SELECT list of calling queries clean and readable.
     • Can be reused in CHECK-style logic or reporting without duplication.
   ──────────────────────────────────────────────────────────────────────────── */
CREATE OR ALTER FUNCTION dbo.fn_GetTotalScholarship
(
    @UserAccountId INT       -- PK of the UserAccount to sum scholarships for
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Total DECIMAL(12,2);

    SELECT @Total = SUM(sc.Amount)
    FROM   UserAccount_Scholarship AS us
    JOIN   Scholarship             AS sc ON sc.ScholarshipId = us.ScholarshipId
    WHERE  us.UserAccountId = @UserAccountId;

    -- SUM of an empty set is NULL; normalise to 0.00
    RETURN ISNULL(@Total, 0.00);
END;
GO

-- END OF FUNCTIONS FILE
