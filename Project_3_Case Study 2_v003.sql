CREATE DATABASE case_study_2;
show databases;
USE case_study_2;

# Table - 1 users

create table users (
user_id	int,
created_at	varchar(100),
company_id	int,
language varchar(50),
activated_at varchar(100),
state varchar(50));

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM users;

ALTER TABLE users add column temp_created_at datetime;
UPDATE users SET temp_created_at = STR_TO_DATE(created_at, '%d-%m-%Y %H:%i');
ALTER TABLE users DROP COLUMN created_at;
ALTER TABLE users CHANGE COLUMN temp_created_at created_at DATETIME;

ALTER TABLE users add column temp_activated_at datetime;
UPDATE users SET temp_activated_at = STR_TO_DATE(activated_at, '%d-%m-%Y %H:%i');
ALTER TABLE users DROP COLUMN activated_at;
ALTER TABLE users CHANGE COLUMN temp_activated_at activated_at DATETIME;

# Table - 2 events

create table events (
user_id	int NULL,
occurred_at	varchar(100),
event_type varchar(50),
event_name varchar(100),
location varchar(50),
device varchar(50),
user_type INT );

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv"
INTO TABLE events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM events;


ALTER TABLE events add column temp_occurred_at datetime;
UPDATE events SET temp_occurred_at = STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i');
ALTER TABLE events DROP COLUMN occurred_at;
ALTER TABLE events CHANGE COLUMN temp_occurred_at occurred_at DATETIME;

# Table - 3 email_events

create table email_events (
user_id	int,
occurred_at	varchar(100),
action varchar(100),
user_type int );

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv"
INTO TABLE email_events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM email_events;

ALTER TABLE email_events add column temp_occurred_at datetime;
UPDATE email_events SET temp_occurred_at = STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i');
ALTER TABLE email_events DROP COLUMN occurred_at;
ALTER TABLE email_events CHANGE COLUMN temp_occurred_at occurred_at DATETIME;

/* Weekly User Engagement:
Objective: Measure the activeness of users on a weekly basis.
Your Task: Write an SQL query to calculate the weekly user engagement.

User Growth Analysis:
Objective: Analyze the growth of users over time for a product.
Your Task: Write an SQL query to calculate the user growth for the product.

Weekly Retention Analysis:
Objective: Analyze the retention of users on a weekly basis after signing up for a product.
Your Task: Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.

Weekly Engagement Per Device:
Objective: Measure the activeness of users on a weekly basis per device.
Your Task: Write an SQL query to calculate the weekly engagement per device.

Email Engagement Analysis:
Objective: Analyze how users are engaging with the email service.
Your Task: Write an SQL query to calculate the email engagement metrics.*/

/*1. Objective: Measure the activeness of users on a weekly basis.
Your Task: Write an SQL query to calculate the weekly user engagement.*/

SELECT 
    COUNT(DISTINCT user_id) AS active_users,
    WEEK(occurred_at) AS week_number
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY week_number
ORDER BY active_users DESC;


/*2. User Growth Analysis:
Objective: Analyze the growth of users over time for a product.
Your Task: Write an SQL query to calculate the user growth for the product.*/



SELECT year, week_num, num_users, SUM(num_users) OVER (ORDER BY year, week_num) AS user_growth
FROM (
select 
year(created_at) as year,
week(created_at) as week_num, 
count(DISTINCT user_id) as num_users
from users
group by year, week_num
order by year, week_num) as A;



/*3. Weekly Retention Analysis:
Objective: Analyze the retention of users on a weekly basis after signing up for a product.
Your Task: Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.*/

SELECT 
    COUNT(user_id),
    SUM(CASE WHEN retention_week = 1 THEN 1 ELSE 0 END) AS per_week_retention
FROM
    (SELECT 
        a.user_id,
            a.sign_up_week,
            b.engagement_week,
            b.engagement_week - a.sign_up_week AS retention_week
    FROM
            (SELECT DISTINCT user_id, EXTRACT(WEEK FROM occurred_at) AS sign_up_week
             FROM events
             WHERE event_type = 'signup_flow' AND event_name = 'complete_signup'
             AND EXTRACT(WEEK FROM occurred_at) = 18)a
			 LEFT JOIN (SELECT DISTINCT user_id, EXTRACT(WEEK FROM occurred_at) AS engagement_week
                         FROM events
                         WHERE event_type = 'engagement')b 
                         ON a.user_id = b.user_id)c
GROUP BY user_id
ORDER BY user_id;


SELECT user_id,
activated_at
FROM users
WHERE activated_at > (
SELECT occurred_at
FROM events
ORDER BY occurred_at ASC
LIMIT 1)
ORDER BY user_id;



/*4. Weekly Engagement Per Device:
Objective: Measure the activeness of users on a weekly basis per device.
Your Task: Write an SQL query to calculate the weekly engagement per device.*/


SELECT 
    WEEK(occurred_at) AS week,
    YEAR(occurred_at) AS year,
    device,
    COUNT(DISTINCT user_id) AS engaged_users
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY week, year, device
ORDER BY week;


/*5. Email Engagement Analysis:
Objective: Analyze how users are engaging with the email service.
Your Task: Write an SQL query to calculate the email engagement metrics.*/

SELECT week(occurred_at) as Week,
count( DISTINCT ( CASE WHEN action = "sent_weekly_digest"
THEN user_id end )) as weekly_digest,
count( distinct ( CASE WHEN action = "sent_reengagement_email"
THEN user_id end )) as reengagement_mail,
count( distinct ( CASE WHEN action = "email_open"
THEN user_id end )) as opened_email,
count( distinct ( CASE WHEN action = "email_clickthrough"
THEN user_id end )) as email_clickthrough
FROM email_events
GROUP BY week
ORDER BY week;


SELECT *
FROM events;

SELECT *
FROM email_events;

SELECT *
FROM users;


