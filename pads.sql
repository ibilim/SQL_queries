SELECT * FROM (SELECT concat(name,'(',LEFT(occupation,1),')') FROM occupations
) table_1
UNION 
SELECT * FROM ( SELECT CONCAT('There are a total of ',COUNT(1),' ',lower(occupation),'s.') FROM occupations 
GROUP BY occupation
 ) table_2
ORDER BY 1
