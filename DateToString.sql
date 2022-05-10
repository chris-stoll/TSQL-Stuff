--======================================================================
-- Author: Chris Stoll
-- Date: 5/10/2022
--======================================================================

CREATE FUNCTION DataQ.StringFromDate(@InputDate DATE)
RETURNS VARCHAR(8)
AS
BEGIN
	DECLARE @Return_date VARCHAR(8) = ''

	SELECT @Return_date += CAST(DATEPART(YEAR, @InputDate) AS VARCHAR(4));
	SELECT @Return_date += RIGHT('0' + CAST(DATEPART(MONTH, @InputDate) AS VARCHAR(2)), 2);
	SELECT @Return_date += RIGHT('0' + CAST(DATEPART(DAY, @InputDate) AS VARCHAR(2)), 2);

	SELECT @Return_date = NULLIF(@Return_date, '');

	RETURN @Return_date

END
GO