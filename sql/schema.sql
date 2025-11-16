-- =============================================
-- Academic Management System - Database Schema
-- SQL Server 2019/2022
-- =============================================

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AcademicDB')
BEGIN
    CREATE DATABASE AcademicDB;
END
GO

USE AcademicDB;
GO

-- Drop tables in reverse order of dependencies (for clean re-runs)
IF OBJECT_ID('dbo.Professor_Group', 'U') IS NOT NULL DROP TABLE dbo.Professor_Group;
IF OBJECT_ID('dbo.Enrollments', 'U') IS NOT NULL DROP TABLE dbo.Enrollments;
IF OBJECT_ID('dbo.Groups', 'U') IS NOT NULL DROP TABLE dbo.Groups;
IF OBJECT_ID('dbo.Subjects', 'U') IS NOT NULL DROP TABLE dbo.Subjects;
IF OBJECT_ID('dbo.Professors', 'U') IS NOT NULL DROP TABLE dbo.Professors;
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;
IF OBJECT_ID('dbo.Students', 'U') IS NOT NULL DROP TABLE dbo.Students;
GO

-- =============================================
-- Table: Students
-- =============================================
CREATE TABLE Students (
    id INT PRIMARY KEY IDENTITY(1,1),
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    birth_date DATE NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'graduated', 'suspended')),
    CONSTRAINT CHK_Students_BirthDate CHECK (birth_date < GETDATE()),
    CONSTRAINT CHK_Students_Email CHECK (email LIKE '%@%')
);
GO

CREATE INDEX IX_Students_Email ON Students(email);
CREATE INDEX IX_Students_Status ON Students(status);
GO

-- =============================================
-- Table: Departments
-- =============================================
CREATE TABLE Departments (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(200) NOT NULL,
    code NVARCHAR(10) NOT NULL UNIQUE,
    director_id INT NULL  -- Will be set after professors are created
);
GO

CREATE INDEX IX_Departments_Code ON Departments(code);
GO

-- =============================================
-- Table: Professors
-- =============================================
CREATE TABLE Professors (
    id INT PRIMARY KEY IDENTITY(1,1),
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    hire_date DATE NOT NULL DEFAULT GETDATE(),
    department_id INT NOT NULL,
    CONSTRAINT FK_Professors_Department
        FOREIGN KEY (department_id) REFERENCES Departments(id),
    CONSTRAINT CHK_Professors_Email CHECK (email LIKE '%@%')
);
GO

CREATE INDEX IX_Professors_Email ON Professors(email);
CREATE INDEX IX_Professors_Department ON Professors(department_id);
GO

-- Add FK from Departments to Professors for director
ALTER TABLE Departments
ADD CONSTRAINT FK_Departments_Director
    FOREIGN KEY (director_id) REFERENCES Professors(id);
GO

-- =============================================
-- Trigger: Ensure director belongs to the department
-- =============================================
GO
CREATE OR ALTER TRIGGER TR_Departments_ValidateDirector
ON Departments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Professors p ON i.director_id = p.id
        WHERE p.department_id != i.id
    )
    BEGIN
        RAISERROR('Director must be a professor from the same department', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
GO

-- =============================================
-- Table: Subjects
-- =============================================
CREATE TABLE Subjects (
    id INT PRIMARY KEY IDENTITY(1,1),
    code NVARCHAR(20) NOT NULL UNIQUE,
    name NVARCHAR(200) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0 AND credits <= 12),
    description NVARCHAR(MAX) NULL
);
GO

CREATE INDEX IX_Subjects_Code ON Subjects(code);
GO

-- =============================================
-- Table: Groups (Course Sections)
-- =============================================
CREATE TABLE Groups (
    id INT PRIMARY KEY IDENTITY(1,1),
    subject_id INT NOT NULL,
    code NVARCHAR(10) NOT NULL,  -- e.g., 'A', 'B', '01', '02'
    semester NVARCHAR(20) NOT NULL,  -- e.g., '2024-1', '2024-2'
    schedule NVARCHAR(100) NULL,  -- e.g., 'Mon/Wed 10:00-12:00'
    room NVARCHAR(50) NULL,  -- e.g., 'Room 301', 'Lab B'
    CONSTRAINT FK_Groups_Subject
        FOREIGN KEY (subject_id) REFERENCES Subjects(id) ON DELETE CASCADE,
    CONSTRAINT UQ_Groups_Subject_Code_Semester
        UNIQUE (subject_id, code, semester)
);
GO

