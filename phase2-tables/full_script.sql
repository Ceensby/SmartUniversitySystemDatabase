/* ============================================================================
   PROJECT: University Management System
   PHASE 2: Table Creation + Sample Records  (v2)

/* ============================================================================
   SECTION 1: STRONG ENTITIES (parent tables first, no dependencies)
   ============================================================================ */

-- 1. FACULTY
CREATE TABLE Faculty (
    FacultyId   INT IDENTITY(1,1) PRIMARY KEY,
    FacultyName VARCHAR(100) NOT NULL,
    DeanName    VARCHAR(100)
);

-- 2. DEPARTMENT  (Faculty 1:N Department, total participation on both sides)
CREATE TABLE Department (
    DepartmentId   INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    FacultyId      INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculty(FacultyId)
);

-- 3. USER ACCOUNT  (Department 1:N UserAccount)
CREATE TABLE UserAccount (
    UserAccountId INT IDENTITY(1,1) PRIMARY KEY,
    Username      VARCHAR(50)  NOT NULL UNIQUE,
    Password      VARCHAR(100) NOT NULL,
    Email         VARCHAR(100) UNIQUE,
    DepartmentId  INT,
    FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId)
);

-- 4. STUDENT  (UserAccount 1:1 Student, total on Student side)
--    StudentPhone moved to separate Student_PhoneNumber table (multivalued)
--    Age is DERIVED -> computed column
CREATE TABLE Student (
    StudentId     INT IDENTITY(1,1) PRIMARY KEY,
    StudentName   VARCHAR(100) NOT NULL,
    BirthDate     DATE,
    Age           AS DATEDIFF(YEAR, BirthDate, GETDATE()),
    UserAccountId INT NOT NULL UNIQUE,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

-- 5. STAFF  (Superclass, Staff 1:1 UserAccount)
CREATE TABLE Staff (
    StaffId        INT IDENTITY(1,1) PRIMARY KEY,
    StaffName      VARCHAR(100) NOT NULL,
    AcademicTitles VARCHAR(100),
    UserAccountId  INT NOT NULL UNIQUE,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

-- 6. INSTRUCTOR  (Subclass of Staff, DISJOINT) -- shared PK with Staff
CREATE TABLE Instructor (
    StaffId      INT PRIMARY KEY,
    DepartmentId INT,
    FOREIGN KEY (StaffId)      REFERENCES Staff(StaffId)            ON DELETE CASCADE,
    FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId)
);

-- 7. NON-ACADEMIC STAFF  (Subclass of Staff, DISJOINT) -- shared PK with Staff
CREATE TABLE NonAcademicStaff (
    StaffId   INT PRIMARY KEY,
    Workplace VARCHAR(100),
    FOREIGN KEY (StaffId) REFERENCES Staff(StaffId) ON DELETE CASCADE
);

-- 8. PROJECT  (Instructor 1:N Project)
CREATE TABLE Project (
    ProjectId      INT IDENTITY(1,1) PRIMARY KEY,
    ProjectContent VARCHAR(500),
    InstructorId   INT,
    FOREIGN KEY (InstructorId) REFERENCES Instructor(StaffId)
);

-- 9. TRANSCRIPT  (Student 1:1 Transcript, total on Student side)
CREATE TABLE Transcript (
    TranscriptId INT IDENTITY(1,1) PRIMARY KEY,
    ScoreInfo    VARCHAR(500),
    StudentId    INT NOT NULL UNIQUE,
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
);

-- 10. CLASSROOM
CREATE TABLE Classroom (
    ClassroomId      INT IDENTITY(1,1) PRIMARY KEY,
    ClassroomName    VARCHAR(50)  NOT NULL,
    ClassroomDepart  VARCHAR(50)
);

-- 11. COURSE  (PK = CourseAccount; Classroom 1:N Course, total on Course side)
CREATE TABLE Course (
    CourseAccount VARCHAR(100) PRIMARY KEY,   -- text PK per spec
    ClassroomId   INT NOT NULL,
    FOREIGN KEY (ClassroomId) REFERENCES Classroom(ClassroomId)
);

-- 12. COURSE CONTENT  (WEAK, owner = Course; partial key = LectureId)
CREATE TABLE CourseContent (
    CourseAccount VARCHAR(100) NOT NULL,
    LectureId     INT NOT NULL,
    LectureName   VARCHAR(100),
    PRIMARY KEY (CourseAccount, LectureId),
    FOREIGN KEY (CourseAccount) REFERENCES Course(CourseAccount) ON DELETE CASCADE
);

-- 13. EXAM  (WEAK, owner = Course; partial key = ExamId; total on Exam side)
CREATE TABLE Exam (
    CourseAccount VARCHAR(100) NOT NULL,
    ExamId        INT NOT NULL,
    AverageScore  DECIMAL(5,2),
    PRIMARY KEY (CourseAccount, ExamId),
    FOREIGN KEY (CourseAccount) REFERENCES Course(CourseAccount) ON DELETE CASCADE
);

-- 14. ASSIGNMENT  (WEAK, owner = Course; partial key = AssignmentId)
--     AssignmentTitle is multivalued -> moved to Assignment_Title table
CREATE TABLE Assignment (
    CourseAccount VARCHAR(100) NOT NULL,
    AssignmentId  INT NOT NULL,
    DueDate       DATE,
    PRIMARY KEY (CourseAccount, AssignmentId),
    FOREIGN KEY (CourseAccount) REFERENCES Course(CourseAccount) ON DELETE CASCADE
);

-- 15. LIBRARY
CREATE TABLE Library (
    LibraryId   INT IDENTITY(1,1) PRIMARY KEY,
    LibraryName VARCHAR(100) NOT NULL
);

-- 16. PUBLISHER
CREATE TABLE Publisher (
    PublisherId      INT IDENTITY(1,1) PRIMARY KEY,
    PublisherName    VARCHAR(100) NOT NULL,
    PublisherCountry VARCHAR(50)
);

-- 17. BOOK  (Publisher 1:N Book, total on Book side; Library 1:N Book)
CREATE TABLE Book (
    BookId      INT IDENTITY(1,1) PRIMARY KEY,
    BookName    VARCHAR(200) NOT NULL,
    BookType    VARCHAR(50),
    ReturnDate  DATE,
    PublisherId INT NOT NULL,
    LibraryId   INT,
    FOREIGN KEY (PublisherId) REFERENCES Publisher(PublisherId),
    FOREIGN KEY (LibraryId)   REFERENCES Library(LibraryId)
);

-- 18. REVIEW  (Book 1:N Review)
CREATE TABLE Review (
    ReviewId INT IDENTITY(1,1) PRIMARY KEY,
    Rating   INT,
    BookId   INT,
    FOREIGN KEY (BookId) REFERENCES Book(BookId)
);

-- 19. CLUB
CREATE TABLE Club (
    ClubId   INT IDENTITY(1,1) PRIMARY KEY,
    ClubName VARCHAR(100) NOT NULL,
    ClubLoan DECIMAL(10,2)
);

-- 20. EVENT  (PK = EventTag per diagram)
CREATE TABLE Event (
    EventTag  INT IDENTITY(1,1) PRIMARY KEY,
    EventName VARCHAR(100) NOT NULL
);

-- 21. GYM  (RegistrationNumber moved to multivalued Gym_RegistrationNumber)
CREATE TABLE Gym (
    GymId           INT IDENTITY(1,1) PRIMARY KEY,
    GymLocation     VARCHAR(100),
    Capacity        INT,
    SuscriptionTime VARCHAR(50)
);

-- 22. TRAINER  (Gym 1:N Trainer, total on both sides)
CREATE TABLE Trainer (
    TrainerId     INT IDENTITY(1,1) PRIMARY KEY,
    TrainerName   VARCHAR(100) NOT NULL,
    TrainerBranch VARCHAR(50),
    GymId         INT NOT NULL,
    FOREIGN KEY (GymId) REFERENCES Gym(GymId)
);

-- 23. EQUIPMENT  (Gym 1:N Equipment)
CREATE TABLE Equipment (
    EquipmentId INT IDENTITY(1,1) PRIMARY KEY,
    GymId       INT,
    FOREIGN KEY (GymId) REFERENCES Gym(GymId)
);

-- 24. DORMITORY
CREATE TABLE Dormitory (
    DormitoryId   INT IDENTITY(1,1) PRIMARY KEY,
    DormitoryName VARCHAR(100) NOT NULL,
    DormAddress   VARCHAR(200)
);

-- 25. SCHOLARSHIP  (Dormitory 1:N Scholarship)
CREATE TABLE Scholarship (
    ScholarshipId  INT IDENTITY(1,1) PRIMARY KEY,
    ValidityPeriod VARCHAR(50),
    Amount         DECIMAL(10,2),
    CompletionRate DECIMAL(5,2),
    DormitoryId    INT,
    FOREIGN KEY (DormitoryId) REFERENCES Dormitory(DormitoryId)
);

-- 26. PAYMENT  (Scholarship 1:N Payment)
CREATE TABLE Payment (
    PaymentId     INT IDENTITY(1,1) PRIMARY KEY,
    PaymentAmount DECIMAL(10,2),
    ScholarshipId INT,
    FOREIGN KEY (ScholarshipId) REFERENCES Scholarship(ScholarshipId)
);

-- 27. INTERNSHIP  (UserAccount 1:N Internship; InternshipDuration is DERIVED)
CREATE TABLE Internship (
    InternshipId       INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName        VARCHAR(100),
    StartDate          DATE,
    EndDate            DATE,
    InternshipDuration AS DATEDIFF(DAY, StartDate, EndDate),
    UserAccountId      INT,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

-- 28. INTERNSHIP REPORT  (Internship 1:1 InternshipReport)
CREATE TABLE InternshipReport (
    ReportId      INT IDENTITY(1,1) PRIMARY KEY,
    ReportGrade   VARCHAR(10),
    ReportContent VARCHAR(1000),
    InternshipId  INT NOT NULL UNIQUE,
    FOREIGN KEY (InternshipId) REFERENCES Internship(InternshipId)
);

-- 29. FEEDBACK
CREATE TABLE Feedback (
    FeedbackId    INT IDENTITY(1,1) PRIMARY KEY,
    FeedbackText  VARCHAR(1000),
    UserAccountId INT,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

-- 30. LOGIN SESSION
CREATE TABLE LoginSession (
    SessionId     INT IDENTITY(1,1) PRIMARY KEY,
    LoginTime     DATETIME,
    UserAccountId INT,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

-- 31. NOTIFICATION
CREATE TABLE Notification (
    NotificationId      INT IDENTITY(1,1) PRIMARY KEY,
    NotificationContent VARCHAR(500),
    UserAccountId       INT,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);


/* ============================================================================
   SECTION 2: MULTIVALUED ATTRIBUTE TABLES
   ============================================================================ */

-- 32. Instructor.ExpertiseArea  (multivalued)
CREATE TABLE Instructor_ExpertiseArea (
    StaffId       INT NOT NULL,
    ExpertiseArea VARCHAR(100) NOT NULL,
    PRIMARY KEY (StaffId, ExpertiseArea),
    FOREIGN KEY (StaffId) REFERENCES Instructor(StaffId) ON DELETE CASCADE
);

-- 33. NonAcademicStaff.PhoneNumber  (multivalued)
CREATE TABLE NonAcademicStaff_PhoneNumber (
    StaffId     INT NOT NULL,
    PhoneNumber VARCHAR(30) NOT NULL,
    PRIMARY KEY (StaffId, PhoneNumber),
    FOREIGN KEY (StaffId) REFERENCES NonAcademicStaff(StaffId) ON DELETE CASCADE
);

-- 34. Equipment.TargetMuscle  (multivalued)
CREATE TABLE Equipment_TargetMuscle (
    EquipmentId  INT NOT NULL,
    TargetMuscle VARCHAR(50) NOT NULL,
    PRIMARY KEY (EquipmentId, TargetMuscle),
    FOREIGN KEY (EquipmentId) REFERENCES Equipment(EquipmentId) ON DELETE CASCADE
);

-- 35. Student.PhoneNumber  (multivalued) -- StudentPhone moved here
CREATE TABLE Student_PhoneNumber (
    StudentId   INT NOT NULL,
    PhoneNumber VARCHAR(30) NOT NULL,
    PRIMARY KEY (StudentId, PhoneNumber),
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId) ON DELETE CASCADE
);

-- 36. Book.Author  (multivalued)
CREATE TABLE Book_Author (
    BookId INT NOT NULL,
    Author VARCHAR(100) NOT NULL,
    PRIMARY KEY (BookId, Author),
    FOREIGN KEY (BookId) REFERENCES Book(BookId) ON DELETE CASCADE
);

-- 37. Assignment.AssignmentTitle  (multivalued) -- references composite PK of Assignment
CREATE TABLE Assignment_Title (
    CourseAccount   VARCHAR(100) NOT NULL,
    AssignmentId    INT NOT NULL,
    AssignmentTitle VARCHAR(150) NOT NULL,
    PRIMARY KEY (CourseAccount, AssignmentId, AssignmentTitle),
    FOREIGN KEY (CourseAccount, AssignmentId)
        REFERENCES Assignment(CourseAccount, AssignmentId) ON DELETE CASCADE
);

-- 38. Dormitory.DormitoryPhone  (multivalued)
CREATE TABLE Dormitory_Phone (
    DormitoryId    INT NOT NULL,
    DormitoryPhone VARCHAR(30) NOT NULL,
    PRIMARY KEY (DormitoryId, DormitoryPhone),
    FOREIGN KEY (DormitoryId) REFERENCES Dormitory(DormitoryId) ON DELETE CASCADE
);

-- 39. Gym.RegistrationNumber  (multivalued)
CREATE TABLE Gym_RegistrationNumber (
    GymId              INT NOT NULL,
    RegistrationNumber VARCHAR(50) NOT NULL,
    PRIMARY KEY (GymId, RegistrationNumber),
    FOREIGN KEY (GymId) REFERENCES Gym(GymId) ON DELETE CASCADE
);


/* ============================================================================
   SECTION 3: M:N JUNCTION TABLES
   ============================================================================ */

-- 40. UserAccount M:N Scholarship
CREATE TABLE UserAccount_Scholarship (
    UserAccountId INT NOT NULL,
    ScholarshipId INT NOT NULL,
    PRIMARY KEY (UserAccountId, ScholarshipId),
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId),
    FOREIGN KEY (ScholarshipId) REFERENCES Scholarship(ScholarshipId)
);

-- 41. UserAccount M:N Course
CREATE TABLE UserAccount_Course (
    UserAccountId INT NOT NULL,
    CourseAccount VARCHAR(100) NOT NULL,
    PRIMARY KEY (UserAccountId, CourseAccount),
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId),
    FOREIGN KEY (CourseAccount) REFERENCES Course(CourseAccount)
);

-- 42. UserAccount M:N Library
CREATE TABLE UserAccount_Library (
    UserAccountId INT NOT NULL,
    LibraryId     INT NOT NULL,
    PRIMARY KEY (UserAccountId, LibraryId),
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId),
    FOREIGN KEY (LibraryId)     REFERENCES Library(LibraryId)
);

