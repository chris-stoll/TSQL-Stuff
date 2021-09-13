
SELECT *	
FROM OPENROWSET (
     BULK 'D:\SQL2019\csv\sample.csv'
    ,FORMATFILE = 'D:\SQL2019\csv\sample.xml'
    ,CODEPAGE = '65001'
    ,FIRSTROW = 2
) as j