CREATE INDEX IX_Groups_Subject ON Groups(subject_id);
CREATE INDEX IX_Groups_Semester ON Groups(semester);
GO

-- =============================================
-- Table: Enrollments
-- =============================================
CREATE TABLE Enrollments (
    id INT PRIMARY KEY IDENTITY(1,1),
    student_id INT NOT NULL,
    group_id INT NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT GETDATE(),
    grade DECIMAL(4,2) NULL CHECK (grade >= 0 AND grade <= 100),
    CONSTRAINT FK_Enrollments_Student
        FOREIGN KEY (student_id) REFERENCES Students(id) ON DELETE CASCADE,
    CONSTRAINT FK_Enrollments_Group
        FOREIGN KEY (group_id) REFERENCES Groups(id) ON DELETE CASCADE,
    CONSTRAINT UQ_Enrollments_Student_Group
        UNIQUE (student_id, group_id)
);
GO

CREATE INDEX IX_Enrollments_Student ON Enrollments(student_id);
CREATE INDEX IX_Enrollments_Group ON Enrollments(group_id);
GO

-- =============================================
-- Table: Professor_Group (Teaching Assignments)
-- =============================================
CREATE TABLE Professor_Group (
    id INT PRIMARY KEY IDENTITY(1,1),
    professor_id INT NOT NULL,
    group_id INT NOT NULL,
    role NVARCHAR(20) NOT NULL DEFAULT 'titular'
        CHECK (role IN ('titular', 'auxiliar', 'assistant', 'coordinator')),
    CONSTRAINT FK_ProfessorGroup_Professor
        FOREIGN KEY (professor_id) REFERENCES Professors(id) ON DELETE CASCADE,
    CONSTRAINT FK_ProfessorGroup_Group
        FOREIGN KEY (group_id) REFERENCES Groups(id) ON DELETE CASCADE,
    CONSTRAINT UQ_ProfessorGroup_Prof_Group_Role
        UNIQUE (professor_id, group_id, role)
);
GO

CREATE INDEX IX_ProfessorGroup_Professor ON Professor_Group(professor_id);
CREATE INDEX IX_ProfessorGroup_Group ON Professor_Group(group_id);
GO

-- =============================================
-- Trigger: Ensure each group has at least one professor
-- Note: This validates on DELETE from Professor_Group
-- =============================================
GO
CREATE OR ALTER TRIGGER TR_ProfessorGroup_ValidateMinimum
ON Professor_Group
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT g.id
        FROM Groups g
        WHERE g.id IN (SELECT group_id FROM deleted)
        AND NOT EXISTS (
            SELECT 1
            FROM Professor_Group pg
            WHERE pg.group_id = g.id
        )
    )
    BEGIN
        RAISERROR('A group must have at least one assigned professor', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
GO

-- =============================================
-- Summary Statistics View (Optional)
-- =============================================
GO
CREATE OR ALTER VIEW vw_DatabaseStats AS
SELECT
    (SELECT COUNT(*) FROM Students) AS TotalStudents,
    (SELECT COUNT(*) FROM Professors) AS TotalProfessors,
    (SELECT COUNT(*) FROM Departments) AS TotalDepartments,
    (SELECT COUNT(*) FROM Subjects) AS TotalSubjects,
    (SELECT COUNT(*) FROM Groups) AS TotalGroups,
    (SELECT COUNT(*) FROM Enrollments) AS TotalEnrollments,
    (SELECT COUNT(*) FROM Professor_Group) AS TotalAssignments;
GO

PRINT 'Database schema created successfully!';
PRINT 'Tables: Students, Professors, Departments, Subjects, Groups, Enrollments, Professor_Group';
GO
