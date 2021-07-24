SELECT n,CASE  WHEN p is NULL THEN 'Root'
                WHEN n IN (SELECT p FROM BST) THEN 'Inner'
            ELSE  'Leaf' END     
FROM BST
ORDER BY n
