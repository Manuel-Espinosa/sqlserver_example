-- Query 1: Estudiantes matriculados y sus materias
SELECT
	s.id AS StudentID,
	CONCAT(s.first_name, ' ', s.last_name) AS StudentName,
	s.email AS StudentEmail,
	s.status AS Status,
	COUNT(DISTINCT sub.id) AS TotalSubjects,
	STRING_AGG(CONCAT(sub.code, ' - ', sub.name), '; ') AS EnrolledSubjects
FROM
	Students s
INNER JOIN Enrollments e ON
	s.id = e.student_id
INNER JOIN Groups g ON
	e.group_id = g.id
INNER JOIN Subjects sub ON
	g.subject_id = sub.id
WHERE
	g.semester = '2025-1'
GROUP BY
	s.id,
	s.first_name,
	s.last_name,
	s.email,
	s.status
ORDER BY
	s.last_name,
	s.first_name;
-- Query 2: Profesores que enseñan en mas de un grupo
SELECT
	d.name AS Department,
	d.code AS DeptCode,
	CONCAT(p.first_name, ' ', p.last_name) AS ProfessorName,
	p.email AS Email,
	COUNT(DISTINCT pg.group_id) AS GroupsTeaching,
	ca.GroupCodes
FROM
	Departments d
INNER JOIN Professors p ON
	d.id = p.department_id
LEFT JOIN Professor_Group pg ON
	p.id = pg.professor_id
LEFT JOIN Groups g ON
	pg.group_id = g.id
LEFT JOIN Subjects sub ON
	g.subject_id = sub.id
CROSS APPLY (
	SELECT
		STRING_AGG(CONCAT(SubjectCode, '-', GroupCode), ', ') AS GroupCodes
	FROM
		(
		SELECT
			DISTINCT
            sub2.code AS SubjectCode,
			g2.code AS GroupCode
		FROM
			Professor_Group pg2
		INNER JOIN Groups g2 ON
			pg2.group_id = g2.id
		INNER JOIN Subjects sub2 ON
			g2.subject_id = sub2.id
		WHERE
			pg2.professor_id = p.id
			AND (g2.semester = '2025-1'
				OR g2.semester IS NULL)
    ) x
) ca
WHERE
	g.semester = '2025-1'
	OR g.semester IS NULL
GROUP BY
	d.name,
	d.code,
	p.first_name,
	p.last_name,
	p.email,
	ca.GroupCodes
HAVING
	COUNT(DISTINCT pg.group_id) > 1
ORDER BY
	Department,
	GroupsTeaching DESC;
-- Query 3: Group professor status
SELECT
	sub.code AS SubjectCode,
	sub.name AS SubjectName,
	g.code AS GroupCode,
	g.semester AS Semester,
	g.schedule AS Schedule,
	COUNT(pg.professor_id) AS TotalProfessors,
	STRING_AGG(CONCAT(p.first_name, ' ', p.last_name, ' (', pg.role, ')'), '; ') AS Professors,
	CASE
		WHEN COUNT(pg.professor_id) = 1 THEN 'Single Professor'
		WHEN COUNT(pg.professor_id) > 1 THEN 'Multiple Professors'
		ELSE 'No Professors'
	END AS ProfessorStatus
FROM
	Subjects sub
INNER JOIN Groups g ON
	sub.id = g.subject_id
LEFT JOIN Professor_Group pg ON
	g.id = pg.group_id
LEFT JOIN Professors p ON
	pg.professor_id = p.id
WHERE
	g.semester = '2025-1'
GROUP BY
	sub.code,
	sub.name,
	g.code,
	g.semester,
	g.schedule
ORDER BY
	sub.code,
	g.code;
-- Query 4: Estadistica de calificaciones 
SELECT
	sub.code AS SubjectCode,
	sub.name AS SubjectName,
	sub.credits AS Credits,
	COUNT(e.id) AS TotalEnrollments,
	COUNT(e.grade) AS GradedEnrollments,
	ROUND(AVG(e.grade), 2) AS AverageGrade,
	MIN(e.grade) AS MinGrade,
	MAX(e.grade) AS MaxGrade,
	ROUND(
        CAST(SUM(CASE WHEN e.grade >= 70 THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(e.grade), 0) * 100,
        2
    ) AS PassRatePercent
FROM
	Subjects sub
INNER JOIN Groups g ON
	sub.id = g.subject_id
INNER JOIN Enrollments e ON
	g.id = e.group_id
WHERE
	e.grade IS NOT NULL
GROUP BY
	sub.code,
	sub.name,
	sub.credits
HAVING
	COUNT(e.grade) > 0
ORDER BY
	AverageGrade DESC;
-- Query 5: Profesores que son directores de departamento y enseñan
SELECT
	d.name AS Department,
	d.code AS DeptCode,
	CONCAT(p.first_name, ' ', p.last_name) AS ProfessorName,
	p.email AS Email,
	COUNT(DISTINCT pg.group_id) AS GroupsTeaching,
	ca.GroupCodes
FROM
	Departments d
INNER JOIN Professors p ON
	d.id = p.department_id
LEFT JOIN Professor_Group pg ON
	p.id = pg.professor_id
LEFT JOIN Groups g ON
	pg.group_id = g.id
LEFT JOIN Subjects sub ON
	g.subject_id = sub.id
CROSS APPLY (
	SELECT
		STRING_AGG(CONCAT(SubjectCode, '-', GroupCode), ', ') AS GroupCodes
	FROM
		(
		SELECT
			DISTINCT
            sub2.code AS SubjectCode,
			g2.code AS GroupCode
		FROM
			Professor_Group pg2
		INNER JOIN Groups g2 ON
			pg2.group_id = g2.id
		INNER JOIN Subjects sub2 ON
			g2.subject_id = sub2.id
		WHERE
			pg2.professor_id = p.id
			AND (g2.semester = '2025-1'
				OR g2.semester IS NULL)
    ) AS x
) AS ca
WHERE
	g.semester = '2025-1'
	OR g.semester IS NULL
GROUP BY
	d.name,
	d.code,
	p.first_name,
	p.last_name,
	p.email,
	ca.GroupCodes
HAVING
	COUNT(DISTINCT pg.group_id) > 1
ORDER BY
	Department,
	GroupsTeaching DESC;
-- Query 6: Estudiantes sin calificacion
SELECT
	s.id AS StudentID,
	CONCAT(s.first_name, ' ', s.last_name) AS StudentName,
	s.email AS Email,
	s.enrollment_date AS EnrollmentDate,
	COUNT(e.id) AS TotalEnrollments,
	COUNT(e.grade) AS GradedEnrollments
FROM
	Students s
INNER JOIN Enrollments e ON
	s.id = e.student_id
WHERE
	s.status = 'active'
	AND s.id IN (
	SELECT
		student_id
	FROM
		Enrollments
	WHERE
		grade IS NULL
  )
GROUP BY
	s.id,
	s.first_name,
	s.last_name,
	s.email,
	s.enrollment_date
HAVING
	COUNT(e.grade) = 0
ORDER BY
	s.enrollment_date DESC;