SELECT id, age, coins_needed, power FROM (SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=1) table_1
UNION ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=2) table_2
UNION ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=3) table_3
UNION  ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=4) table_4
UNION ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=5) table_5
UNION ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=6) table_6
UNION ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=7) table_7
UNION ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=8) table_8
UNION ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=9) table_9
UNION ALL
SELECT * FROM (SELECT id,code, coins_needed,power, RANK() OVER  (Partition BY code ORDER BY coins_needed) as new_rank  From wands WHERE power=10) table_10) all_tables
JOIN wands_property ON all_tables.code=wands_property.code
WHERE all_tables.new_rank=1 and is_evil=0
ORDER BY power DESC, age DESC

