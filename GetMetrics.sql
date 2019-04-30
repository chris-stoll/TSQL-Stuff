CREATE OR ALTER PROCEDURE [Maintenance].[GetMetrics]
	@SampleDuration INT = 10
AS
BEGIN
/*

EXEC Maintenance.GetMetrics;

EXEC Maintenance.GetMetrics 30;

*/
	SET NOCOUNT ON;
	IF @SampleDuration IS NULL OR @SampleDuration < 5
		SET @SampleDuration = 10;
	ELSE IF @SampleDuration > 59
		SET @SampleDuration = 59;

	-- Variables for Counters
	DECLARE @BatchRequestsPerSecond BIGINT;
	DECLARE @CompilationsPerSecond BIGINT;
	DECLARE @ReCompilationsPerSecond BIGINT;
	DECLARE @LockWaitsPerSecond BIGINT;
	DECLARE @PageSplitsPerSecond BIGINT;
	DECLARE @CheckpointPagesPerSecond BIGINT;
	DECLARE @PageReadsPerSecond BIGINT;
	DECLARE @PageWritesPerSecond BIGINT;
	DECLARE @ActiveTempTables BIGINT;
	DECLARE @TempTableCreationRatePerSecond BIGINT;
	DECLARE @TempTablesForDestruction BIGINT;

	-- Variable for date
	DECLARE @stat_date DATETIME;

	 -- Table for First Sample
	DECLARE @RatioStatsX TABLE(object_name VARCHAR(128),counter_name VARCHAR(128),instance_name VARCHAR(128),cntr_value BIGINT);

	-- Table for Second Sample
	DECLARE @RatioStatsY TABLE(object_name VARCHAR(128),counter_name VARCHAR(128),instance_name VARCHAR(128),cntr_value BIGINT);

	-- Capture stat time
	SET @stat_date = GETDATE();

 	INSERT INTO @RatioStatsX (object_name,counter_name,instance_name,cntr_value)
	SELECT object_name,counter_name,instance_name,cntr_value FROM sys.dm_os_performance_counters;

	EXEC Maintenance.WaitForSeconds @SampleDuration;

	-- Table for second sample
	INSERT INTO @RatioStatsY (object_name,counter_name,instance_name,cntr_value)
	SELECT object_name,counter_name,instance_name,cntr_value FROM sys.dm_os_performance_counters;

	-- Capture each per second counter for first sampling
	SELECT TOP 1 @BatchRequestsPerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'Batch Requests/sec' AND object_name LIKE '%SQL Statistics%';
	SELECT TOP 1 @CompilationsPerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'SQL Compilations/sec' AND object_name LIKE '%SQL Statistics%';
	SELECT TOP 1 @ReCompilationsPerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'SQL Re-Compilations/sec' AND object_name LIKE '%SQL Statistics%';
	SELECT TOP 1 @LockWaitsPerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'Lock Waits/sec' AND instance_name = '_Total' AND object_name LIKE '%Locks%';
	SELECT TOP 1 @PageSplitsPerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'Page Splits/sec' AND object_name LIKE '%Access Methods%'; 
	SELECT TOP 1 @CheckpointPagesPerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'Checkpoint Pages/sec' AND object_name LIKE '%Buffer Manager%';                                         
	SELECT TOP 1 @PageReadsPerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'Page reads/sec' AND object_name LIKE '%Buffer Manager%';
	SELECT TOP 1 @PageWritesPerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'Page writes/sec' AND object_name LIKE '%Buffer Manager%';                                         
	SELECT TOP 1 @TempTableCreationRatePerSecond = cntr_value FROM @RatioStatsX WHERE counter_name = 'Temp Tables Creation Rate' AND object_name LIKE '%General Statistics%';                                         

	--Get Values from last sample
	SELECT TOP 1 @TempTablesForDestruction = cntr_value FROM @RatioStatsY WHERE counter_name = 'Temp Tables For Destruction' AND object_name LIKE '%General Statistics%';                                         
	SELECT TOP 1 @TempTableCreationRatePerSecond = cntr_value FROM @RatioStatsY WHERE counter_name = 'Temp Tables Creation Rate' AND object_name LIKE '%General Statistics%';                                         
	
	DECLARE @Now DATETIME = GETDATE();

	SELECT 
		 'StatDate' = @Now   
		,'Duration(sec)' = (CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END)
		,'BufferCacheHitRatio' = (a.BufferCacheHitRatio * 1.0 / b.BufferCacheHitRatioBase) * 100.0
		,c.PageLifeExpectency
		,d.BatchRequestsPerSecond
		,e.CompilationsPerSecond
		,f.ReCompilationsPerSecond
		,g.UserConnections
		,h.LockWaitsPerSecond 
		,i.PageSplitsPerSecond
		,j.ProcessesBlocked
		,k.CheckpointPagesPerSecond            
		,l.PageReadsPerSecond
		,m.PageWritesPerSecond
		,'ActiveTempTables' = @ActiveTempTables
		,'TempTableCreationRatePerSecond' = n.TempTableCreationRatePerSecond
		,'TempTablesForDestruction' = @TempTablesForDestruction
	FROM (SELECT 'BufferCacheHitRatio' = cntr_value FROM @RatioStatsY WHERE counter_name = 'Buffer cache hit ratio' AND object_name LIKE '%Buffer Manager%') a
	CROSS JOIN (SELECT 'BufferCacheHitRatioBase' = cntr_value FROM @RatioStatsY WHERE counter_name = 'Buffer cache hit ratio base' AND object_name LIKE '%Buffer Manager%') b
	CROSS JOIN (SELECT 'PageLifeExpectency' = cntr_value FROM @RatioStatsY WHERE counter_name = 'Page life expectancy ' AND object_name LIKE '%Buffer Manager%') c
	CROSS JOIN (SELECT 'BatchRequestsPerSecond' = (cntr_value - @BatchRequestsPerSecond) /(CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'Batch Requests/sec'AND object_name LIKE '%SQL Statistics%') d   
	CROSS JOIN (SELECT 'CompilationsPerSecond' = (cntr_value - @CompilationsPerSecond) /(CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'SQL Compilations/sec' AND object_name LIKE '%SQL Statistics%') e 
	CROSS JOIN (SELECT 'ReCompilationsPerSecond' = (cntr_value - @ReCompilationsPerSecond) / (CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'SQL Re-Compilations/sec' AND object_name LIKE '%SQL Statistics%') f
	CROSS JOIN (SELECT 'UserConnections' = cntr_value FROM @RatioStatsY WHERE counter_name = 'User Connections' AND object_name LIKE '%General Statistics%') g
	CROSS JOIN (SELECT 'LockWaitsPerSecond' = (cntr_value - @LockWaitsPerSecond) / (CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'Lock Waits/sec' AND instance_name = '_Total' AND object_name LIKE '%Locks%') h
	CROSS JOIN (SELECT 'PageSplitsPerSecond' = (cntr_value - @PageSplitsPerSecond) / (CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'Page Splits/sec' AND object_name LIKE '%Access Methods%') i
	CROSS JOIN (SELECT 'ProcessesBlocked' = cntr_value FROM @RatioStatsY WHERE counter_name = 'Processes blocked' AND object_name LIKE '%General Statistics%') j
	CROSS JOIN (SELECT 'CheckpointPagesPerSecond' = (cntr_value - @CheckpointPagesPerSecond) / (CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'Checkpoint Pages/sec' AND object_name LIKE '%Buffer Manager%') k
	CROSS JOIN (SELECT 'PageReadsPerSecond' = (cntr_value - @PageReadsPerSecond) / (CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'Page reads/sec' AND object_name LIKE '%Buffer Manager%') l
	CROSS JOIN (SELECT 'PageWritesPerSecond' = (cntr_value - @PageWritesPerSecond) / (CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'Page writes/sec' AND object_name LIKE '%Buffer Manager%') m
	CROSS JOIN (SELECT 'TempTableCreationRatePerSecond' = (cntr_value - @TempTableCreationRatePerSecond) / (CASE WHEN DATEDIFF(SECOND,@stat_date, @Now) = 0 THEN  1 ELSE DATEDIFF(SECOND,@stat_date, @Now) END) FROM @RatioStatsY WHERE counter_name = 'Temp Tables Creation Rate' AND object_name LIKE '%General Statistics%') n
END
