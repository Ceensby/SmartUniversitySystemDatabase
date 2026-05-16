/* ============================================================================
   PHASE 2 - PART 1: CREATE TABLE statements only
   University Management System
   DBMS: Microsoft SQL Server 2025

   Run order: 01_create_tables.sql -> 02_insert_sample_data.sql
   ============================================================================ */
/* ----- SECTION 1: STRONG ENTITIES (parent tables first) ----- */

CREATE TABLE Faculty (
    FacultyId   INT IDENTITY(1,1) PRIMARY KEY,
    FacultyName VARCHAR(100) NOT NULL,
    DeanName    VARCHAR(100)
);

CREATE TABLE Department (
    DepartmentId   INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    FacultyId      INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculty(FacultyId)
);

CREATE TABLE UserAccount (
    UserAccountId INT IDENTITY(1,1) PRIMARY KEY,
    Username      VARCHAR(50)  NOT NULL UNIQUE,
    Password      VARCHAR(100) NOT NULL,
    Email         VARCHAR(100) UNIQUE,
    DepartmentId  INT,
    FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId)
);

CREATE TABLE Student (
    StudentId     INT IDENTITY(1,1) PRIMARY KEY,
    StudentName   VARCHAR(100) NOT NULL,
    BirthDate     DATE,
    Age           AS DATEDIFF(YEAR, BirthDate, GETDATE()),
    UserAccountId INT NOT NULL UNIQUE,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

CREATE TABLE Staff (
    StaffId        INT IDENTITY(1,1) PRIMARY KEY,
    StaffName      VARCHAR(100) NOT NULL,
    AcademicTitles VARCHAR(100),
    UserAccountId  INT NOT NULL UNIQUE,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

CREATE TABLE Instructor (
    StaffId      INT PRIMARY KEY,
    DepartmentId INT,
    FOREIGN KEY (StaffId)      REFERENCES Staff(StaffId)            ON DELETE CASCADE,
    FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId)
);

CREATE TABLE NonAcademicStaff (
    StaffId   INT PRIMARY KEY,
    Workplace VARCHAR(100),
    FOREIGN KEY (StaffId) REFERENCES Staff(StaffId) ON DELETE CASCADE
);

CREATE TABLE Project (
    ProjectId      INT IDENTITY(1,1) PRIMARY KEY,
    ProjectContent VARCHAR(500),
    InstructorId   INT,
    FOREIGN KEY (InstructorId) REFERENCES Instructor(StaffId)
);

CREATE TABLE Transcript (
    TranscriptId INT IDENTITY(1,1) PRIMARY KEY,
    ScoreInfo    VARCHAR(500),
    StudentId    INT NOT NULL UNIQUE,
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
);

CREATE TABLE Classroom (
    ClassroomId      INT IDENTITY(1,1) PRIMARY KEY,
    ClassroomName    VARCHAR(50)  NOT NULL,
    ClassroomDepart  VARCHAR(50)
);

CREATE TABLE Course (
    CourseAccount VARCHAR(100) PRIMARY KEY,
    ClassroomId   INT NOT NULL,
    FOREIGN KEY (ClassroomId) REFERENCES Classroom(ClassroomId)
);

CREATE TABLE CourseContent (
    CourseAccount VARCHAR(100) NOT NULL,
    LectureId     INT NOT NULL,
    LectureName   VARCHAR(100),
    PRIMARY KEY (CourseAccount, LectureId),
    FOREIGN KEY (CourseAccount) REFERENCES Course(CourseAccount) ON DELETE CASCADE
);

CREATE TABLE Exam (
    CourseAccount VARCHAR(100) NOT NULL,
    ExamId        INT NOT NULL,
    AverageScore  DECIMAL(5,2),
    PRIMARY KEY (CourseAccount, ExamId),
    FOREIGN KEY (CourseAccount) REFERENCES Course(CourseAccount) ON DELETE CASCADE
);

CREATE TABLE Assignment (
    CourseAccount VARCHAR(100) NOT NULL,
    AssignmentId  INT NOT NULL,
    DueDate       DATE,
    PRIMARY KEY (CourseAccount, AssignmentId),
    FOREIGN KEY (CourseAccount) REFERENCES Course(CourseAccount) ON DELETE CASCADE
);

CREATE TABLE Library (
    LibraryId   INT IDENTITY(1,1) PRIMARY KEY,
    LibraryName VARCHAR(100) NOT NULL
);

CREATE TABLE Publisher (
    PublisherId      INT IDENTITY(1,1) PRIMARY KEY,
    PublisherName    VARCHAR(100) NOT NULL,
    PublisherCountry VARCHAR(50)
);

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

CREATE TABLE Review (
    ReviewId INT IDENTITY(1,1) PRIMARY KEY,
    Rating   INT,
    BookId   INT,
    FOREIGN KEY (BookId) REFERENCES Book(BookId)
);

CREATE TABLE Club (
    ClubId   INT IDENTITY(1,1) PRIMARY KEY,
    ClubName VARCHAR(100) NOT NULL,
    ClubLoan DECIMAL(10,2)
);

CREATE TABLE Event (
    EventTag  INT IDENTITY(1,1) PRIMARY KEY,
    EventName VARCHAR(100) NOT NULL
);

CREATE TABLE Gym (
    GymId           INT IDENTITY(1,1) PRIMARY KEY,
    GymLocation     VARCHAR(100),
    Capacity        INT,
    SuscriptionTime VARCHAR(50)
);

CREATE TABLE Trainer (
    TrainerId     INT IDENTITY(1,1) PRIMARY KEY,
    TrainerName   VARCHAR(100) NOT NULL,
    TrainerBranch VARCHAR(50),
    GymId         INT NOT NULL,
    FOREIGN KEY (GymId) REFERENCES Gym(GymId)
);

CREATE TABLE Equipment (
    EquipmentId INT IDENTITY(1,1) PRIMARY KEY,
    GymId       INT,
    FOREIGN KEY (GymId) REFERENCES Gym(GymId)
);

CREATE TABLE Dormitory (
    DormitoryId   INT IDENTITY(1,1) PRIMARY KEY,
    DormitoryName VARCHAR(100) NOT NULL,
    DormAddress   VARCHAR(200)
);

CREATE TABLE Scholarship (
    ScholarshipId  INT IDENTITY(1,1) PRIMARY KEY,
    ValidityPeriod VARCHAR(50),
    Amount         DECIMAL(10,2),
    CompletionRate DECIMAL(5,2),
    DormitoryId    INT,
    FOREIGN KEY (DormitoryId) REFERENCES Dormitory(DormitoryId)
);

CREATE TABLE Payment (
    PaymentId     INT IDENTITY(1,1) PRIMARY KEY,
    PaymentAmount DECIMAL(10,2),
    ScholarshipId INT,
    FOREIGN KEY (ScholarshipId) REFERENCES Scholarship(ScholarshipId)
);

CREATE TABLE Internship (
    InternshipId       INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName        VARCHAR(100),
    StartDate          DATE,
    EndDate            DATE,
    InternshipDuration AS DATEDIFF(DAY, StartDate, EndDate),
    UserAccountId      INT,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

CREATE TABLE InternshipReport (
    ReportId      INT IDENTITY(1,1) PRIMARY KEY,
    ReportGrade   VARCHAR(10),
    ReportContent VARCHAR(1000),
    InternshipId  INT NOT NULL UNIQUE,
    FOREIGN KEY (InternshipId) REFERENCES Internship(InternshipId)
);

CREATE TABLE Feedback (
    FeedbackId    INT IDENTITY(1,1) PRIMARY KEY,
    FeedbackText  VARCHAR(1000),
    UserAccountId INT,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

CREATE TABLE LoginSession (
    SessionId     INT IDENTITY(1,1) PRIMARY KEY,
    LoginTime     DATETIME,
    UserAccountId INT,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);

CREATE TABLE Notification (
    NotificationId      INT IDENTITY(1,1) PRIMARY KEY,
    NotificationContent VARCHAR(500),
    UserAccountId       INT,
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId)
);


/* ----- SECTION 2: MULTIVALUED ATTRIBUTE TABLES ----- */

CREATE TABLE Instructor_ExpertiseArea (
    StaffId       INT NOT NULL,
    ExpertiseArea VARCHAR(100) NOT NULL,
    PRIMARY KEY (StaffId, ExpertiseArea),
    FOREIGN KEY (StaffId) REFERENCES Instructor(StaffId) ON DELETE CASCADE
);

CREATE TABLE NonAcademicStaff_PhoneNumber (
    StaffId     INT NOT NULL,
    PhoneNumber VARCHAR(30) NOT NULL,
    PRIMARY KEY (StaffId, PhoneNumber),
    FOREIGN KEY (StaffId) REFERENCES NonAcademicStaff(StaffId) ON DELETE CASCADE
);

CREATE TABLE Equipment_TargetMuscle (
    EquipmentId  INT NOT NULL,
    TargetMuscle VARCHAR(50) NOT NULL,
    PRIMARY KEY (EquipmentId, TargetMuscle),
    FOREIGN KEY (EquipmentId) REFERENCES Equipment(EquipmentId) ON DELETE CASCADE
);

CREATE TABLE Student_PhoneNumber (
    StudentId   INT NOT NULL,
    PhoneNumber VARCHAR(30) NOT NULL,
    PRIMARY KEY (StudentId, PhoneNumber),
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId) ON DELETE CASCADE
);

CREATE TABLE Book_Author (
    BookId INT NOT NULL,
    Author VARCHAR(100) NOT NULL,
    PRIMARY KEY (BookId, Author),
    FOREIGN KEY (BookId) REFERENCES Book(BookId) ON DELETE CASCADE
);

CREATE TABLE Assignment_Title (
    CourseAccount   VARCHAR(100) NOT NULL,
    AssignmentId    INT NOT NULL,
    AssignmentTitle VARCHAR(150) NOT NULL,
    PRIMARY KEY (CourseAccount, AssignmentId, AssignmentTitle),
    FOREIGN KEY (CourseAccount, AssignmentId)
        REFERENCES Assignment(CourseAccount, AssignmentId) ON DELETE CASCADE
);

CREATE TABLE Dormitory_Phone (
    DormitoryId    INT NOT NULL,
    DormitoryPhone VARCHAR(30) NOT NULL,
    PRIMARY KEY (DormitoryId, DormitoryPhone),
    FOREIGN KEY (DormitoryId) REFERENCES Dormitory(DormitoryId) ON DELETE CASCADE
);

CREATE TABLE Gym_RegistrationNumber (
    GymId              INT NOT NULL,
    RegistrationNumber VARCHAR(50) NOT NULL,
    PRIMARY KEY (GymId, RegistrationNumber),
    FOREIGN KEY (GymId) REFERENCES Gym(GymId) ON DELETE CASCADE
);


/* ----- SECTION 3: M:N JUNCTION TABLES ----- */

CREATE TABLE UserAccount_Scholarship (
    UserAccountId INT NOT NULL,
    ScholarshipId INT NOT NULL,
    PRIMARY KEY (UserAccountId, ScholarshipId),
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId),
    FOREIGN KEY (ScholarshipId) REFERENCES Scholarship(ScholarshipId)
);

