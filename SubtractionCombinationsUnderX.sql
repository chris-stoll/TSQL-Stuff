/*
My daughter's 1st grade class was working on subtraction.
This query gives a the combination of all 
equations where the n2 is below @MaximumSum.
*/
DECLARE @num TABLE(n tinyint);

DECLARE @MaximumSum INT = 15;

INSERT INTO @num(n)
SELECT TOP(@MaximumSum) 
	ROW_NUMBER() OVER(ORDER BY name)
FROM sys.objects
UNION 
SELECT 0;

SELECT 
	 [n2] = n2.n
	,[n1] = n1.n
	,[Sum] = n2.n + n1.n
	,[Equation] = CAST(n2.n + n1.n AS VARCHAR(100)) + ' - ' + CAST(n2.n as VARCHAR(100)) + ' = ' +  CAST(n1.n as VARCHAR(100))
FROM @num n1
CROSS JOIN @num n2
WHERE n1.n + n2.n <= 15
	AND n1.n <= n2.n
ORDER BY n1.n + n2.n, n2.n, n1.n;