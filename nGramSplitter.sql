CREATE OR ALTER FUNCTION dbo.SplitNGram(@string VARCHAR(MAX), @nGramSize INT)
RETURNS @output TABLE
(
OrderID SMALLINT NOT NULL PRIMARY KEY IDENTITY(1,1), ngram VARCHAR(MAX)

)
AS
/*
select OrderID, ngram
from dbo.SplitNGram('The quick brown fox jumps over the lazy dog .', 3);

select OrderID, ngram
from dbo.SplitNGram('The quick brown fox jumps over the lazy dog .', 2);

*/
BEGIN
	DECLARE @SplitString TABLE (OrderID SMALLINT NOT NULL PRIMARY KEY IDENTITY(1,1), Word VARCHAR(MAX));
	DECLARE @Delimiter CHAR(1) = ' ';
	DECLARE @outputstring VARCHAR(500);

	INSERT INTO @SplitString(Word)
	SELECT ss.value
	FROM STRING_SPLIT(@string, @Delimiter) ss;


	DECLARE @Pos INT = 1;
	WHILE @Pos + @ngramSize - 1 <= (SELECT COUNT(*) FROM @SplitString)
	BEGIN
		SELECT @outputstring = '';
		SELECT @outputstring += ss.Word + @Delimiter
		FROM @SplitString ss
		WHERE ss.OrderID BETWEEN @Pos AND @Pos + @ngramSize - 1; 

		INSERT INTO @output(ngram)
		SELECT TRIM(@outputstring);

		SELECT @Pos+=1;
	END;

	RETURN;
END