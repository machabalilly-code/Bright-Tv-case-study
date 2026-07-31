-- Databricks notebook source
SELECT
    COALESCE(A.userid, B.userid) AS sub_id,
    month_id,
    watch_date,
    day_in_dataset,
    day_name,
    day_classification,
    month_name,
    Tv_channel,
    time_of_day,
    hour_of_day,
    screen_time_bucket,
    duration,
    Region,
    age_groups,
    email_flag,
    sm_flag,
    Race,
    Gender

FROM
(
    SELECT
        COALESCE(UserID0, UserID4) AS userid,
        TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
        TO_DATE(RecordDate2) AS watch_date,
        TO_CHAR(RecordDate2, 'DD') AS day_in_dataset,
        DAYNAME(RecordDate2) AS day_name,
        CASE
            WHEN DAYNAME(RecordDate2) IN ('Sat','Sun') THEN 'weekend'
            ELSE 'weekday'
        END AS day_classification,
        MONTHNAME(RecordDate2) AS month_name,
        CASE
            WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
            WHEN Channel2 IN ('SuperSport Live Events',
                              'Live on SuperSport',
                              'Supersport Live Events',
                              'DStv Events 1')
            THEN 'Live Events'
            ELSE Channel2
        END AS Tv_channel,
        DATE_FORMAT(RecordDate2,'HH:mm:ss') AS watch_time,
        CASE
            WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
            WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
            WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
            ELSE '04. Evening'
        END AS time_of_day,
        DATE_FORMAT(`Duration 2`,'HH:mm:ss') AS duration,
        CASE
            WHEN `Duration 2` BETWEEN '00:05:00' AND '00:30:00' THEN '01. Low Usage'
            WHEN `Duration 2` BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage'
            WHEN `Duration 2` > '00:59:59' THEN '03. High Usage'
            ELSE '04. No Usage'
        END AS screen_time_bucket,
        HOUR(RecordDate2) AS hour_of_day
    FROM brighttv.brighttvsales.viewership
) AS A

LEFT JOIN

(
    SELECT
        UserID,
        CASE
            WHEN Province=' ' THEN 'Uncategorized'
            WHEN Province='None' THEN 'Uncategorized'
            WHEN Province IS NULL THEN 'Uncategorized'
            ELSE Province
        END AS Region,

        age,

        CASE
            WHEN age=0 THEN 'Infants'
            WHEN age BETWEEN 1 AND 12 THEN 'Kids'
            WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
            WHEN age BETWEEN 20 AND 35 THEN 'Youth'
            WHEN age BETWEEN 36 AND 50 THEN 'Adult'
            WHEN age BETWEEN 51 AND 65 THEN 'Elder'
            WHEN age>65 THEN 'Pensioner'
        END AS age_groups,

        CASE
            WHEN Email IS NOT NULL
              OR Email=' '
              OR Email NOT IN ('None')
            THEN 1
            ELSE 0
        END AS email_flag,

        CASE
            WHEN `Social Media Handle` IS NOT NULL
              OR `Social Media Handle`=' '
              OR `Social Media Handle` NOT IN ('None')
            THEN 1
            ELSE 0
        END AS sm_flag,

        CASE
            WHEN Race='other' THEN 'None'
            WHEN Race=' ' THEN 'None'
            ELSE Race
        END AS Race,

        CASE
            WHEN Gender=' ' THEN 'None'
            ELSE Gender
        END AS Gender

    FROM brighttv.brighttvsales.userprofile
) AS B

ON A.userid = B.userid;
