/* ============================================================================
   PHASE 3 - TRIGGERS
   University Management System
   DBMS: Microsoft SQL Server 2025

   File : triggers/01_triggers.sql
   Contains 5 Triggers:

     1. trg_PreventInternshipDateOverlap  – INSTEAD OF INSERT on Internship
     2. trg_AuditUserAccountChanges       – AFTER UPDATE on UserAccount
     3. trg_ValidateExamScore             – AFTER INSERT, UPDATE on Exam
     4. trg_AutoNotifyNewEnrollment       – AFTER INSERT on UserAccount_Course
     5. trg_PreventNegativeScholarship    – AFTER INSERT, UPDATE on Scholarship
   ============================================================================ */


/* ──────────────────────────────────────────────────────────────────────────────
   TRIGGER 1
   Name   : trg_PreventInternshipDateOverlap
   Table  : Internship
   Event  : INSTEAD OF INSERT

   Business Rule:
     A user may not have two overlapping internships.  If a new internship's
     [StartDate, EndDate] period overlaps with any existing internship for the
     same UserAccountId, the INSERT is blocked and an error is raised.

   Why INSTEAD OF?
     An AFTER trigger fires after the row is already written; if we want to
     completely prevent the row from being stored, INSTEAD OF is the correct
     choice – it replaces the DML operation itself.
   ────────────────────────────────────────────────────────────────────────────── */
GO
CREATE OR ALTER TRIGGER dbo.trg_PreventInternshipDateOverlap
ON Internship
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check whether any inserted row overlaps an existing internship
    IF EXISTS (
        SELECT 1
        FROM   inserted       AS i
        JOIN   Internship     AS ex ON ex.UserAccountId = i.UserAccountId
        WHERE  i.StartDate  <= ex.EndDate          -- new starts before old ends
          AND  i.EndDate    >= ex.StartDate         -- new ends after old starts
    )
    BEGIN
        -- Overlap detected: raise an error and abort without writing any row
        RAISERROR(
            'TRIGGER trg_PreventInternshipDateOverlap: '
            + 'Internship dates overlap with an existing internship for this user.',
            16, 1
        );
        RETURN;
    END
    ELSE
    BEGIN
        -- BUG FIX: No overlap found – the original code ended here without
        -- saving the data.  INSTEAD OF triggers completely replace the DML
        -- operation, so we MUST re-issue the INSERT ourselves.
        INSERT INTO Internship (CompanyName, StartDate, EndDate, UserAccountId)
        SELECT CompanyName, StartDate, EndDate, UserAccountId
        FROM   inserted;
    END;
END;
GO


/* ──────────────────────────────────────────────────────────────────────────────
   TRIGGER 2
   Name   : trg_AuditUserAccountChanges
   Table  : UserAccount
   Event  : AFTER UPDATE

   Business Rule / Automation:
     Whenever a UserAccount row is modified (e.g. email or department change),
     a Notification is automatically sent to that user recording exactly what
     was changed and when.  This creates a lightweight audit trail visible to
     the user in the Notification table.

   Why AFTER?
     The audit entry should only be created after a successful update.
     AFTER ensures the UPDATE has already committed; if the UPDATE rolls back,
     the notification never appears.
   ────────────────────────────────────────────────────────────────────────────── */
GO
CREATE OR ALTER TRIGGER dbo.trg_AuditUserAccountChanges
ON UserAccount
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- For each updated row, insert one notification row
    INSERT INTO Notification (NotificationContent, UserAccountId)
    SELECT
        'Account updated on ' + CONVERT(VARCHAR(20), GETDATE(), 120) +
        '. Old email: ' + ISNULL(d.Email, 'N/A') +
        ' → New email: ' + ISNULL(i.Email, 'N/A'),
        i.UserAccountId
    FROM inserted AS i
    JOIN deleted  AS d ON d.UserAccountId = i.UserAccountId;
END;
GO


/* ──────────────────────────────────────────────────────────────────────────────
   TRIGGER 3
   Name   : trg_ValidateExamScore
   Table  : Exam
   Event  : AFTER INSERT, UPDATE

   Business Rule:
     AverageScore on any Exam must be between 0.00 and 100.00 (inclusive).
     If an out-of-range value is inserted or updated, the transaction is
     rolled back and a descriptive error is raised.

   Why AFTER with ROLLBACK?
     We use AFTER so we can inspect the values that SQL Server would have
     written; we then roll back if they are invalid.  This is a common
     pattern for data validation triggers in SQL Server.
   ────────────────────────────────────────────────────────────────────────────── */
GO
CREATE OR ALTER TRIGGER dbo.trg_ValidateExamScore
ON Exam
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM   inserted
        WHERE  AverageScore IS NOT NULL
          AND  (AverageScore < 0 OR AverageScore > 100)
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR(
            'TRIGGER trg_ValidateExamScore: ' +
            'AverageScore must be between 0 and 100.',
            16, 1
        );
        RETURN;
    END;
END;
GO


/* ──────────────────────────────────────────────────────────────────────────────
   TRIGGER 4
   Name   : trg_AutoNotifyNewEnrollment
   Table  : UserAccount_Course
   Event  : AFTER INSERT

   Business Rule / Automation:
     Whenever a user is enrolled in a course (a row is added to the
     UserAccount_Course junction table), the system automatically creates
     a notification for that user.  This automates the confirmation message
     without requiring the application layer to do it explicitly.

   Why AFTER INSERT?
     We only want to notify on successful enrollments.  AFTER INSERT fires
     only when the row has already been committed.
   ────────────────────────────────────────────────────────────────────────────── */
GO
CREATE OR ALTER TRIGGER dbo.trg_AutoNotifyNewEnrollment
ON UserAccount_Course
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notification (NotificationContent, UserAccountId)
    SELECT
        'You have been enrolled in course: ' + i.CourseAccount +
        ' on ' + CONVERT(VARCHAR(20), GETDATE(), 120),
        i.UserAccountId
    FROM inserted AS i;
END;
GO


/* ──────────────────────────────────────────────────────────────────────────────
   TRIGGER 5
   Name   : trg_PreventNegativeScholarship
   Table  : Scholarship
   Event  : AFTER INSERT, UPDATE

   Business Rule:
     • The Amount of any scholarship cannot be negative or zero.
     • The CompletionRate must be between 0.00 and 100.00.
     If either constraint is violated the transaction is rolled back.

   Why AFTER with ROLLBACK?
     CHECK constraints on columns could handle simple range checks, but
     using a trigger allows a richer, combined validation with a meaningful
     error message and the option to log the violation in the future.
   ────────────────────────────────────────────────────────────────────────────── */
GO
CREATE OR ALTER TRIGGER dbo.trg_PreventNegativeScholarship
ON Scholarship
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate Amount
    IF EXISTS (
        SELECT 1 FROM inserted WHERE Amount IS NOT NULL AND Amount <= 0
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR(
            'TRIGGER trg_PreventNegativeScholarship: ' +
            'Scholarship Amount must be greater than 0.',
            16, 1
        );
        RETURN;
    END;

    -- Validate CompletionRate
    IF EXISTS (
        SELECT 1
        FROM   inserted
        WHERE  CompletionRate IS NOT NULL
          AND  (CompletionRate < 0 OR CompletionRate > 100)
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR(
            'TRIGGER trg_PreventNegativeScholarship: ' +
            'CompletionRate must be between 0 and 100.',
            16, 1
        );
        RETURN;
    END;
END;
GO

-- END OF TRIGGERS FILE
