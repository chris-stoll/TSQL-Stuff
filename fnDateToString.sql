--======================================================================
-- Author: Chris Stoll
-- Date: 6/22/2022
-- Description: Returns a bigint from a datetime
-- Testing:
		/*

			select dbo.fnDateToString(NULL)
			GO
			declare @dt datetime2(3) = sysdatetime();
			select @dt, dbo.fnDateToString(@dt)
			GO
			declare @dt datetime = getdate();
			select @dt, dbo.fnDateToString(@dt)
			GO
			declare @dt date = getdate();
			select @dt, dbo.fnDateToString(@dt)

		*/
-- Changes:
--		06/22/22 - CIS - Created
--======================================================================
CREATE OR ALTER FUNCTION dbo.fnDateToString
    (@dt DATETIME2(3) = NULL)
RETURNS BIGINT
AS
BEGIN
	RETURN 
		CAST(CONCAT(CAST(DATEPART(YEAR, @dt) AS VARCHAR(4))
		,RIGHT(REPLICATE('0', 2) + CAST(DATEPART(MONTH, @dt) AS VARCHAR(2)), 2)
		,RIGHT(REPLICATE('0', 2) + CAST(DATEPART(DAY, @dt) AS VARCHAR(2)), 2)
		,RIGHT(REPLICATE('0', 2) + CAST(DATEPART(HOUR, @dt) AS VARCHAR(2)), 2)
		,RIGHT(REPLICATE('0', 2) + CAST(DATEPART(MINUTE, @dt) AS VARCHAR(2)), 2)
		,RIGHT(REPLICATE('0', 2) + CAST(DATEPART(SECOND, @dt) AS VARCHAR(2)), 2)
		,RIGHT(REPLICATE('0', 3) + CAST(DATEPART(MILLISECOND, @dt) AS VARCHAR(3)), 3)) AS BIGINT);
END;
GO