CREATE OR ALTER VIEW dbo.vLineByLineFile
AS
	SELECT j.SingleLine
	FROM OPENROWSET (BULK '{FileHere}.extension'
	,FORMATFILE = '{FolderHere}\LineByLine.xml'
	,CODEPAGE = '65001'
	) as j
GO