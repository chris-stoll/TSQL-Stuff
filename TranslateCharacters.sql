--======================================================================
-- Author: Chris Stoll
-- Date: 6/17/2021
-- Description: Mimics TRANSLATE function built into sql 2017+
-- Note: @Characters and @Translations must have same number of characters
--======================================================================
CREATE OR ALTER FUNCTION dbo.TranslateCharacters
(
	 @Input NVARCHAR(MAX)
	,@Characters NVARCHAR(MAX)
	,@Translations NVARCHAR(MAX)
)
/*
--Testing


SELECT dbo.TranslateCharacters('123456[7890', '[',' ');
SELECT dbo.TranslateCharacters('1234*56[7890', '[*','||');

*/
RETURNS NVARCHAR(MAX)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
    
	IF DATALENGTH(@Characters) <> DATALENGTH(@Translations)
		RETURN CAST('@character @Translation length mismatch' AS INT);

	DECLARE @pos INT = 1;

	WHILE @pos <= LEN(@Characters)
		SELECT @Input = REPLACE(@Input, SUBSTRING(@Characters, @pos, 1), SUBSTRING(@Translations, @pos, 1)), @pos +=1;

	RETURN TRIM(@Input);
END;
GO

