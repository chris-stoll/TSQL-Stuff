CREATE OR ALTER FUNCTION dbo.RemoveTrailingCharacter(@input VARCHAR(MAX), @character CHAR(1))
RETURNS VARCHAR(MAX)
AS
BEGIN
	RETURN CASE
				WHEN RIGHT(RTRIM(@input),1) = @character 
				THEN SUBSTRING(RTRIM(@input),1,LEN(RTRIM(@input))-1)
				ELSE @input
		   END
END