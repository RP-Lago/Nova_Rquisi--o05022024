DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''tb_cliente'' AND TABLE_SCHEMA = ''dbo'' AND COLUMN_NAME = ''' + c.COLUMN_NAME + ''') ' +
    'BEGIN ' +
    'ALTER TABLE [schema3].[tb_copia_cliente] ALTER COLUMN ' + QUOTENAME(c.COLUMN_NAME) + ' ' + t.DATA_TYPE + 
    CASE 
        WHEN t.DATA_TYPE IN ('varchar', 'char', 'varbinary', 'binary', 'text')
            THEN '(' + CASE WHEN t.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX' ELSE CAST(t.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) END + ')'
        WHEN t.DATA_TYPE IN ('nchar', 'nvarchar')
            THEN '(' + CASE WHEN t.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX' ELSE CAST(t.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) END + ') COLLATE ' + t.COLLATION_NAME
        WHEN t.DATA_TYPE IN ('decimal', 'numeric')
            THEN '(' + CAST(t.NUMERIC_PRECISION AS VARCHAR) + ', ' + CAST(t.NUMERIC_SCALE AS VARCHAR) + ')'
        ELSE ''
    END + 
    CASE 
        WHEN t.IS_NULLABLE = 'YES' THEN ' NULL'
        ELSE ' NOT NULL'
    END + 
    ' END; '
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN INFORMATION_SCHEMA.COLUMNS t ON t.TABLE_NAME = 'tb_cliente' AND t.TABLE_SCHEMA = 'dbo' AND t.COLUMN_NAME = c.COLUMN_NAME
WHERE c.TABLE_NAME = 'tb_copia_cliente' AND c.TABLE_SCHEMA = 'schema3';

EXEC sp_executesql @sql;
