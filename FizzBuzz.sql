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
SELECT 'n' = ISNULL(NULLIF(CASE WHEN n%3=0 THEN 'Fizz' ELSE '' END + CASE WHEN n%5=0 THEN 'Buzz' ELSE '' END,''),n)
FROM num;
