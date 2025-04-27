/*
===============================================================================
    INTERMEDIATE TO ADVANCED SQL PRACTICE (2025)
    Author: Vivek Kumar
    Description: This file contains table creation, data insertions,
                 and challenging SQL problems designed for real-world
                 2025 IT interview scenarios.
===============================================================================
*/

/* ======================= */
/* 1. Create Tables         */
/* ======================= */

-- Employees Table
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    designation VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    manager_id INT
);

-- Projects Table
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    client_name VARCHAR(100)
);

-- Employee_Project Table
CREATE TABLE employee_project (
    emp_id INT,
    project_id INT,
    allocation_percentage INT CHECK (allocation_percentage BETWEEN 0 AND 100),
    role VARCHAR(50),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    PRIMARY KEY (emp_id, project_id)
);

-- Leaves Table
CREATE TABLE leaves (
    leave_id INT PRIMARY KEY,
    emp_id INT,
    leave_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) CHECK (status IN ('Approved', 'Pending', 'Rejected')),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

/* ======================= */
/* 2. Insert Sample Data    */
/* ======================= */

-- Insert Employees
INSERT INTO employees VALUES 
(1, 'Vivek Kumar', 'Senior Developer', 'IT', 90000, '2020-06-15', NULL),
(2, 'Amit Sharma', 'Tech Lead', 'IT', 120000, '2018-03-01', 1),
(3, 'Priya Mehta', 'Business Analyst', 'Finance', 75000, '2019-07-20', NULL),
(4, 'John Doe', 'Manager', 'IT', 150000, '2016-01-01', NULL),
(5, 'Sara Khan', 'Developer', 'IT', 80000, '2022-11-10', 2);

-- Insert Projects
INSERT INTO projects VALUES 
(101, 'NextGen ERP', '2024-01-10', NULL, 'Infosys'),
(102, 'AI Chatbot', '2023-09-05', '2024-03-31', 'TCS'),
(103, 'Cloud Migration', '2023-01-01', NULL, 'Wipro');

-- Insert Employee_Project Relations
INSERT INTO employee_project VALUES 
(1, 101, 100, 'Developer'),
(2, 101, 100, 'Lead'),
(5, 102, 50, 'Developer'),
(5, 103, 50, 'Support'),
(3, 103, 100, 'Analyst');

-- Insert Leaves
INSERT INTO leaves VALUES 
(1, 1, 'Sick', '2025-02-01', '2025-02-03', 'Approved'),
(2, 5, 'Annual', '2025-03-10', '2025-03-15', 'Pending'),
(3, 3, 'Casual', '2025-01-20', '2025-01-21', 'Rejected');

/* ======================= */
/* 3. Practice Problems     */
/* ======================= */

/* Problem 1:
   Find all employees who are NOT allocated to any project.
   Output: emp_id, emp_name, designation
*/
select e.emp_id,e.emp_name,e.designation,ep.project_id
from employees e
left join employee_project ep 
on e.emp_id = ep.emp_id
where project_id is null;


/* Problem 2:
   List employees along with the number of projects they are working on.
   Output: emp_id, emp_name, number_of_projects
*/
select e.emp_id,e.emp_name,ep.project_id, COUNT(ep.project_id) as num_of_projects
from employees e
left join employee_project ep 
on e.emp_id = ep.emp_id
group by e.emp_id,e.emp_name
order by num_of_projects desc;


/* Problem 3:
   Find the Top 2 highest salaried employees in each department.
   Use Window Functions.
   Output: department, emp_name, salary, rank_in_department
*/
with cte as
(select department,emp_name
,salary
,rank () over ( partition by department order by salary desc) as rank_of_employees
from employees) 
select * from cte where rank_of_employees <=2;


/* Problem 4:
   List all projects and total number of employees assigned to each project.
   Output: project_id, project_name, total_employees
*/
Select p.project_id,p.project_name,count(ep.emp_id)
from projects p
left join employee_project ep
on p.project_id = ep.project_id
group by p.project_id,p.project_name
order by count(ep.emp_id)


/* Problem 5:
   Find employees who have taken more than 1 leave.
   Output: emp_id, number_of_leaves
*/
select emp_id,count(leave_id) as no_of_leaves
from leaves
group by emp_id
having count(leave_id) >1;

/* ======================= */
/*  End of File             */
/* ======================= */


--6. Find the average salary of employees by department and display the department with and average salary greater than $85,000


select department,avg(salary)
--row_number () over (partition by department)
from employees
group by department
having avg(salary) >85000;

---7.  For each project, find the employee who worked on it with the highest allocation percentage.
select * from employees;
select * from projects;
select * from employee_project


with cte as
(select e.emp_name,ep.project_id,p.project_name,ep.allocation_percentage
,row_number() over (partition by p.project_id order by ep.allocation_percentage desc) 
from employees e
join employee_project ep
on e.emp_id = ep.emp_id 
join projects p
on ep.project_id = p.project_id) 
select * from cte
where row_number =1 ;

---8. Find the employees who have been working  in the company for more than 3 years and not managers


select * from employees
where hire_date <= CURRENT_DATE - INTERVAL '3 Years'
and designation not in ('Manager');


---9. Get a list of projects that have not started yet (Start date is in future).

select * from projects
where start_date > current_date;

---10. Find the total number of leaves taken by each employee. Show only employees who have taken more than 3 days of leave

select * from leaves;

select e.emp_name,e.emp_id
,sum(cast(l.end_date-l.start_date as integer )+1)
from leaves l
join employees e
on e.emp_id = l.emp_id
group by e.emp_name,e.emp_id
having sum(cast(l.end_date-l.start_date as integer )+1) >3;
