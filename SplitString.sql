--Not mine, just wanted to keep it in my back pocket. 
--Taken from: https://sqlperformance.com/2016/03/t-sql-queries/string-split
CREATE OR ALTER FUNCTION dbo.SplitStrings
(
   @List       nvarchar(8000),
   @Delimiter  char(1)
)
RETURNS TABLE WITH SCHEMABINDING
AS
   RETURN (SELECT [value] = y.i.value(N'(./text())[1]', 'varchar(8000)')
      FROM (SELECT x = CONVERT(XML, N'<i>' 
          + REPLACE(@List, @Delimiter, N'</i><i>') 
          + N'</i>').query('.')
      ) AS a CROSS APPLY x.nodes(N'i') AS y(i));
GO
