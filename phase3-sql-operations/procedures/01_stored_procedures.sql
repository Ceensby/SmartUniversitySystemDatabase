/* ============================================================================
   PHASE 3 - STORED PROCEDURES
   University Management System
   DBMS: Microsoft SQL Server 2025

   File : procedures/01_stored_procedures.sql
   Contains 2 Stored Procedures:
     1. sp_EnrollStudentInCourse   – validates and inserts enrollment
     2. sp_ProcessScholarship      – awards/updates scholarship for a user
   ============================================================================ */

GO
/* ────────────────────────────────────────────────────────────────────────────
   PROCEDURE 1
   Name    : sp_EnrollStudentInCourse
   Purpose : Safely enroll a user account into a course.

   Business Rules enforced inside the procedure:
     1. The UserAccount must exist – if not, raise an error and stop.
     2. The Course must exist    – if not, raise an error and stop.
     3. Duplicate enrollment must be prevented (UNIQUE constraint on the
        junction table would also catch this, but an early check gives a
        friendlier error message).
     4. On success, log a Notification to the user's account.

   Parameters:
     @UserAccountId  INT   IN   – the user to enroll
     @CourseAccount  VARCHAR(100) IN  – the target course
     @RowsAffected   INT   OUT  – 1 if enrollment succeeded, 0 otherwise
   ──────────────────────────────────────────────────────────────────────────── */
CREATE OR ALTER PROCEDURE dbo.sp_EnrollStudentInCourse
    @UserAccountId   INT,
    @CourseAccount   VARCHAR(100),
    @RowsAffected    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Default output: assume failure
    SET @RowsAffected = 0;

    -- ── Rule 1: Verify the UserAccount exists ────────────────────────────────
    IF NOT EXISTS (
        SELECT 1 FROM UserAccount WHERE UserAccountId = @UserAccountId
    )
    BEGIN
        RAISERROR('UserAccount ID %d does not exist.', 16, 1, @UserAccountId);
        RETURN;
    END;

    -- ── Rule 2: Verify the Course exists ────────────────────────────────────
    IF NOT EXISTS (
        SELECT 1 FROM Course WHERE CourseAccount = @CourseAccount
    )
    BEGIN
        RAISERROR('Course "%s" does not exist.', 16, 1, @CourseAccount);
        RETURN;
    END;

    -- ── Rule 3: Check for duplicate enrollment ───────────────────────────────
    IF EXISTS (
        SELECT 1
        FROM   UserAccount_Course
        WHERE  UserAccountId = @UserAccountId
          AND  CourseAccount = @CourseAccount
    )
    BEGIN
        RAISERROR('UserAccount ID %d is already enrolled in course "%s".',
                  16, 1, @UserAccountId, @CourseAccount);
        RETURN;
    END;

    -- ── Enroll the user ──────────────────────────────────────────────────────
    BEGIN TRY
        BEGIN TRANSACTION;

            INSERT INTO UserAccount_Course (UserAccountId, CourseAccount)
            VALUES (@UserAccountId, @CourseAccount);

            -- Rule 4: Notify the user of their successful enrollment
            INSERT INTO Notification (NotificationContent, UserAccountId)
            VALUES (
                'You have been successfully enrolled in: ' + @CourseAccount,
                @UserAccountId
            );

        COMMIT TRANSACTION;
        SET @RowsAffected = 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;          -- Re-raise the original error to the caller
    END CATCH;
END;
GO


/* ────────────────────────────────────────────────────────────────────────────
   PROCEDURE 2
   Name    : sp_ProcessScholarship
   Purpose : Award a new scholarship to a user, OR update the amount of an
             existing scholarship that they already hold.

   Business Rules:
     1. UserAccount must exist.
     2. Scholarship must exist.
     3. IF the user already has this scholarship → UPDATE the Scholarship
        amount by adding @AdditionalAmount to it (e.g. renewal/top-up).
     4. IF the user does not yet have this scholarship → INSERT a new row
        into UserAccount_Scholarship and create a Payment record.
     5. CompletionRate must be between 0 and 100 – if the scholarship row
        already has a CompletionRate < 60, block the award (minimum
        academic standing requirement).

   Parameters:
     @UserAccountId    INT    IN   – recipient
     @ScholarshipId    INT    IN   – scholarship to award
     @AdditionalAmount DECIMAL IN  – extra money for renewal scenario
     @Action           VARCHAR OUT – describes what the procedure did
   ──────────────────────────────────────────────────────────────────────────── */
CREATE OR ALTER PROCEDURE dbo.sp_ProcessScholarship
    @UserAccountId    INT,
    @ScholarshipId    INT,
    @AdditionalAmount DECIMAL(10,2) = 0,
    @Action           VARCHAR(200)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CompletionRate DECIMAL(5,2);
    DECLARE @CurrentAmount  DECIMAL(10,2);

    -- ── Rule 1: Verify UserAccount ───────────────────────────────────────────
    IF NOT EXISTS (SELECT 1 FROM UserAccount WHERE UserAccountId = @UserAccountId)
    BEGIN
        RAISERROR('UserAccount ID %d does not exist.', 16, 1, @UserAccountId);
        RETURN;
    END;

    -- ── Rule 2: Verify Scholarship and read eligibility data ─────────────────
    SELECT @CompletionRate = CompletionRate,
           @CurrentAmount  = Amount
    FROM   Scholarship
    WHERE  ScholarshipId = @ScholarshipId;

    IF @CompletionRate IS NULL      -- scholarship row not found
    BEGIN
        RAISERROR('Scholarship ID %d does not exist.', 16, 1, @ScholarshipId);
        RETURN;
    END;

    -- ── Rule 5: Academic standing check ─────────────────────────────────────
    IF @CompletionRate < 60.00
    BEGIN
        SET @Action = 'BLOCKED – CompletionRate (' +
                      CAST(@CompletionRate AS VARCHAR(10)) +
                      '%) is below the required 60%.';
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ── Rule 3 vs 4: Existing holder → update; new holder → insert ───────
        IF EXISTS (
            SELECT 1
            FROM   UserAccount_Scholarship
            WHERE  UserAccountId = @UserAccountId
              AND  ScholarshipId = @ScholarshipId
        )
        BEGIN
            -- Top-up the scholarship amount
            UPDATE Scholarship
            SET    Amount = Amount + @AdditionalAmount
            WHERE  ScholarshipId = @ScholarshipId;

            SET @Action = 'UPDATED – scholarship amount increased by ' +
                          CAST(@AdditionalAmount AS VARCHAR(20)) + ' for UserAccountId ' +
                          CAST(@UserAccountId AS VARCHAR(10));
        END
        ELSE
        BEGIN
            -- Award the scholarship for the first time
            INSERT INTO UserAccount_Scholarship (UserAccountId, ScholarshipId)
            VALUES (@UserAccountId, @ScholarshipId);

            -- Create a corresponding payment record
            INSERT INTO Payment (PaymentAmount, ScholarshipId)
            VALUES (@CurrentAmount, @ScholarshipId);

            SET @Action = 'AWARDED – scholarship ' + CAST(@ScholarshipId AS VARCHAR(10)) +
                          ' granted to UserAccountId ' + CAST(@UserAccountId AS VARCHAR(10));
        END;

        -- Notify the recipient
        INSERT INTO Notification (NotificationContent, UserAccountId)
        VALUES ('Scholarship update: ' + @Action, @UserAccountId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- END OF PROCEDURES FILE