-- 43. UserAccount M:N Gym
CREATE TABLE UserAccount_Gym (
    UserAccountId INT NOT NULL,
    GymId         INT NOT NULL,
    PRIMARY KEY (UserAccountId, GymId),
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId),
    FOREIGN KEY (GymId)         REFERENCES Gym(GymId)
);

-- 44. Student M:N Event  (Arranges)
CREATE TABLE Student_Event (
    StudentId INT NOT NULL,
    EventTag  INT NOT NULL,
    PRIMARY KEY (StudentId, EventTag),
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId),
    FOREIGN KEY (EventTag)  REFERENCES Event(EventTag)
);

-- 45. Student M:N Club  (Joins)
CREATE TABLE Student_Club (
    StudentId INT NOT NULL,
    ClubId    INT NOT NULL,
    PRIMARY KEY (StudentId, ClubId),
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId),
    FOREIGN KEY (ClubId)    REFERENCES Club(ClubId)
);


/* ============================================================================
   SECTION 4: SAMPLE DATA  (parent -> child order, English only)
   ============================================================================ */

-- FACULTY (Ids 1, 2)
INSERT INTO Faculty (FacultyName, DeanName) VALUES
('Engineering Faculty', 'Dr. James Wilson'),
('Science Faculty',     'Dr. Patricia Moore');

