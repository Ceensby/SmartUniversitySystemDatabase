/* ============================================================================
   PHASE 2 - PART 2: INSERT sample data
   University Management System
   DBMS: Microsoft SQL Server 2025

   Run after: 01_create_tables.sql
   ============================================================================ */

INSERT INTO Faculty (FacultyName, DeanName) VALUES
('Engineering Faculty', 'Dr. James Wilson'),
('Science Faculty',     'Dr. Patricia Moore');

INSERT INTO Department (DepartmentName, FacultyId) VALUES
('Computer Engineering',   1),
('Electrical Engineering', 1),
('Mathematics',            2),
('Physics',                2);

INSERT INTO UserAccount (Username, Password, Email, DepartmentId) VALUES
('john.smith',     'pass123', 'john.smith@uni.edu',     1),
('emma.johnson',   'pass456', 'emma.johnson@uni.edu',   1),
('michael.brown',  'pass789', 'michael.brown@uni.edu',  2),
('sarah.wilson',   'pass321', 'sarah.wilson@uni.edu',   3),
('robert.davis',   'pass654', 'robert.davis@uni.edu',   4),
('linda.miller',   'pass987', 'linda.miller@uni.edu',   1);

INSERT INTO Student (StudentName, BirthDate, UserAccountId) VALUES
('John Smith',   '2002-05-10', 1),
('Emma Johnson', '2003-08-22', 2);

INSERT INTO Staff (StaffName, AcademicTitles, UserAccountId) VALUES
('Dr. Michael Brown', 'Associate Professor', 3),
('Dr. Sarah Wilson',  'Professor',           4),
('Robert Davis',      NULL,                  5),
('Linda Miller',      NULL,                  6);

INSERT INTO Instructor (StaffId, DepartmentId) VALUES
(1, 2),
(2, 3);

INSERT INTO NonAcademicStaff (StaffId, Workplace) VALUES
(3, 'Student Affairs Office'),
(4, 'Library Administration');

INSERT INTO Project (ProjectContent, InstructorId) VALUES
('IoT-based Smart Campus System',     1),
('Quantum Computing Research Project', 2);

INSERT INTO Transcript (ScoreInfo, StudentId) VALUES
('GPA: 3.45, Total Credits: 90', 1),
('GPA: 3.78, Total Credits: 75', 2);

INSERT INTO Classroom (ClassroomName, ClassroomDepart) VALUES
('A-101', 'Computer Engineering'),
('B-205', 'Mathematics');

INSERT INTO Course (CourseAccount, ClassroomId) VALUES
('CS301 - Database Management Systems', 1),
('MATH201 - Linear Algebra',            2);

INSERT INTO CourseContent (CourseAccount, LectureId, LectureName) VALUES
('CS301 - Database Management Systems', 1, 'Introduction to Databases'),
('CS301 - Database Management Systems', 2, 'ER Modeling'),
('MATH201 - Linear Algebra',            1, 'Vector Spaces');

INSERT INTO Exam (CourseAccount, ExamId, AverageScore) VALUES
('CS301 - Database Management Systems', 1, 78.50),
('CS301 - Database Management Systems', 2, 82.30),
('MATH201 - Linear Algebra',            1, 71.20);

INSERT INTO Assignment (CourseAccount, AssignmentId, DueDate) VALUES
('CS301 - Database Management Systems', 1, '2026-03-15'),
('CS301 - Database Management Systems', 2, '2026-04-20'),
('MATH201 - Linear Algebra',            1, '2026-03-10');

INSERT INTO Library (LibraryName) VALUES
('Central Library'),
('Engineering Library');

INSERT INTO Publisher (PublisherName, PublisherCountry) VALUES
('Pearson Education', 'USA'),
('Springer',          'Germany');

INSERT INTO Book (BookName, BookType, ReturnDate, PublisherId, LibraryId) VALUES
('Fundamentals of Database Systems', 'Textbook', '2026-06-30', 1, 1),
('Linear Algebra Done Right',        'Textbook', '2026-07-15', 2, 2);

INSERT INTO Review (Rating, BookId) VALUES
(5, 1),
(4, 2);

INSERT INTO Club (ClubName, ClubLoan) VALUES
('Computer Science Club', 5000.00),
('Photography Club',      2500.00);

INSERT INTO Event (EventName) VALUES
('Tech Talk 2026'),
('Photography Workshop');

INSERT INTO Gym (GymLocation, Capacity, SuscriptionTime) VALUES
('Main Campus Gym',    150, 'Monthly'),
('Sports Complex Gym', 200, 'Yearly');

INSERT INTO Trainer (TrainerName, TrainerBranch, GymId) VALUES
('David Garcia',     'Strength Training', 1),
('Jennifer Martinez','Cardio',            2);

INSERT INTO Equipment (GymId) VALUES
(1),
(2);

INSERT INTO Dormitory (DormitoryName, DormAddress) VALUES
('Lincoln Dormitory',   'Campus East Block A'),
('Roosevelt Dormitory', 'Campus West Block B');

INSERT INTO Scholarship (ValidityPeriod, Amount, CompletionRate, DormitoryId) VALUES
('2026 Spring', 5000.00, 75.50, 1),
('2026 Spring', 7500.00, 90.00, 2);

INSERT INTO Payment (PaymentAmount, ScholarshipId) VALUES
(2500.00, 1),
(3750.00, 2);

INSERT INTO Internship (CompanyName, StartDate, EndDate, UserAccountId) VALUES
('Google Inc.', '2026-06-01', '2026-08-31', 1),
('Apple Inc.',  '2026-07-01', '2026-09-30', 2);

INSERT INTO InternshipReport (ReportGrade, ReportContent, InternshipId) VALUES
('A',  'Excellent performance in cloud computing tasks.',     1),
('B+', 'Good contribution to mobile software systems.',       2);

INSERT INTO Feedback (FeedbackText, UserAccountId) VALUES
('The course materials are well organized.', 1),
('The system runs smoothly.',                2);

INSERT INTO LoginSession (LoginTime, UserAccountId) VALUES
('2026-05-15 09:30:00', 1),
('2026-05-15 10:45:00', 2);

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
(3, 'CS301 - Database Management Systems');

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

-- END OF INSERT SCRIPT
