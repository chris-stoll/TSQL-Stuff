/*
	Author: Chris Stoll
	Date: 09/02/2020
	Description: Dyanmically generate a date table 
	Enhanced version based upon original function found here: https://protiguous.software/2020/09/02/sql-function-to-generate-date-table/
	
	-- * TESTING * --
	SELECT Date FROM [dbo].[GenerateDates]( 'second',1, '2020-01-01 10:00:00.000AM', '2020-01-01 10:01:00.000AM' );
	SELECT Date FROM [dbo].[GenerateDates]( 'second',5, '2020-01-01 10:00:00.000AM', '2020-01-01 10:01:00.000AM' );
	SELECT Date FROM [dbo].[GenerateDates]( 'minute',1, getdate()-1, getdate()+1 );
	SELECT Date FROM [dbo].[GenerateDates]( 'minute',15, getdate()-1, getdate()+1 );
	SELECT Date FROM [dbo].[GenerateDates]( 'minute',30, getdate()-1, getdate()+1 );
	SELECT Date FROM [dbo].[GenerateDates]( 'hour',1, getdate()-1, getdate()+1 );
	SELECT Date FROM [dbo].[GenerateDates]( 'hour',2, getdate()-1, getdate()+1 );
	SELECT Date FROM [dbo].[GenerateDates]( 'day',1, getdate()-10, getdate()+10 );
	SELECT Date FROM [dbo].[GenerateDates]( 'week',1, getdate()-21, getdate()+21 );
	SELECT Date FROM [dbo].[GenerateDates]( 'month',1, getdate()-365, getdate()+365 );
	SELECT Date FROM [dbo].[GenerateDates]( 'year',1, getdate()-500, getdate()+500 );

	--Error cases
	SELECT Date FROM [dbo].[GenerateDates]( 'BADINCREMENT',1, getdate()-500, getdate()+500 );
	
	SELECT Date FROM [dbo].[GenerateDates]( 'second',-1, getdate()-500, getdate()+500 );

	SELECT Date FROM [dbo].[GenerateDates]( 'minute',1, getdate(), getdate()-1 );
*/
CREATE OR ALTER FUNCTION dbo.GenerateDates(
    @Interval VARCHAR(10),
	@Increment INT,
    @Start DATETIME2(3),
    @End DATETIME2(3)
)
RETURNS @Range TABLE( [Date] DATETIME2(3) )
AS
BEGIN
    SET @Interval = LOWER( @Interval );
 
	IF @Interval NOT IN ('second', 'minute','hour', 'day', 'week', 'month', 'year')
		RETURN;

	IF @Increment <= 0
		RETURN;

	IF @Start > @End
		RETURN;

    ;WITH Dates( [Date] ) AS (
        SELECT @Start
        UNION ALL
        SELECT
            CASE @Interval
				WHEN 'second' THEN DATEADD(SECOND, @Increment, [Date])
				WHEN 'minute' THEN DATEADD(MINUTE, @Increment, [Date])
				WHEN 'hour' THEN DATEADD(HOUR, @Increment, [Date])
                WHEN 'day' THEN DATEADD(DAY, @Increment, [Date])
                WHEN 'week' THEN DATEADD(WEEK, @Increment, [Date])
                WHEN 'month' THEN DATEADD(MONTH, @Increment, [Date])
                WHEN 'year' THEN DATEADD(YEAR, @Increment, [Date])
            END
        FROM Dates
        WHERE [Date] <= 
            CASE @Interval
                WHEN 'second' THEN DATEADD(SECOND, -@Increment, @End)
                WHEN 'minute' THEN DATEADD(MINUTE, -@Increment, @End)
                WHEN 'hour' THEN DATEADD(HOUR, -@Increment, @End)
                WHEN 'day' THEN DATEADD(DAY, -@Increment, @End)
                WHEN 'week' THEN DATEADD(WEEK, -@Increment, @End)
                WHEN 'month' THEN DATEADD(MONTH, -@Increment, @End)
                WHEN 'year' THEN DATEADD(YEAR, -@Increment, @End)
            END
    )
    INSERT INTO @Range( [Date] )
    SELECT [Date]
    FROM Dates
    OPTION (MAXRECURSION 0);
 
    RETURN;
END;