-- DEPARTMENT (Ids 1..4)
INSERT INTO Department (DepartmentName, FacultyId) VALUES
('Computer Engineering',   1),
('Electrical Engineering', 1),
('Mathematics',            2),
('Physics',                2);

-- USER ACCOUNT (Ids 1..6)
INSERT INTO UserAccount (Username, Password, Email, DepartmentId) VALUES
('john.smith',     'pass123', 'john.smith@uni.edu',     1),  -- student
('emma.johnson',   'pass456', 'emma.johnson@uni.edu',   1),  -- student
('michael.brown',  'pass789', 'michael.brown@uni.edu',  2),  -- instructor
('sarah.wilson',   'pass321', 'sarah.wilson@uni.edu',   3),  -- instructor
('robert.davis',   'pass654', 'robert.davis@uni.edu',   4),  -- non-academic
('linda.miller',   'pass987', 'linda.miller@uni.edu',   1);  -- non-academic

-- STUDENT (Ids 1, 2)
INSERT INTO Student (StudentName, BirthDate, UserAccountId) VALUES
('John Smith',   '2002-05-10', 1),
('Emma Johnson', '2003-08-22', 2);

-- STAFF (Ids 1..4)
INSERT INTO Staff (StaffName, AcademicTitles, UserAccountId) VALUES
('Dr. Michael Brown', 'Associate Professor', 3),
('Dr. Sarah Wilson',  'Professor',           4),
('Robert Davis',      NULL,                  5),
('Linda Miller',      NULL,                  6);

