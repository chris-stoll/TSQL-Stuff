/*
My daughter's 1st grade class was working on addition where the sums 
added to a maximum of 10. This query gives a the combination of all 
equations where the sum of the two numbers equals @MaximumSum

It does not duplicate sums (ie. 1+2 and 2+1 )
*/
DECLARE @num TABLE(n tinyint);

DECLARE @MaximumSum INT = 15

INSERT INTO @num(n)
SELECT TOP(@MaximumSum) 
	ROW_NUMBER() OVER(ORDER BY name)
FROM sys.objects
UNION 
SELECT 0

SELECT 
	 [n1] = n1.n
	,[n2] = n2.n
	,[Sum] = n2.n + n1.n
	,[Equation] = CAST(n2.n as VARCHAR(100)) + ' + ' + CAST(n1.n as VARCHAR(100)) + ' = ' + CAST(n2.n + n1.n AS VARCHAR(100))
FROM @num n1
CROSS JOIN @num n2
WHERE n1.n + n2.n <= @MaximumSum
	AND n1.n <= n2.n
ORDER BY n1.n + n2.n, n1.n, n2.n;