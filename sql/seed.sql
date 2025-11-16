USE AcademicDB;
GO

------------------------------------------------------------
-- 1. DEPARTMENTS
------------------------------------------------------------
INSERT INTO Departments (name, code)
VALUES
('Computer Science', 'CS'),
('Mathematics', 'MATH'),
('Physics', 'PHYS'),
('Literature', 'LIT'),
('Biology', 'BIO');
GO

------------------------------------------------------------
-- 2. PROFESSORS
------------------------------------------------------------
INSERT INTO Professors (first_name, last_name, email, department_id)
VALUES
('Alan', 'Turing', 'alan.turing@university.edu', 1),
('Ada', 'Lovelace', 'ada.lovelace@university.edu', 1),
('Sofia', 'Kovalevskaya', 'sofia.kova@university.edu', 2),
('Richard', 'Feynman', 'richard.feynman@university.edu', 3),
('Jane', 'Austen', 'jane.austen@university.edu', 4),
('Charles', 'Darwin', 'charles.darwin@university.edu', 5);
GO

------------------------------------------------------------
-- 3. DIRECTORES
------------------------------------------------------------
UPDATE Departments SET director_id = 1 WHERE id = 1;
UPDATE Departments SET director_id = 3 WHERE id = 2;
UPDATE Departments SET director_id = 4 WHERE id = 3;
UPDATE Departments SET director_id = 5 WHERE id = 4;
UPDATE Departments SET director_id = 6 WHERE id = 5;
GO

------------------------------------------------------------
-- 4. SUBJECTS
------------------------------------------------------------
INSERT INTO Subjects (code, name, credits)
VALUES
('CS101', 'Algorithms', 8),
('CS102', 'Data Structures', 8),
('MATH101', 'Calculus I', 6),
('MATH201', 'Linear Algebra', 6),
('PHYS301', 'Quantum Mechanics', 8),
('PHYS201', 'Classical Mechanics', 6),
('LIT101', 'English Literature', 4),
('BIO101', 'Evolutionary Biology', 6);
GO

------------------------------------------------------------
-- 5. GROUPS
------------------------------------------------------------
INSERT INTO Groups (subject_id, code, semester)
VALUES
(1, 'A1', '2025-1'),
(1, 'A2', '2025-1'),
(2, 'DS1', '2025-1'),
(3, 'CALC1', '2025-1'),
(4, 'LA1', '2025-1'),
(5, 'QM1', '2025-1'),
(7, 'LIT1', '2025-1'),
(8, 'BIO1', '2025-1');
GO

------------------------------------------------------------
-- 6. STUDENTS
------------------------------------------------------------
INSERT INTO Students (first_name, last_name, email, birth_date)
VALUES
('Maria', 'Gomez', 'maria.gomez@student.edu', '2002-05-10'),
('Luis', 'Hernandez', 'luis.hernandez@student.edu', '2001-09-22'),
('Elena', 'Rodriguez', 'elena.rodriguez@student.edu', '2003-03-14'),
('Carlos', 'Lopez', 'carlos.lopez@student.edu', '2002-12-01'),
('Ana', 'Martinez', 'ana.martinez@student.edu', '2001-07-18');
GO

------------------------------------------------------------
-- 7. ENROLLMENTS
------------------------------------------------------------
INSERT INTO Enrollments (student_id, group_id, enrollment_date)
VALUES
(1, 1, GETDATE()),
(1, 3, GETDATE()),
(2, 4, GETDATE()),
(2, 5, GETDATE()),
(3, 2, GETDATE()),
(4, 7, GETDATE()),
(5, 8, GETDATE());
GO

------------------------------------------------------------
-- 8. PROFESSOR_GROUP
------------------------------------------------------------
INSERT INTO Professor_Group (professor_id, group_id)
VALUES
(1, 1),
(2, 2),
(1, 3),
(3, 4),
(3, 5),
(4, 6),
(5, 7),
(6, 8);
GO