-- INSTRUCTOR (subclass)
INSERT INTO Instructor (StaffId, DepartmentId) VALUES
(1, 2),
(2, 3);

-- NON-ACADEMIC STAFF (subclass)
INSERT INTO NonAcademicStaff (StaffId, Workplace) VALUES
(3, 'Student Affairs Office'),
(4, 'Library Administration');

-- PROJECT
INSERT INTO Project (ProjectContent, InstructorId) VALUES
('IoT-based Smart Campus System',     1),
('Quantum Computing Research Project', 2);

-- TRANSCRIPT
INSERT INTO Transcript (ScoreInfo, StudentId) VALUES
('GPA: 3.45, Total Credits: 90', 1),
('GPA: 3.78, Total Credits: 75', 2);

-- CLASSROOM
INSERT INTO Classroom (ClassroomName, ClassroomDepart) VALUES
('A-101', 'Computer Engineering'),
('B-205', 'Mathematics');

-- COURSE  (CourseAccount is text PK)
INSERT INTO Course (CourseAccount, ClassroomId) VALUES
('CS301 - Database Management Systems', 1),
('MATH201 - Linear Algebra',            2);

-- COURSE CONTENT (weak)
INSERT INTO CourseContent (CourseAccount, LectureId, LectureName) VALUES
('CS301 - Database Management Systems', 1, 'Introduction to Databases'),
('CS301 - Database Management Systems', 2, 'ER Modeling'),
('MATH201 - Linear Algebra',            1, 'Vector Spaces');

