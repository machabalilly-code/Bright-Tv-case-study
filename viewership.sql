-- Databricks notebook source

SELECT * FROM `brighttv`.`brighttvsales`.`viewership`;
--------------------------------------------------
-- Checking all the columns in the table viewrship
--------------------------------------------------
SELECT *
FROM `brighttv`.`brighttvsales`.`viewership`;	
--------------------------------------------------
-- Checking if there is any row where in the column userid0 is empty
--------------------------------------------------
SELECT *
FROM `brighttv`.`brighttvsales`.`viewership`
WHERE UserID0 IS NULL 
    OR userid4 IS NULL;
------------------------------------------------------
SELECT *
FROM brighttv.brighttvsales.viewership
WHERE userid0 <> userid4;

----------------------------------------------------------
-- Checking for duplicates
----------------------------------------------------------
SELECT COUNT(*),
       UserID0, RecordDate2
FROM brighttv.brighttvsales.viewership
GROUP BY UserID0, RecordDate2
HAVING COUNT(*)>1;

SELECT
    UserID0,
    RecordDate2,
    COUNT(*) AS duplicate_count
FROM brighttv.brighttvsales.viewership
GROUP BY
    UserID0,
    RecordDate2
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
----------------------------------------
SELECT UserID0,
       TO_DATE(RecordDate2) AS watch_date,
       date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
       date_format(`Duration 2`, 'HH:mm:ss') AS duration,
        Channel2
FROM brighttv.brighttvsales.viewership
WHERE userid0=810044;

WITH ranked_records AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                UserID0,
                TO_DATE(RecordDate2),
                date_format(RecordDate2, 'HH:mm:ss'),
                date_format(`Duration 2`, 'HH:mm:ss'),
                Channel2
            ORDER BY RecordDate2
        ) AS row_num
    FROM brighttv.brighttvsales.viewership
)

SELECT * EXCEPT (row_num)
FROM ranked_records
WHERE row_num = 1;

WITH cte1 AS (
SELECT DISTINCT *
FROM brighttv.brighttvsales.viewership
)
SELECT COUNT(*) AS duplicate_cnt,
       UserID0,
       TO_DATE(RecordDate2) AS watch_date,
       date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
       date_format(`Duration 2`, 'HH:mm:ss') AS duration,
        Channel2
FROM cte1
--WHERE userid0=810044
GROUP BY ALL
HAVING COUNT(*) > 1
ORDER BY duplicate_cnt DESC;

-- PART B

WITH user_profiles AS (
SELECT UserID,
CASE
WHEN Province=' ' THEN 'Uncategorized'
WHEN Province='None' THEN 'Uncategorized'
WHEN Province IS NULL THEN 'Uncategorized'
ELSE Province
END AS Region,
--------------------------------------------------------------------
age,
CASE
WHEN age = 0 THEN 'Infants'
WHEN age BETWEEN 1 AND 12 THEN 'Kids'
WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
WHEN age BETWEEN 20 AND 35 THEN 'Youth'WHEN age BETWEEN 36 AND 50 THEN 'Adult'
WHEN age BETWEEN 51 AND 65 THEN 'Elder'
WHEN age >65 THEN 'Pensioner'
END AS age_groups,
CASE
WHEN Email IS NOT NULL OR Email=' ' OR Email NOT IN ('None')THEN 1
ELSE 0
END AS email_flag,
CASE
WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle`=' ') OR (`Social Media Handle` NOT IN ('None')) THEN 1 
        ELSE 0 
    END AS sm_flag,
CASE
WHEN Race='other' THEN 'None'
WHEN Race=' ' THEN 'None'
ELSE Race
END AS Race,
CASE
WHEN gender =' ' THEN 'None'
ELSE gender
END AS Gender
FROM brighttv.brighttvsales.userprofile
),
viewership AS (
SELECT
COALESCE(UserID0,userid4) AS userid,
TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
TO_DATE(RecordDate2) AS watch_date,
--TIME(RecordDate2) AS watch_time,
TO_CHAR(RecordDate2, 'DD') AS day_of_week,
DAYNAME(RecordDate2) AS day_name,
CASE
WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
ELSE 'weekday'
END AS day_classification,
MONTHNAME(RecordDate2) AS month_name,
CASE
WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events',
'DStv Events 1') THEN 'Live Events'
ELSE Channel2
END AS Tv_channel,date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
CASE
WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
END AS time_of_day,
DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,
CASE
WHEN `Duration 2` BETWEEN '00:05:00' AND '00:30:00' THEN '01. Low Usage: <30 min'
WHEN `Duration 2` BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage: <60 min'
WHEN `Duration 2` > '00:59:59' THEN '03. High Usage: >60 min'
ELSE '04. No Usage'
END AS screen_time_bucket,
HOUR(RecordDate2) AS hour_of_day
FROM brighttv.brighttvsales.viewership
)
SELECT Coalesce(A.userid,B.userid) AS sub_id,
    month_id,
    watch_date,
    day_of_week,
    day_name,
    day_classification,month_name,
    Tv_channel,
    time_of_day,
    hour_of_day,
    screen_time_bucket,
--user_flag,
    duration,
    Region,
    age_groups,
    email_flag,
    sm_flag,
Race,
Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
ON A.userid=B.userid;

