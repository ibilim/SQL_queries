SELECT CASE WHEN marks>69 THEN name ELSE NULL END AS new_name,
           CASE WHEN marks between 0 and 9 THEN 1
                WHEN marks between 10 and 19 THEN 2
                WHEN marks between 20 and 29 THEN 3
                WHEN marks between 30 and 39 THEN 4
                WHEN marks between 40 and 49 THEN 5
                WHEN marks between 50 and 59 THEN 6
                WHEN marks BETWEEN 60 AND 69 THEN 7
                WHEN marks BETWEEN 70 AND 79 THEN 8
                WHEN marks BETWEEN 80 and 89 THEN 9
                WHEN marks between 90 and 100 THEN 10 END AS grade,
        Marks 
FROM Students
ORDER BY 2 DESC,name ASC,marks ASC
