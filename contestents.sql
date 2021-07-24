SELECT * FROM (SELECT  hacker_id, name, sum(new_score) as sum_total FROM ( SELECT DISTINCT sub.hacker_id, name, challenge_id, sub.new_score FROM (  SELECT hacker_id, challenge_id,score, MAX(score) over (partition by challenge_id, hacker_id) as new_score From submissions 
) sub 
JOIN hackers ON hackers.hacker_id=sub.hacker_id) sub_2
GROUP BY hacker_id, name ) sub_3
WHERE sum_total>0
ORDER BY sum_total DESC, hacker_id asc  ;
