;WITH
	num (n)
	AS
	(
		SELECT 1
		UNION ALL
		SELECT n+1
		FROM num
		WHERE n < 100
	)
SELECT 'n' = ISNULL(NULLIF(IIF(n%3=0,'Fizz', '') + IIF(n%5=0,'Buzz',''),''),n)
FROM num;