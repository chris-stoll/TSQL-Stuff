/*
My daughter's 1st grade class was working on addition where the sums 
added to a maximum of 10. This query gives a the combination of all 
equations where the sum of the two numbers equals 10
*/
DECLARE @num TABLE(n tinyint);


INSERT INTO @num(n)
VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);


SELECT n1.n, n2.n, n2.n + n1.n
FROM @num n1
CROSS JOIN @num n2
WHERE n1.n + n2.n <= 10
	AND n1.n <= n2.n
ORDER BY n1.n + n2.n, n1.n, n2.n;

