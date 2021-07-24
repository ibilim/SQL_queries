SELECT sub.hacker_id,sub.name FROM (SELECT submissions.hacker_id, hackers.name,COUNT(submissions.challenge_id) as sub_chal FROM submissions
JOIN  Challenges ON  submissions.challenge_id=challenges.challenge_id
JOIN hackers ON hackers.hacker_id=submissions.hacker_id
WHERE (score=20 and difficulty_level=1) OR
      (score=30 and difficulty_level=2) OR
      (score=40 and difficulty_level=3) OR
      (score=60 and difficulty_level=4) OR
      (score=80 and difficulty_level=5) OR
      (score=100 and difficulty_level=6) OR
      (score=120 and difficulty_level=7) 
GROUP BY 1,2
ORDER BY sub_chal DESC, 1 ASC) sub
WHERE sub.sub_chal>1