-- EXAM (weak)
INSERT INTO Exam (CourseAccount, ExamId, AverageScore) VALUES
('CS301 - Database Management Systems', 1, 78.50),
('CS301 - Database Management Systems', 2, 82.30),
('MATH201 - Linear Algebra',            1, 71.20);

-- ASSIGNMENT (weak)  -- title is now in Assignment_Title
INSERT INTO Assignment (CourseAccount, AssignmentId, DueDate) VALUES
('CS301 - Database Management Systems', 1, '2026-03-15'),
('CS301 - Database Management Systems', 2, '2026-04-20'),
('MATH201 - Linear Algebra',            1, '2026-03-10');

-- LIBRARY
INSERT INTO Library (LibraryName) VALUES
('Central Library'),
('Engineering Library');

-- PUBLISHER
INSERT INTO Publisher (PublisherName, PublisherCountry) VALUES
('Pearson Education', 'USA'),
('Springer',          'Germany');

-- BOOK
INSERT INTO Book (BookName, BookType, ReturnDate, PublisherId, LibraryId) VALUES
('Fundamentals of Database Systems', 'Textbook', '2026-06-30', 1, 1),
('Linear Algebra Done Right',        'Textbook', '2026-07-15', 2, 2);

-- REVIEW
INSERT INTO Review (Rating, BookId) VALUES
(5, 1),
(4, 2);

-- CLUB
INSERT INTO Club (ClubName, ClubLoan) VALUES
('Computer Science Club', 5000.00),
('Photography Club',      2500.00);

-- EVENT
INSERT INTO Event (EventName) VALUES
('Tech Talk 2026'),
('Photography Workshop');

-- GYM
INSERT INTO Gym (GymLocation, Capacity, SuscriptionTime) VALUES
('Main Campus Gym',    150, 'Monthly'),
('Sports Complex Gym', 200, 'Yearly');

-- TRAINER
INSERT INTO Trainer (TrainerName, TrainerBranch, GymId) VALUES
('David Garcia',     'Strength Training', 1),
('Jennifer Martinez','Cardio',            2);

-- EQUIPMENT
INSERT INTO Equipment (GymId) VALUES
(1),
(2);

-- DORMITORY
INSERT INTO Dormitory (DormitoryName, DormAddress) VALUES
('Lincoln Dormitory',   'Campus East Block A'),
('Roosevelt Dormitory', 'Campus West Block B');

