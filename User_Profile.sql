-- Databricks notebook source
--i want to see what is in the table
Select*
FROM `brighttv`.`brighttvsales`.`userprofile` 
limit 1;
-----------------------------------------------
--Gender Checks
-----------------------------------------------
SELECT DISTINCT Gender
From `brighttv`.`brighttvsales`.`userprofile`;

SELECT Distinct
    Case 
        WHEN gender = 'None' THEN 'Unknown'
        WHEN gender = ' ' THEN 'Unknown'
        WHEN gender IS NULL THEN 'Unknown'
        Else gender
    END AS Sex	
    FROM `brighttv`.`brighttvsales`.`userprofile`;
    ----------------------------------------------
    --Race checks
    ---------------------------------------------
    SELECT DISTINCT race
        FROM`brighttv`.`brighttvsales`.`userprofile`;  

  SELECT COUNT(Distinct UserID) As subs,
    case 
        WHEN race = 'other' THEN 'Unknown'
        WHEN race = 'None' THEN 'Unknown'
        WHEN race = ' ' THEN 'Unknown'
        WHEN race IS NULL THEN 'Unknown'
        Else race
    END AS ethnicity
    FROM `brighttv`.`brighttvsales`.`userprofile`
    GROUP BY ethnicity;
    ----------------------------------------------
    --Provice checks
    ----------------------------------------------
    SELECT DISTINCT province
    FROM`brighttv`.`brighttvsales`.`userprofile`;

    SELECT Distinct 
     case 
        WHEN province = 'None' THEN 'Unknown'
        WHEN province = ' ' THEN 'Unknown'
        WHEN province IS NULL THEN 'Unknown'
     else province 
     End As Region
    FROM`brighttv`.`brighttvsales`.`userprofile`;
    --------------------------------------------------
    --Age checks
    --------------------------------------------------
    SELECT MIN(Age) As min_age,
           MAX(Age) As max_age,
           AVG(Age) As mean_age
    FROM `brighttv`.`brighttvsales`.`userprofile`;

    SELECT
    case 
        WHEN age = 0 THEN 'infant'
        WHEN age BETWEEN 1 AND 12 THEN 'Kids'
        WHEN age BETWEEN 13 AND 17 THEN 'Youth'
        WHEN age BETWEEN 18 AND 36 THEN 'Young Adults'
        WHEN age BETWEEN 36 AND 50 THEN 'Adults'
        WHEN age > 50 AND AGE <=60 THEN 'Elder'
    End As Age_group
    From `brighttv`.`brighttvsales`.`userprofile`;

    ---------------------------------------------------
CREATE OR REPLACE TEMPORARY TABLE processed_userprofile As (
SELECT 
    UserID,
    
    Case 
        WHEN (EMAIL IS NOT NULL) AND (`EMAIL` <> ' ') AND (`EMAIL` NOT IN ('NONE') ) THEN 1 
        ELSE 0
    END AS email_flag,

    Case 
        WHEN Name IS NOT NULL THEN 1
        ELSE 0
     END AS Name_flag,
    
    Case 
        WHEN (`Social Media Handle` IS NOT NULL) AND (`Social Media Handle` <> ' ') AND (`Social Media Handle` NOT IN ('NONE') ) THEN 1 
        ELSE 0
    END AS Social_media_flag,
   
    Case 
        WHEN Surname IS NOT NULL THEN 1
        ELSE 0
        END AS Surname_flag,

    Case 
        WHEN gender ='NONE' THEN 'UNKNOWN'
        WHEN gender = ' ' THEN 'Unknown'
        WHEN gender IS NULL THEN 'Unknown'
    Else gender
    END AS Sex,

 Race,
    case 
        WHEN race = 'other' THEN 'Unknown'
        WHEN race = 'None' THEN 'Unknown'
        WHEN race = ' ' THEN 'Unknown'
        WHEN race IS NULL THEN 'Unknown'
     Else race
    END AS ethnicity,

Province,
    case 
        WHEN province = 'None' THEN 'Unknown'
        WHEN province = ' ' THEN 'Unknown'
        WHEN province IS NULL THEN 'Unknown'
        else province
        End As Region,
    
    AGE,
    case 
        WHEN age = 0 THEN '01.infant: 0'
        WHEN age BETWEEN 1 AND 12 THEN '02.Kids: 1 - 12'
        WHEN age BETWEEN 13 AND 17 THEN '03.Youth: 13 - 17'
        WHEN age BETWEEN 18 AND 36 THEN '04.Young Adults: 18 - 35'
        WHEN age BETWEEN 36 AND 58 THEN '05.Adult: 36 - 50'
        WHEN age > 50 AND AGE <=60 THEN '06.Elder: 51 - 60'
        WHEN age > 60 THEN '07.Pensioner: >60'
    End As Age_group
    FROM `brighttv`.`brighttvsales`.`userprofile`);

SELECT count(*) as cnt,
       count(distinct userid) as active_subs
FROM processed_userprofile;

CREATE OR REPLACE TEMPORARY TABLE viewership AS (
    
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
        WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
    ELSE Channel2
    END AS Tv_channel,

    date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
    CASE
        WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
        WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
        WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
        WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
    END AS time_of_day

FROM `brighttv`.`brighttvsales`.`viewership`
);

