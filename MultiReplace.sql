CREATE OR ALTER FUNCTION dbo.MutliReplace
(
    @InputString NVARCHAR(MAX)
    ,@TargetString NVARCHAR(MAX) 
    ,@ReplacementChar NCHAR(1) 
)
RETURNS NVARCHAR(MAX)
/*

SELECT dbo.MutliReplace('TEST!@#$%^&*()TEST', '!@#$%^&*()', ' ')

*/
AS
BEGIN
RETURN
	REPLACE(TRANSLATE(@InputString, @TargetString, REPLICATE(CHAR(26), LEN(@TargetString))), CHAR(26), @ReplacementChar)

END
GO