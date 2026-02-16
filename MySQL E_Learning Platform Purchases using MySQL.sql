-- MySQL Module End Project - E_Learning Platform Purchases using MySQL
-- Step 1: create a database
create database elearning_platform;
use elearning_platform;

-- Step 2: Create Tables - 1.	Table: learners
create table learners (
	learner_id int primary key auto_increment,
    full_name varchar(100) not null,
    country varchar(50) not null
);

-- 2.	Table: courses
create table courses (
	course_id int primary key auto_increment,
    course_name varchar(150) not null,
    category varchar(50) not null,
    unit_price decimal(10, 2) not null
);

-- 3.	Table: purchases - (Transaction details with Foreign Keys)
drop table if exists purchases;
create table purchases (
	purchase_id int primary key auto_increment,
    learner_id int not null,
    course_id int not null,
    quantity int not null,
    purchase_date date not null,
    foreign key (learner_id) references learners(learner_id),
    foreign key (course_id) references courses(course_id)
);


-- Step 3: Insert All Three Tables
-- Insert 5 Learners
insert into learners 
(full_name, country) values
('Pranav Kumar', 'India'),
('Sarah Johnson', 'USA'),
('Ahmed Ali', 'UAE'),
('Maria George', 'Spain'),
('Li Wei', 'China');

-- Insert 5 Courses (different categories)
insert into courses (course_name, category, unit_price) values
('Python for Data Science', 'Programming', 2999.00),
('Power BI Mastery', 'Data Analytics', 1999.00),
('Web Development Bootcamp', 'Programming', 3499.00),
('Excel for Business', 'Data Analytics', 999.00),
('Digital Marketing Pro', 'Marketing', 1499.00);

-- In courses table change the column datatype null allowed
alter table courses
modify column category varchar(50) null;

-- Add not purchased values
insert into courses (course_name, category, unit_price) values
('SQL Advanced', 'Not Purchased', 1299.00),
('Machine Learning Intro', 'Not Purchased', 3999.00);

-- Insert 8 Purchase Records
insert into purchases (learner_id, course_id, quantity, purchase_date) values
(1, 1, 1, '2025-01-15'),
(1, 2, 1, '2025-02-20'),
(2, 1, 2, '2025-01-18'),
(3, 3, 1, '2025-03-10'),
(4, 4, 1, '2025-02-05'),
(5, 5, 1, '2025-03-25'),
(2, 4, 1, '2025-02-28'),
(3, 2, 1, '2025-03-15');

-- Step 4: Data Exploration Using Joins

select l.full_name as learners_name, l.country,
	c.course_name, c.category, p.quantity, round(p.quantity * c.unit_price, 2) as total_amount,
    p.purchase_date
from purchases p
inner join learners l on p.learner_id = l.learner_id
inner join courses c on p.course_id = c.course_id
order by total_amount desc;

-- left join
select l.full_name as learners_name, l.country,
	c.course_name, c.category, p.quantity, round(p.quantity * c.unit_price, 2) as total_amount,
    p.purchase_date
from learners l
left join purchases p on l.learner_id = p.learner_id
left join courses c on p.course_id = c.course_id
order by total_amount desc;

-- right join
select l.full_name as learners_name, l.country,
	c.course_name, c.category, p.quantity, round(p.quantity * c.unit_price, 2) as total_amount,
    p.purchase_date
from purchases p
right join learners l
	on l.learner_id = p.learner_id
inner join courses c
	on p.course_id = c.course_id
order by total_amount desc;

-- step 4: Analytical Queries
-- Display each learner’s total spending (quantity × unit_price) along with their country.
select l.full_name as learner_name, l.country,
	coalesce(round(sum(p.quantity * c.unit_price), 2), 0.00) as total_spend_amount
from learners l
left join purchases p on l.learner_id = p.learner_id
left join courses c on c.course_id = p.course_id
group by l.learner_id, l.full_name, l.country
order by total_spend_amount desc;

-- Find the top 3 most purchased courses based on total quantity sold
select c.course_name, c.category, sum(p.quantity) as total_quantity_sold
from courses c
inner join purchases p 
	on c.course_id = p.course_id
group by c.course_id, c.course_name, c.category
order by total_quantity_sold desc
limit 3;

-- Show each course category’s total revenue and the number of unique learners who purchased from that category
select c.category, round(sum(p.quantity * c.unit_price), 1) as total_revenue,
	count(distinct p.learner_id) as unique_learners
from courses c
inner join purchases p on c.course_id = p.course_id
group by c.category
order by total_revenue desc;

-- List all learners who have purchased courses from more than one category.
select l.full_name as learners_name, l.country, count(distinct c.category) as categories_purchased
from learners l
	inner join purchases p on l.learner_id = p.learner_id
	inner join courses c on c.course_id = p.course_id
group by l.learner_id, l.full_name, l.country
having count(distinct c.category) > 1;

-- Identify courses that have not been purchased at all.
select c.course_id, c.course_name, p.course_id as purchase_course_id from courses c
left join purchases p on c.course_id = p.course_id
order by c.course_id;

-- Q5 FIXED: Clean unpurchased courses list
SELECT 
    c.course_name,
    c.category,
    c.unit_price
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
WHERE p.course_id IS NULL;   


