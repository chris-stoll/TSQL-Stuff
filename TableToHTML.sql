CREATE OR ALTER PROCEDURE General.TableToHTML
 @TableName VARCHAR(500)
,@Body VARCHAR(MAX) OUTPUT
AS
/*

DECLARE @BodyOut varchar(max);
EXEC General.TableToHTML @TableName =
	 'Location.LocationType'
	,@body = @bodyOut output;

SELECT @BodyOut	;

*/
BEGIN
	SET NOCOUNT ON;
	IF OBJECT_ID('tempdb..#Columns') IS NOT NULL
		DROP TABLE #Columns;
	
	DECLARE @columnQuery VARCHAR(MAX) = 'select name, Column_id from {db}sys.columns where object_id =object_id(''{table}'')';
	IF PATINDEX('%#%', @TableName) > 0
	BEGIN
		SELECT @columnQuery	= REPLACE(@columnQuery, '{table}', 'tempdb..' + @TableName);
		SELECT @columnQuery	= REPLACE(@columnQuery, '{db}', 'tempdb.');
	END;
	ELSE
	BEGIN 
		SELECT @columnQuery	= REPLACE(@columnQuery, '{table}', @TableName);	
		SELECT @columnQuery	= REPLACE(@columnQuery, '{db}', '');	
	END;

	CREATE TABLE #Columns (ColumnName VARCHAR(128), ColumnOrder INT NOT NULL PRIMARY KEY);
	--PRINT @columnQuery
	
	INSERT INTO #Columns (ColumnName, ColumnOrder)
	EXEC(@columnQuery);

	DECLARE @OrderedByExternalOrderID BIT = 0
	IF EXISTS(SELECT c.ColumnName FROM #Columns c WHERE c.ColumnName = 'ExternalOrderID')
		SET @OrderedByExternalOrderID = 1;

	DECLARE @HeaderList VARCHAR(MAX);

	SELECT @HeaderList= STUFF((
								SELECT '<th>' + ColumnName + '</th>'
								FROM #Columns
								WHERE ColumnName <> 'ExternalOrderID'
								ORDER BY ColumnOrder
								FOR XML PATH('')
								),1,1,'');

	SELECT @HeaderList = REPLACE(REPLACE( REPLACE( @HeaderList, '&lt;', '<' ), '&gt;', '>' ), 'lt;', '<');
	
	--PRINT 'Header: ' + @HeaderList;
	
	DECLARE @OuterList VARCHAR(MAX);

	SELECT @OuterList= STUFF((
						SELECT ' [' + ColumnName + '] + ''</td><td>'' + '
						FROM #Columns
						WHERE ColumnName <> 'ExternalOrderID'
						ORDER BY ColumnOrder
						FOR XML PATH('')
						),1,1,'');

	--PRINT @OuterList;
	SELECT @OuterList = REPLACE(REPLACE( REPLACE( @OuterList, '&lt;', '<' ), '&gt;', '>' ), 'lt;', '<');
	SELECT @OuterList = LEFT(@OuterList, LEN(@OuterList) - 16);

	--PRINT 'OuterList: ' + @OuterList;

	DECLARE @columnList VARCHAR(MAX);
	SELECT @columnList = STUFF((
								SELECT ',[' + ColumnName  +'] = ISNULL(CAST([' + ColumnName + '] AS VARCHAR(MAX)), '''')'
								FROM #Columns
								--WHERE ColumnName <> 'ExternalOrderID'
								ORDER BY ColumnOrder
								FOR XML PATH('')
								),1,1,'');

	--PRINT 'ColumnList: ' + @columnList;

	DROP TABLE #Columns;

	DECLARE @sqlCommand NVARCHAR(MAX)= '
set @body = cast( (

select td = {outerlist}

from (

      select {columnlist}

      from {tablename}

      ) as d
{ExternalOrdering}
for xml path( ''tr'' ), type ) as varchar(max) )

 

set @body = ''<table cellpadding="2" cellspacing="2" border="1">''

              + ''<tr>{headerlist}</tr>''

              + replace( replace( @body, ''&lt;'', ''<'' ), ''&gt;'', ''>'' )

              + ''</table>''
';


	SET @sqlCommand = REPLACE(@sqlCommand, '{headerlist}', @HeaderList);
	SET @sqlCommand = REPLACE(@sqlCommand, '{columnlist}', @columnList);
	SET @sqlCommand = REPLACE(@sqlCommand, '{outerlist}', @OuterList);
	SET @sqlCommand = REPLACE(@sqlCommand, '{tablename}', @TableName);
	
	IF @OrderedByExternalOrderID = 1
		SET @sqlCommand = REPLACE(@sqlCommand, '{ExternalOrdering}', 'ORDER BY CAST(ExternalOrderID AS INT)')
	ELSE 
		SET @sqlCommand = REPLACE(@sqlCommand, '{ExternalOrdering}', '');

	--PRINT @sqlcommand
	EXECUTE sp_executesql @sqlCommand, N'@body varchar(max) OUTPUT', @Body = @Body	OUTPUT;


	
END;







GO

