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

