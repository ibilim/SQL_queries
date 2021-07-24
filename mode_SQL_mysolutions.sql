### The following SQL queries are emerged from my solutions of problems on mode.com ---- SQL Advanced Level------

SELECT duration_seconds,
       SUM(duration_seconds) OVER (ORDER BY start_time) AS running_total,start_time
  FROM tutorial.dc_bikeshare_q1_2012
LIMIT 100

####
SELECT start_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_total,
       COUNT(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_count,
       AVG(duration_seconds) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_avg
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
LIMIT 100

#####
SELECT bike.start_terminal, 
       bike.duration_seconds,
      SUM (bike.duration_seconds)  OVER 
      (PARTITION BY start_terminal ORDER BY start_time )  AS running_total,
      (duration_seconds/SUM(duration_seconds) OVER (PARTITION BY start_terminal)) AS pct_of_total_time
      

FROM tutorial.dc_bikeshare_q1_2012 bike 
WHERE start_time <'2012-01-08'
LIMIT 100

#####
SELECT end_terminal,
       duration_seconds,
       SUM(duration_seconds) OVER
         (PARTITION BY end_terminal ORDER BY duration_seconds DESC)
         AS running_total
         
FROM tutorial.dc_bikeshare_q1_2012
WHERE start_time < '2012-01-08'
LIMIT 100
####

SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER 
       (PARTITION BY start_terminal ORDER BY start_time)
                    AS row_number
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
LIMIT 100

####
SELECT *

FROM
(SELECT bike.start_terminal, 
        bike.duration_seconds,
       DENSE_RANK() OVER 
       (PARTITION BY bike.start_terminal ORDER BY bike.duration_seconds DESC) AS longest_shortest 

FROM tutorial.dc_bikeshare_q1_2012 bike
WHERE bike.start_time< '2012-01-08') sub

WHERE sub.longest_shortest<6
LIMIT 100

####
SELECT start_terminal,
       duration_seconds,
       NTILE(4) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
          AS quartile,
       NTILE(5) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS quintile,
       NTILE(100) OVER
         (PARTITION BY start_terminal ORDER BY duration_seconds)
         AS percentile
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'
 ORDER BY start_terminal, duration_seconds
 LIMIT 800
 
 ####
 SELECT duration_seconds,
      
      NTILE(100) OVER (ORDER BY duration_seconds) AS percentile_dration
FROM tutorial.dc_bikeshare_q1_2012 
WHERE start_time< '2012-01-08'
LIMIT 100

#####
SELECT  start_terminal,  
        duration_seconds,
        LAG(duration_seconds,1) OVER (PARTITION BY start_terminal ORDER BY duration_seconds) AS lagged,
        LEAD(duration_seconds,1) OVER (PARTITION BY start_terminal ORDER BY duration_seconds ) AS leaded

FROM tutorial.dc_bikeshare_q1_2012
LIMIT 100

#####

SELECT teams.conference, 
        sub.*
      
FROM ( SELECT
        players.school_name,
        COUNT(*) AS players
FROM benn.college_football_players players
GROUP BY 1 ) sub

JOIN benn.college_football_teams  teams
ON teams.school_name=sub.school_name

#####

SELECT DATE_TRUNC('week',events.occurred_at) AS weeks,
        COUNT(1)
FROM tutorial.yammer_events events
GROUP BY weeks
LIMIT 100

###   -----SQL intermediate level-----

SELECT year,month, MIN(low) AS minimum,
              MAX(high) AS maximum FROM tutorial.aapl_historical_stock_price
GROUP BY year,month
ORDER BY year,month

#####

SELECT year, month, MIN(low) AS month_low 
FROM tutorial.aapl_historical_stock_price
GROUP BY year, month
HAVING MIN(low) <100
ORDER BY year, month

#####


SELECT player_name, year, 
CASE WHEN year='SR' THEN 'yes'
ELSE 'no' END AS is_a_senior
FROM benn.college_football_players

#####

SELECT player_name, state, CASE WHEN state='CA' THEN 'yes'
ELSE NULL END AS is_from_California
FROM benn.college_football_players
ORDER BY is_from_California 

#####


SELECT player_name, weight, 
CASE WHEN weight > 250 THEN 'over 250'
      WHEN weight > 200 AND weight <= 250 THEN '201-250'
      WHEN weight > 175 AND weight <= 200 THEN '176-200'
     ELSE '175 or Under' END AS weight_scala
FROM benn.college_football_players
 
 ####
 
 SELECT player_name,height,
CASE 
     WHEN height >= 50 AND height<60 THEN 'normal'
     WHEN height >=60 AND height <=70 THEN 'tall'
     WHEN height >70 THEN 'really tall'
     ELSE 'dwarf' END AS height_compare

FROM benn.college_football_players

####

SELECT * , CASE 
    WHEN year='JR' OR year='SR' THEN player_name
    ELSE NULL END AS  Senior_or_junior
FROM benn.college_football_players


####


SELECT CASE 
  WHEN year='FR' THEN 'FR'
  WHEN year='SR' THEN 'SR'
  ELSE 'Not_FR' END  AS Count_first_last,
  COUNT(1)
FROM benn.college_football_players
GROUP BY Count_first_last

####

SELECT CASE 
    WHEN state='CA' THEN 'CA'
    WHEN state='OR' THEN 'OR'
    WHEN state='WA'  THEN 'WA'
    WHEN state='TX' THEN 'TX'
    ELSE 'Other' END AS  new_region,
    COUNT(1)
FROM benn.college_football_players
WHERE weight>300
GROUP BY new_region
--HAVING weight>300

####

SELECT *,players.school_name AS players_school_name,
       teams.school_name AS teams_school_name
FROM benn.college_football_players players
JOIN benn.college_football_teams  teams
ON players.school_name=teams.school_name

#####


SELECT players.player_name, 
      players.school_name,
      teams.conference 
FROM benn.college_football_players players
JOIN benn.college_football_teams teams 
ON players.school_name=teams.school_name
WHERE teams.division='FBS (Division I-A Teams)'

####

SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
FROM tutorial.crunchbase_companies companies
LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
  ON companies.permalink=acquisitions.company_permalink
  
  ####
  
  SELECT companies.state_code,COUNT(DISTINCT companies.name) AS company_unique,
      COUNT(DISTINCT acquisitions.company_name) AS acquisition_unique
FROM tutorial.crunchbase_companies companies
LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
ON companies.state_code=acquisitions.company_state_code
WHERE companies.state_code IS NOT NULL
GROUP BY companies.state_code
ORDER BY acquisition_unique DESC

####

SELECT companies.state_code,COUNT(DISTINCT companies.name) AS company_unique,
      COUNT(DISTINCT acquisitions.company_name) AS acquisition_unique
FROM tutorial.crunchbase_companies companies
INNER JOIN tutorial.crunchbase_acquisitions acquisitions
ON companies.state_code=acquisitions.company_state_code
WHERE companies.state_code IS NOT NULL
GROUP BY companies.state_code
ORDER BY acquisition_unique DESC

###

SELECT companies.state_code,COUNT(DISTINCT companies.name) AS company_unique,
      COUNT(DISTINCT acquisitions.company_name) AS acquisition_unique
FROM tutorial.crunchbase_companies companies
RIGHT JOIN tutorial.crunchbase_acquisitions acquisitions
ON companies.state_code=acquisitions.company_state_code
WHERE companies.state_code IS NOT NULL
GROUP BY companies.state_code
ORDER BY acquisition_unique DESC

#####



SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
FROM tutorial.crunchbase_companies companies
LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
ON companies.permalink=acquisitions.company_permalink
AND acquisitions.company_permalink!='/company/1000memories'
ORDER BY 1

#####

SELECT companies.permalink AS companies_permalink,
       companies.name AS companies_name,
       acquisitions.company_permalink AS acquisitions_permalink,
       acquisitions.acquired_at AS acquired_date
FROM tutorial.crunchbase_companies companies
LEFT JOIN tutorial.crunchbase_acquisitions acquisitions
ON     companies.permalink=acquisitions.company_permalink
WHERE acquisitions.company_permalink != '/company/1000memories'
OR     acquisitions.company_permalink IS NULL
ORDER BY 1

####



SELECT COUNT(CASE WHEN ( acqusitions.acquired_at_cleaned::timestamp-companies.founded_at_clean::timestamp) < INTERVAL '3 years'   
                   THEN '3' ELSE NULL END) AS with3_years,
        COUNT(CASE WHEN ( acqusitions.acquired_at_cleaned::timestamp-companies.founded_at_clean::timestamp) > INTERVAL '3 years' AND
                  ( acqusitions.acquired_at_cleaned::timestamp-companies.founded_at_clean::timestamp)  < INTERVAL '5 years'  THEN '5' ELSE NULL END) AS within5_years,
        COUNT(CASE WHEN ( acqusitions.acquired_at_cleaned::timestamp-companies.founded_at_clean::timestamp) > INTERVAL '5 years' AND
                  ( acqusitions.acquired_at_cleaned::timestamp-companies.founded_at_clean::timestamp )  < INTERVAL '10 years'  THEN '10' ELSE NULL END) AS within10_years,
        COUNT(CASE WHEN acqusitions.company_permalink IS NOT NULL THEN '1' END) AS total
FROM tutorial.crunchbase_acquisitions_clean_date acqusitions
JOIN tutorial.crunchbase_companies_clean_date companies
ON companies.permalink=acqusitions.company_permalink 
WHERE  companies.founded_at IS NOT NULL 

#####

SELECT incidnt_num,
        date,
        LEFT(date,10) AS clean_date,
        RIGHT(date,17) AS cleaned_time,
        LENGTH(date) AS lenght_date,
        SUBSTR(date,4,2),
        date::timestamp AS reformatted_date,
        location,
        TRIM(both '()' FROM location),
        descript,
        POSITION('A' IN descript) AS a_position,
        STRPOS(descript,'B') AS b_position

FROM tutorial.sf_crime_incidents_2014_01

####


SELECT sf.incidnt_num,
      sf.day_of_week,
      CONCAT(sf.day_of_week,', ', LEFT(date,10)) AS day_and_date,
      CONCAT(sf.lat,',',sf.lon) AS new_location,
      sf.lat ||','|| sf.lon AS new1_location

FROM tutorial.sf_crime_incidents_2014_01 sf

####

SELECT cleaned_date,
       EXTRACT ('year' FROM sf.cleaned_date) AS year,
       EXTRACT ('month' FROM sf.cleaned_date) AS month,
       EXTRACT ('day' FROM sf.cleaned_date)  AS day,
       EXTRACT ('hour' FROM sf.cleaned_date)  AS hour,
       EXTRACT ('dow' FROM sf.cleaned_date)  AS day_of_week,
      DATE_TRUNC('year'   , cleaned_date) AS year_round,
       DATE_TRUNC('month'  , cleaned_date) AS month_round,
       DATE_TRUNC('week'   , cleaned_date) AS week_round,
       DATE_TRUNC('day'    , cleaned_date) AS day_round,
       DATE_TRUNC('hour'   , cleaned_date) AS hour_round

FROM tutorial.sf_crime_incidents_cleandate sf

#####

SELECT sf.incidnt_num,
      CONCAT(CURRENT_DATE,' ', CURRENT_TIME AT TIME ZONE 'UTC-8')::timestamp-sf.cleaned_date::timestamp AS time_ago,
      sf.descript,
      COALESCE(sf.descript,'No description')

FROM tutorial.sf_crime_incidents_cleandate sf
ORDER BY sf.descript DESC

####

SELECT sf_sub.*
FROM 
(
SELECT *
    FROM tutorial.sf_crime_incidents_2014_01 sf
    WHERE sf.descript='WARRANT ARREST'
    ) sf_sub
WHERE sf_sub.resolution='NONE'

####

SELECT LEFT(sf_sub.date,2) AS month,
            sf_sub.day_of_week,
            AVG (sf_sub.number_of_incident)
FROM 
(
SELECT sf.day_of_week,
       sf.date,
       COUNT(sf.incidnt_num) AS number_of_incident
FROM tutorial.sf_crime_incidents_2014_01 sf
GROUP BY 1,2
) sf_sub

GROUP BY 1,2
   
