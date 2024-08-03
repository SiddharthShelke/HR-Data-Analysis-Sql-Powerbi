create database projects;
use projects;

select * from hr;

# data cleaning

alter table hr
change column ï»¿id emp_id varchar(20) null;

SET sql_safe_updates = 0;

describe hr;

select birthdate from hr;

update hr
set birthdate = case
when birthdate like "%/%" then date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
when birthdate like "%-%" then date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
else null
end;

alter table hr
modify column birthdate date;

update hr
set hire_date = case
when hire_date like "%/%" then date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
when hire_date like "%-%" then date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
else null
end;

alter table hr
modify column hire_date date;

select termdate from hr;

update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate!=' ';

update hr
set termdate = '0000-00-00'
where termdate = '';

select termdate from hr;

alter table hr
modify column termdate date;

UPDATE hr
SET termdate = NULL
WHERE termdate = '0000-00-00';

alter table hr
add column age int;

# update age column. Instead of date we will show age
update hr
set age = timestampdiff(year, birthdate, curdate());

select birthdate, age from hr;

#check min and max ages
select min(age) as youngest, max(age) as oldest
from hr;

#check how many less than 18
select count(*) from hr
where age<18;

-- Questions 

-- 1. What is the gennder breakdown of employees in the company?
select gender, count(*) as count
from hr
where age>=18 and termdate is null
group by gender;

-- 2. What is the race/ethinicity breakdown of employees in teh company?
select race, count(*) as count from hr
where age>=18 and termdate is null
group by race
order by count desc;

-- 3. What is the age distribution of employees in the company?
select 
min(age)as youngest, 
max(age) as oldest
from hr
where age >=18 and termdate is null;

-- create an age group to see number of employees in each age_group
select
  case
    when age>=18 and age <=24 then '18-24'
    when age>=25 and age <=34 then '25-34'
    when age>=35 and age <=44 then '35-44'
    when age>=45 and age <=54 then '45-54'
    when age>=55 and age <=64 then '55-64'
    else '65+'
    end as age_group,
    count(*) as count
    from hr
    where age>=18 and termdate is null
    group by age_group
    order by age_group;
    
-- I also want to know gender distribution among age groups

select
  case
    when age>=18 and age <=24 then '18-24'
    when age>=25 and age <=34 then '25-34'
    when age>=35 and age <=44 then '35-44'
    when age>=45 and age <=54 then '45-54'
    when age>=55 and age <=64 then '55-64'
    else '65+'
    end as age_group, gender,
    count(*) as count
    from hr
    where age>=18 and termdate is null
    group by age_group, gender
    order by age_group, gender;
    
-- 4. How many employees work at headquarters vs remotoe locations?
select location, count(*) as count
from hr
where age>=18 and termdate is null
group by location;

-- 5. What is the average length of employment for employees who have been terminated?
select
round(avg(datediff(termdate, hire_date))/365,0) as avg_length_employment
from hr
where termdate<= curdate() and termdate is not null and age >=18;


-- 6. How does the gender distribution vary across departments and job titles?
select department, gender, count(*) as count
from hr
where age>=18 and termdate is null
group by department, gender
order by department;


-- 7. What is the distribution of job titles across the company?
select jobtitle, count(*)as count
from hr
where age>=18 and termdate is null
group by jobtitle
order by jobtitle desc;


-- 8. Which department has the highest turnover rate?
-- turnover is the rate at which the employees leave a company
-- how long they work till they quit or fired.
-- we will be using subquery
-- total no of employees who have left over a given period /
-- total no employeed who were in that dept during that time
select department,
 total_count,
 terminated_count,
 (terminated_count/total_count) as termination_rate
 from (
   select department, count(*) as total_count,
          sum(case when termdate is not null and termdate <= curdate()
              then 1 else 0 end) as terminated_count
		  from hr
          where age>=18
          group by department
          ) as subquery
   order by termination_rate desc;
   
   
-- 9. What is the distribution of employees across loactions by city and state?
-- As there are many cities, it would be difficult to map therefore we will only
-- use location state
   select location_state, count(*) as count
   from hr
   where age>=18 and termdate is null
   group by location_state
   order by count desc;
   
   
-- 10. How has the company's employee count changed over time based on hire and term dates?
-- It will tell increase or decrease in percentage of hire over the years
   
   select
     year, hires, terminations, hires-terminations as net_change,
     round(((hires-terminations)*100/hires),2) as net_change_percent
	from (
     select year(hire_date) as year,
     count(*) as hires,
     sum(case when termdate is not null and termdate <= curdate() then 1 else 0 end) as terminations
     from hr
     where age>=18
     group by year(hire_date)
	 ) as subquery
   order by year asc;
   
-- THE EMPLOYEE COUNT HAS BEEN INCREASING
   
   
-- 11. What is the tenure distribution for each department?
   select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
   from hr
   where termdate <=curdate() and termdate is not null and age>=18
   group by department;

    
    
    

