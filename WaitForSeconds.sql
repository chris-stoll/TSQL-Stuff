CREATE OR ALTER PROCEDURE Maintenance.WaitForSeconds
	@Duration SMALLINT = 10
AS
/*

--Hard 10 seconds
EXEC Maintenance.WaitForSeconds @Duration = 10;

--Random between 0 and 10 seconds
EXEC Maintenance.WaitForSeconds @Duration = -10;

*/
BEGIN
	IF @Duration < 0
	BEGIN
		SELECT @Duration = ABS(@Duration);
		SELECT @Duration = ABS(CHECKSUM(NEWID())) % @Duration;
	END

	DECLARE @Hours SMALLINT = @Duration / 3600;
	SELECT @Duration = @Duration % 3600;
	DECLARE @Minutes TINYINT = @Duration / 60;
	SELECT @Duration = @Duration % 60;
	DECLARE @Seconds TINYINT = @Duration;
    
	DECLARE @WaitFor VARCHAR(50) = 'WAITFOR DELAY ''{H}:{M}:{S}'' ';

	SELECT @WaitFor = REPLACE(@WaitFor, '{H}', cast(ISNULL(@Hours, '00') AS VARCHAR(4)));
	SELECT @WaitFor = REPLACE(@WaitFor, '{M}', cast(ISNULL(@Minutes, '00') AS VARCHAR(2)));
	SELECT @WaitFor = REPLACE(@WaitFor, '{S}', cast(ISNULL(@Seconds, '00') AS VARCHAR(2)));
	
	EXEC(@WaitFor);
END
GO