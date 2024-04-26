create database case_study_1;

use case_study_1;

create table job_data (
ds varchar(100),
job_id int,
actor_id int,
event varchar(100),
language char,
time_spent int,
org char );

SHOW VARIABLES LIKE 'secure_file_priv';

SELECT *
FROM job_data;



/*Jobs Reviewed Over Time:
Objective: Calculate the number of jobs reviewed per hour for each day in November 2020.
Your Task: Write an SQL query to calculate the number of jobs reviewed per hour for each 
day in November 2020.

Throughput Analysis:
Objective: Calculate the 7-day rolling average of throughput (number of events per second).
Your Task: Write an SQL query to calculate the 7-day rolling average of throughput. 
Additionally, explain whether you prefer using the daily metric or the 7-day rolling 
average for throughput, and why.

Language Share Analysis:
Objective: Calculate the percentage share of each language in the last 30 days.
Your Task: Write an SQL query to calculate the percentage share of each language over 
the last 30 days.

Duplicate Rows Detection:
Objective: Identify duplicate rows in the data.
Your Task: Write an SQL query to display duplicate rows from the job_data table.*/


/*Jobs Reviewed Over Time:
Objective: Calculate the number of jobs reviewed per hour for each day in November 2020.
Your Task: Write an SQL query to calculate the number of jobs reviewed per hour for each 
day in November 2020.*/

SELECT 
    ds AS date,
    COUNT(job_id) AS number_of_jobs,
    (SUM(time_spent) / 3600) AS time_spent_per_hour
FROM
    job_data
WHERE
    ds BETWEEN '1-11-2020' AND '30-11-2020'
GROUP BY ds
ORDER BY ds;

/*SELECT ds AS Date, COUNT(job_id) AS Cnt_JID, 
ROUND((SUM(time_spent)/3600),2) AS Tot_Time_Sp_Hr,  
ROUND((COUNT(job_id)/(SUM(time_spent)/3600)),2) AS Job_Rev_PHr_PDy 
 FROM job_data 
 WHERE ds BETWEEN '01-11-2020' AND '30-11-2020'
 GROUP BY ds 
 ORDER BY ds;
 
 SELECT
    ds,
    SUM(time_spent) AS total_time_spent_seconds,
    SUM(time_spent) / 3600.0 AS total_time_spent_hours
FROM
    job_data
GROUP BY
   ds;

select
count(distinct job_id)/(30*24) as num 
from job_data
WHERE ds BETWEEN '01-11-2020' AND '30-11-2020';*/



/*Throughput Analysis:
Objective: Calculate the 7-day rolling average of throughput (number of events per second).
Your Task: Write an SQL query to calculate the 7-day rolling average of throughput. 
Additionally, explain whether you prefer using the daily metric or the 7-day rolling 
average for throughput, and why.*/


# weekly_throughput
select round((count(event)/sum(time_spent)),2) as weekly_throughput 
from job_data;
# daily_throughput
select ds as date, round((count(event)/sum(time_spent)),2) as daily_metric
from job_data group by date;

/*Language Share Analysis:
Objective: Calculate the percentage share of each language in the last 30 days.
Your Task: Write an SQL query to calculate the percentage share of each language over 
the last 30 days.*/

SELECT 
	language, 
	count(language) as total_language,
    (COUNT(language)*100)/SUM(count(language)) over() as perc_share
FROM 
    job_data
GROUP BY language
ORDER BY language DESC;

/*Duplicate Rows Detection:
Objective: Identify duplicate rows in the data.
Your Task: Write an SQL query to display duplicate rows from the job_data table.*/

SELECT 
    actor_id, COUNT(actor_id) AS total_count
FROM
    job_data
GROUP BY actor_id
HAVING total_count > 1;

