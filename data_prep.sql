-- First table - Breakdown of Male/Female employees working in the company each year (starting in 1990)

SELECT
	YEAR(d.from_date) AS calendar_year,
	e.gender,
	COUNT(e.emp_no) AS num_of_employees
FROM
	employees e
	JOIN dept_emp d ON d.emp_no = e.emp_no
GROUP BY
	calendar_year,
	e.gender
HAVING
	calendar_year >= 1990;

-- Second table - The number of male and female managers each year
SELECT
	d.dept_name,
	ee.gender,
	dm.emp_no,
	dm.from_date,
	dm.to_date,
	e.calendar_year,
	CASE WHEN YEAR(dm.to_date) >= e.calendar_year
		AND YEAR(dm.from_date) <= e.calendar_year THEN
		1
	ELSE
		0
	END AS active
FROM (
	SELECT
		YEAR(hire_date) AS calendar_year
	FROM
		employees
	GROUP BY
		calendar_year) e
	CROSS JOIN dept_manager dm
	JOIN departments d ON dm.dept_no = d.dept_no
	JOIN employees ee ON dm.emp_no = ee.emp_no
ORDER BY
	dm.emp_no,
	calendar_year;


-- third table - the average salary of female versus male employees in the entire compnay until 2002, with a department filter
SELECT
	e.gender,
	d.dept_name,
	ROUND(AVG(s.salary), 2) AS salary,
	YEAR(s.from_date) AS calendar_year
FROM
	salaries s
	JOIN employees e ON s.emp_no = e.emp_no
	JOIN dept_emp de ON de.emp_no = e.emp_no
	JOIN departments d ON d.dept_no = de.dept_no
GROUP BY
	d.dept_no,
	e.gender,
	calendar_year
HAVING
	calendar_year <= 2002
ORDER BY
	d.dept_no;

-- fourth table - a Stored procedure that queries for male/female average salary per department within a certain range.

DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$ 

CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)

BEGIN
	SELECT
		e.gender, d.dept_name, AVG(s.salary) AS avg_salary
		FROM
			salaries s
			JOIN employees e ON s.emp_no = e.emp_no
			JOIN dept_emp de ON de.emp_no = e.emp_no
			JOIN departments d ON d.dept_no = de.dept_no
		WHERE
			s.salary BETWEEN p_min_salary
			AND p_max_salary
		GROUP BY
			d.dept_no,
			e.gender;
		END$$ 

DELIMITER ;

CALL filter_salary(50000, 90000);