-- SCHOLARSHIP
INSERT INTO Scholarship (ValidityPeriod, Amount, CompletionRate, DormitoryId) VALUES
('2026 Spring', 5000.00, 75.50, 1),
('2026 Spring', 7500.00, 90.00, 2);

-- PAYMENT
INSERT INTO Payment (PaymentAmount, ScholarshipId) VALUES
(2500.00, 1),
(3750.00, 2);

-- INTERNSHIP
INSERT INTO Internship (CompanyName, StartDate, EndDate, UserAccountId) VALUES
('Google Inc.', '2026-06-01', '2026-08-31', 1),
('Apple Inc.',  '2026-07-01', '2026-09-30', 2);

-- INTERNSHIP REPORT
INSERT INTO InternshipReport (ReportGrade, ReportContent, InternshipId) VALUES
('A',  'Excellent performance in cloud computing tasks.',     1),
('B+', 'Good contribution to mobile software systems.',       2);

-- FEEDBACK
INSERT INTO Feedback (FeedbackText, UserAccountId) VALUES
('The course materials are well organized.', 1),
('The system runs smoothly.',                2);

-- LOGIN SESSION
INSERT INTO LoginSession (LoginTime, UserAccountId) VALUES
('2026-05-15 09:30:00', 1),
('2026-05-15 10:45:00', 2);

-- NOTIFICATION
INSERT INTO Notification (NotificationContent, UserAccountId) VALUES
('Your assignment is due tomorrow.',      1),
('New exam schedule has been published.', 2);


/* ---- Multivalued attribute tables ---- */

INSERT INTO Instructor_ExpertiseArea (StaffId, ExpertiseArea) VALUES
(1, 'Database Systems'),
(1, 'Distributed Computing'),
(2, 'Quantum Algorithms');

INSERT INTO NonAcademicStaff_PhoneNumber (StaffId, PhoneNumber) VALUES
(3, '+1-555-111-2233'),
(3, '+1-555-444-5566'),
(4, '+1-555-777-8899');

INSERT INTO Equipment_TargetMuscle (EquipmentId, TargetMuscle) VALUES
(1, 'Chest'),
(1, 'Triceps'),
(2, 'Legs');

INSERT INTO Student_PhoneNumber (StudentId, PhoneNumber) VALUES
(1, '+1-555-123-4567'),
(1, '+1-555-999-8888'),
(2, '+1-555-987-6543');

INSERT INTO Book_Author (BookId, Author) VALUES
(1, 'Ramez Elmasri'),
(1, 'Shamkant Navathe'),
(2, 'Sheldon Axler');

INSERT INTO Assignment_Title (CourseAccount, AssignmentId, AssignmentTitle) VALUES
('CS301 - Database Management Systems', 1, 'Homework 1 - ER Diagram'),
('CS301 - Database Management Systems', 1, 'HW1 - Conceptual Design'),
('CS301 - Database Management Systems', 2, 'Homework 2 - SQL Queries'),
('MATH201 - Linear Algebra',            1, 'Problem Set 1');

INSERT INTO Dormitory_Phone (DormitoryId, DormitoryPhone) VALUES
(1, '+1-212-333-4455'),
(2, '+1-212-555-6677');

INSERT INTO Gym_RegistrationNumber (GymId, RegistrationNumber) VALUES
(1, 'GYM-REG-001'),
(1, 'GYM-REG-002'),
(2, 'GYM-REG-101');


/* ---- M:N junction tables ---- */

INSERT INTO UserAccount_Scholarship (UserAccountId, ScholarshipId) VALUES
(1, 1),
(2, 2);

INSERT INTO UserAccount_Course (UserAccountId, CourseAccount) VALUES
(1, 'CS301 - Database Management Systems'),
(1, 'MATH201 - Linear Algebra'),
(2, 'CS301 - Database Management Systems'),
(3, 'CS301 - Database Management Systems');  -- instructor teaches the course

INSERT INTO UserAccount_Library (UserAccountId, LibraryId) VALUES
(1, 1),
(2, 2);

INSERT INTO UserAccount_Gym (UserAccountId, GymId) VALUES
(1, 1),
(2, 2);

INSERT INTO Student_Event (StudentId, EventTag) VALUES
(1, 1),
(2, 2);

INSERT INTO Student_Club (StudentId, ClubId) VALUES
(1, 1),
(1, 2),
(2, 2);

-- END OF PHASE 2 SCRIPT (v2)
