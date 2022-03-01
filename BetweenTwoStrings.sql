--======================================================================
-- Author: Chris Stoll
-- Date: 3/1/2022
-- Description: Returns a string between two strings in a string
--======================================================================
CREATE OR ALTER FUNCTION General.BetweenTwoStrings
(
	 @InputString NVARCHAR(MAX)
	,@StartString VARCHAR(MAX)
	,@EndString NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
WITH RETURNS NULL ON NULL INPUT
AS
/*

--Testing

DECLARE @Text NVARCHAR(MAX) = '
Phone System Template:

Callback Number: 999-867-5309
Caller''s Name: Jane Doe
Location Name:
City: State:
Brief Description:
'
DECLARE @Start NVARCHAR(100) = 'Callback Number:';
DECLARE @End NVARCHAR(100) = 'Caller''s Name:';


SELECT General.BetweenTwoStrings(@Text, @Start, @End);

*/
BEGIN
	DECLARE @OutputString NVARCHAR(MAX);

	IF CHARINDEX(@StartString, @InputString) > 0 --Start Exists
		AND CHARINDEX(@EndString, @InputString) > 0 --End Exists
		AND CHARINDEX(@StartString, @InputString) < CHARINDEX(@EndString, @InputString) --First start is before first end (Throws error if start is after end)
	BEGIN
		SET @OutputString = TRIM(SUBSTRING(@InputString, CHARINDEX(@StartString, @InputString) + LEN(@StartString), CHARINDEX(@EndString,@InputString) - CHARINDEX(@StartString, @InputString) - LEN(@StartString)));
	END

    RETURN @OutputString;
END
GO