CREATE TABLE UserAccount_Course (
    UserAccountId INT NOT NULL,
    CourseAccount VARCHAR(100) NOT NULL,
    PRIMARY KEY (UserAccountId, CourseAccount),
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId),
    FOREIGN KEY (CourseAccount) REFERENCES Course(CourseAccount)
);

CREATE TABLE UserAccount_Library (
    UserAccountId INT NOT NULL,
    LibraryId     INT NOT NULL,
    PRIMARY KEY (UserAccountId, LibraryId),
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId),
    FOREIGN KEY (LibraryId)     REFERENCES Library(LibraryId)
);

CREATE TABLE UserAccount_Gym (
    UserAccountId INT NOT NULL,
    GymId         INT NOT NULL,
    PRIMARY KEY (UserAccountId, GymId),
    FOREIGN KEY (UserAccountId) REFERENCES UserAccount(UserAccountId),
    FOREIGN KEY (GymId)         REFERENCES Gym(GymId)
);

CREATE TABLE Student_Event (
    StudentId INT NOT NULL,
    EventTag  INT NOT NULL,
    PRIMARY KEY (StudentId, EventTag),
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId),
    FOREIGN KEY (EventTag)  REFERENCES Event(EventTag)
);

CREATE TABLE Student_Club (
    StudentId INT NOT NULL,
    ClubId    INT NOT NULL,
    PRIMARY KEY (StudentId, ClubId),
    FOREIGN KEY (StudentId) REFERENCES Student(StudentId),
    FOREIGN KEY (ClubId)    REFERENCES Club(ClubId)
);

-- END OF CREATE TABLE SCRIPT
