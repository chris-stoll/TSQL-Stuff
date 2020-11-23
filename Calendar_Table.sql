CREATE OR ALTER PROCEDURE General.Calendar_Populate
AS
BEGIN

	SET NOCOUNT ON;
	/*
	DROP TABLE IF EXISTS General.Calendar;

	CREATE TABLE General.Calendar
	(
		Calendar_Date DATE NOT NULL
			CONSTRAINT PK_General_Calendar PRIMARY KEY CLUSTERED(Calendar_Date)
		,YYYYMMDD INT NOT NULL
		,Calendar_Year SMALLINT NOT NULL
		,Calendar_Quarter TINYINT NOT NULL
		,Calendar_Month TINYINT NOT NULL
		,Calendar_DayOfYear SMALLINT NOT NULL
		,Calendar_WeekOfYear TINYINT NOT NULL
		,Calendar_DayOfMonth TINYINT NOT NULL
		,Calendar_DayOfWeek TINYINT NOT NULL
		,Month_Name VARCHAR(10) NOT NULL
		,DayOfWeek_Name VARCHAR(10) NOT NULL
		,Is_Leap_Year BIT NOT NULL
		,Is_Weekday BIT NOT NULL
		,Days_In_Month TINYINT NOT NULL
		,First_Day_Of_Month DATE NOT NULL
		,Last_Day_Of_Month DATE NOT NULL
		,Date_Style107 VARCHAR(25) NOT NULL
	)

	ALTER TABLE General.Calendar
	ADD CONSTRAINT CHK_General_Calendar
		CHECK 
			(
					(Calendar_Date BETWEEN '1/1/1900' AND '12/31/9999')
				AND (Calendar_Year BETWEEN 1900 AND 9999)
				AND (Calendar_Quarter BETWEEN 1 AND 4)
				AND (Calendar_Month BETWEEN 1 AND 12)
				AND (Calendar_DayOfYear BETWEEN 1 AND 366)
				AND (Calendar_WeekOfYear BETWEEN 1 AND 54)
				AND (Calendar_DayOfMonth BETWEEN 1 AND 31)
				AND (Calendar_DayOfWeek BETWEEN 1 AND 7)
				AND (Days_In_Month BETWEEN 28 AND 31)
			)

	EXEC General.Calendar_Populate

	SELECT *
	FROM General.Calendar c
	WHERE c.Calendar_Date BETWEEN DATEADD(DAY, -30, GETDATE()) AND DATEADD(DAY, 60, GETDATE())

	*/

	SET DATEFIRST 7, DATEFORMAT MDY, LANGUAGE US_ENGLISH;

	DECLARE @StartDate DATE = DATEADD(YEAR, -50, GETDATE());
	DECLARE @EndDate DATE = DATEADD(YEAR, 200, GETDATE());

	DECLARE @YYYYMMDD INT;

	DECLARE @Calendar_Year SMALLINT;
	DECLARE @Calendar_Quarter TINYINT;
	DECLARE @Calendar_Month TINYINT;
	DECLARE @Calendar_WeekOfYear TINYINT;

	DECLARE @Calendar_DayOfMonth TINYINT;
	DECLARE @Calendar_DayOfWeek TINYINT;
	DECLARE @Calendar_DayOfYear SMALLINT;

	DECLARE @Month_Name VARCHAR(10);
	DECLARE @DayOfWeek_Name VARCHAR(10);

	DECLARE @Is_Leap_Year BIT;

	DECLARE @Is_Weekday BIT;

	DECLARE @Days_in_Month TINYINT;

	DECLARE @First_Day_Of_Month DATE;
	DECLARE @Last_Day_Of_Month DATE;

	DECLARE @Date_Style107 VARCHAR(25);


	--Loop
	DECLARE @CurrentDate DATE = @StartDate;

	DECLARE @StopWatch DATETIME2 = SYSDATETIME();
	BEGIN TRAN;
		DELETE FROM General.Calendar WITH(TABLOCKX) WHERE Calendar_Date BETWEEN @StartDate AND @EndDate;

		WHILE @CurrentDate <= @EndDate
		BEGIN
			--PRINT @CurrentDate; 

			SELECT @Calendar_Year = DATEPART(YEAR, @CurrentDate);

			SELECT @Calendar_Quarter = DATEPART(QUARTER, @CurrentDate);

			SELECT @Calendar_Month = DATEPART(MONTH, @CurrentDate);

			SELECT @Calendar_WeekOfYear = DATEPART(WEEK, @CurrentDate);

			SELECT @Calendar_DayOfYear = DATEPART(DAYOFYEAR, @CurrentDate);

			SELECT @Calendar_DayOfMonth = DATEPART(DAY, @CurrentDate);

			SELECT @Calendar_DayOfWeek = DATEPART(WEEKDAY, @CurrentDate);

			SELECT @YYYYMMDD = CAST(CONVERT(VARCHAR(10), @CurrentDate, 112) AS INT);

			SELECT @Month_Name = DATENAME(MONTH, @CurrentDate);

			SELECT @DayOfWeek_Name = DATENAME(WEEKDAY, @CurrentDate);

			SELECT @Is_Weekday = 
				CASE WHEN (((@Calendar_DayOfWeek - 1 ) + @@DATEFIRST ) % 7) BETWEEN 1 AND 5 THEN 1 ELSE 0 END;


			SELECT @Is_Leap_Year = 
				CASE
					WHEN @Calendar_Year % 4 <> 0 THEN 0
					WHEN @Calendar_Year % 100 <> 0 THEN 1
					WHEN @Calendar_Year % 400 <> 0 THEN 0
					ELSE 1
				END;

			SELECT @Days_in_Month = 
				CASE
					WHEN @Calendar_Month IN (4, 6, 9, 11) THEN 30				
                    WHEN @Calendar_Month IN (1, 3, 5, 7, 8, 10, 12) THEN 31
					WHEN @Calendar_Month = 2 AND @Is_Leap_Year = 1 THEN 29
					ELSE 28
				END;

			SELECT @First_Day_Of_Month = DATEFROMPARTS(@Calendar_Year, @Calendar_Month, 1);

			SELECT @Last_Day_Of_Month = EOMONTH(@CurrentDate);

			SELECT @Date_Style107 = CONVERT(VARCHAR(25), @CurrentDate, 107);

			INSERT INTO General.Calendar
			(
				Calendar_Date,
				YYYYMMDD,
				Calendar_Year,
				Calendar_Month,
				Calendar_WeekOfYear,
				Calendar_DayOfMonth,
				Calendar_DayOfWeek,
				Month_Name,
				DayOfWeek_Name,
				Is_Leap_Year,
				Is_Weekday,
				Days_In_Month,
				Calendar_Quarter,
				Calendar_DayOfYear,
				First_Day_Of_Month,
				Last_Day_Of_Month,
				Date_Style107
			)
			VALUES
			(
				@CurrentDate, -- Calendar_Date - date
				@YYYYMMDD,		--YYYYMMDD - int
				@Calendar_Year,         -- Calendar_Year - smallint
				@Calendar_Month,         -- Calendar_Month - tinyint
				@Calendar_WeekOfYear,         -- Calendar_WeekOfYear - tinyint
				@Calendar_DayOfMonth,         -- Calendar_DayOfMonth - tinyint
				@Calendar_DayOfWeek,         -- Calendar_DayOfWeek - tinyint
				@Month_Name,        -- Month_Name - varchar(10)
				@DayOfWeek_Name,        -- DayOfWeek_Name - varchar(10)
				@Is_Leap_Year,      -- Is_Leap_Year - bit
				@Is_Weekday,       -- Is_Weekday - bit
				@Days_in_Month,		--Days_In_Month - tinyint
				@Calendar_Quarter,		--Calendar_Quarter - tinyint
				@Calendar_DayOfYear,			--Calendar_DayOfYear - smallint
				@First_Day_Of_Month,		--First_Day_Of_Month - date
				@Last_Day_Of_Month,		--Last_Day_Of_Month - date
				@Date_Style107		--Date_Style107 - varchar(25)
			)
	
			SELECT @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
		END
	COMMIT TRAN;
	PRINT 'Elapsed Time to populate: ' + CAST(DATEDIFF(MILLISECOND, @StopWatch, SYSDATETIME()) AS VARCHAR(100)) + 'ms';
END
GO