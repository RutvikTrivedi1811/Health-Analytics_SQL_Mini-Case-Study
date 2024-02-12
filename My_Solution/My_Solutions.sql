SELECT * FROM health.user_logs;

select distinct measure from  user_logs;

-- How many unique users exist in the logs dataset?

select count(distinct id)
from user_logs;


-- For questions 2-8 I have created a temporary table

DROP TABLE IF EXISTS user_measure_count;

CREATE TEMPORARY TABLE user_measure_count
SELECT
    id,
    COUNT(*) AS measure_count,
    COUNT(DISTINCT measure) as unique_measures
  FROM health.user_logs
  GROUP BY id; 
  
  -- How many total measurements do we have per user on average?   -- mean
  SELECT
  ROUND(avg(measure_count)) 
FROM user_measure_count;
  
 --  What about the median number of measurements per user?
 
 WITH ranked as (
 Select measure_count, 
 row_number() over(order by measure_count) as r,
 count(measure_count) over() as c
 from user_measure_count
 )
 
select avg(measure_count)
from ranked
where r IN (CEIL(c / 2), CEIL(c / 2) + 1, ceil(c/2)-1);

 
 -- How many users have 3 or more measurements?
 
with user_measure as (
select id, count(measure) as measure_count
from user_logs
Group by id
)

select count(id)
from user_measure
where measure_count >= 3;


-- How many users have 1,000 or more measurements?

  with user_measure as (
select id, count(measure) as measure_count
from user_logs
Group by id
  )
  select count(id)
from user_measure
where measure_count >= 1000;


-- what is the number and percentage of the active user base who:

-- 1. Have logged blood glucose measurements?

with measure as (                              -- to find total count of user with blood glucose measure
select count(id) as Total_count
from user_logs
where measure = 'blood_glucose'  
),
measure2 as (                                   -- to find total user id
select count(*) as total_user_count
from user_logs
)

select total_count, (total_user_count/total_count)*100 as percentage           -- percentage
from measure, measure2;


-- 2. Have at least 2 types of measurements?
with measure as (                              -- to find distinct measure
SELECT
    id,
    COUNT(*) AS measure_count,
    COUNT(DISTINCT measure) as unique_measure
  FROM health.user_logs
  GROUP BY id
  ),
measure2 as (
  select count(id) as user_count, ( select count(id) 
  from measure ) as tuc
  from measure 
  where unique_measure > 1 
  )
  

select user_count, (user_count/tuc)*100 as percentage           -- percentage
from measure, measure2 limit 1;

-- 3. Have all 3 measures - blood glucose, weight and blood pressure?

with measure as (                              -- to find distinct measure
SELECT
    id,
    COUNT(*) AS measure_count,
    COUNT(DISTINCT measure) as unique_measure
  FROM health.user_logs
  GROUP BY id
  ),
measure2 as (
  select count(id) as user_count, ( select count(id) 
  from measure ) as tuc
  from measure 
  where unique_measure > 2 
  )
  

select user_count, (user_count/tuc)*100 as percentage           -- percentage
from measure, measure2 limit 1;


-- For users that have blood pressure measurements:
-- What is the median systolic/diastolic blood pressure values?

SELECT
 PERCENT_RANK() over (ORDER BY systolic) AS median_systolic,
  PERCENT_RANK() over (ORDER BY diastolic) AS median_diastolic
FROM health.user_logs
WHERE measure = 'blood_pressure';
