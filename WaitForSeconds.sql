CREATE OR ALTER PROCEDURE dbo.WaitForSeconds
	@Duration SMALLINT = 10
AS
/*

--Hard 10 seconds
EXEC dbo.WaitForSeconds @Duration = 10;

--Random between 0 and 10 seconds
EXEC dbo.WaitForSeconds @Duration = -10;

*/
BEGIN
	IF @Duration < 0
	BEGIN
		SELECT @Duration = ABS(@Duration);
		SELECT @Duration = ABS(CHECKSUM(NEWID())) % @Duration;
	END

	--PRINT CAST(@Duration as varchar(50));
	DECLARE @WaitUntilTime DATETIME;
	SELECT @WaitUntilTime = DATEADD(SECOND, @Duration, GETDATE())
	--PRINT CAST(@WaitUntilTime as varchar(50));
	WAITFOR TIME @WaitUntilTime	
END
GO