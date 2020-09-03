SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE dbo.SqlSearch
    @SearchText VARCHAR(MAX)
AS
BEGIN
                            SELECT s.name +'.' + o.name AS 'ObjectName', o.type_desc
        FROM sys.objects o
            JOIN sys.all_sql_modules asm
            ON o.object_id = asm.object_id
            JOIN sys.schemas s
            ON s.schema_id = o.schema_id
        WHERE  asm.definition LIKE '%' + @SearchText + '%'
            OR o.name LIKE '%' + @SearchText + '%'
            OR s.name LIKE '%' + @SearchText + '%'
    UNION ALL
        SELECT DISTINCT
            s.name+ '.' + t.name
    + ISNULL(' (' + CASE WHEN c.name LIKE '%' + @SearchText + '%' THEN c.name ELSE NULL END + ')', '')
        , 'TABLE' + ISNULL(' (' + CASE WHEN c.name LIKE '%' + @SearchText + '%' THEN ' COLUMN' ELSE NULL END + ')', '') AS 'type_desc'
        FROM sys.columns c
            JOIN sys.tables  t
            ON c.object_id = t.object_id
            JOIN sys.schemas s
            ON s.schema_id = t.schema_id
        WHERE  c.name LIKE '%' + @SearchText + '%'
            OR t.name LIKE '%' + @SearchText + '%'
            OR s.name LIKE '%' + @SearchText + '%'
    UNION ALL
        SELECT
            j.name,
            'SQL Agent Job'
        FROM msdb.dbo.sysjobs j
            JOIN msdb.dbo.sysjobsteps js
            ON js.job_id = j.job_id
        WHERE js.command LIKE '%' + @SearchText + '%'
            OR js.step_name LIKE '%' + @SearchText + '%'
            OR j.name LIKE '%' + @SearchText + '%'
            OR j.description LIKE '%' + @SearchText + '%'
    UNION ALL
        SELECT s.name + '.' + t.name + ' (' + cc.name + ')', cc.type_desc
        FROM sys.check_constraints cc
            JOIN sys.tables t
            ON t.object_id = cc.parent_object_id
            JOIN sys.schemas s
            ON s.schema_id = t.schema_id
        WHERE cc.name LIKE '%' + @SearchText + '%'
            OR cc.definition LIKE '%' + @SearchText + '%'
    UNION ALL
        SELECT s.name + '.' + t.name + ' (' + dc.name + ')', dc.type_desc
        FROM sys.default_constraints dc
            JOIN sys.tables t
            ON t.object_id = dc.parent_object_id
            JOIN sys.schemas s
            ON s.schema_id = t.schema_id
        WHERE dc.name LIKE '%' + @SearchText + '%'
            OR dc.definition LIKE '%' + @SearchText + '%'
    UNION ALL
        SELECT DISTINCT s.name + '.' + t.name + ' (' + i.name + ')', 'NC_Index_Filter'
        FROM sys.indexes i
            JOIN sys.tables t
            ON t.object_id = i.object_id
            JOIN sys.schemas s
            ON s.schema_id = t.schema_id
        WHERE i.filter_definition LIKE '%' + @SearchText + '%'
    ORDER BY 2,1;
END
GO
