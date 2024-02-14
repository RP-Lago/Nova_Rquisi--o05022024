-- Step 1: Create script to add and remove columns in the cloned table if they are different

DECLARE @columns_to_add TABLE (
    column_name NVARCHAR(MAX),
    data_type NVARCHAR(MAX),
    character_maximum_length INT,
    is_nullable BIT,
    column_default NVARCHAR(MAX),
    is_identity BIT
);

-- Get columns from the original table that are not in the cloned table
INSERT INTO @columns_to_add (column_name, data_type, character_maximum_length, is_nullable, column_default, is_identity)
SELECT c.column_name, c.data_type, c.character_maximum_length, 
       CASE
           WHEN c.is_nullable = 'YES' THEN 1
           ELSE 0
       END AS is_nullable,
       c.column_default, 
       CASE
           WHEN COLUMNPROPERTY(object_id(c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') = 1 THEN 1
           ELSE 0
       END AS is_identity
FROM information_schema.columns c
WHERE c.table_name = 'tb_cliente'
AND c.table_schema = 'dbo'
AND NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'tb_copia_cliente'       
    AND table_schema = 'schema3'
    AND column_name = c.column_name
);

-- Generate script to add and adjust columns
DECLARE @query_add_columns NVARCHAR(MAX) = '';

SELECT @query_add_columns += 
    'ALTER TABLE [schema3].[tb_copia_cliente] ADD ' + QUOTENAME(column_name) + ' ' + data_type +
    CASE
        WHEN character_maximum_length IS NOT NULL THEN '(' + CONVERT(NVARCHAR(MAX), character_maximum_length) + ')'
        ELSE ''
    END +
    CASE
        WHEN is_nullable = 1 THEN ' NULL'
        ELSE ' NOT NULL'
    END +
    CASE
        WHEN column_default IS NOT NULL THEN ' DEFAULT ' + column_default
        ELSE ''
    END +
    CASE
        WHEN is_identity = 1 THEN ' IDENTITY(1,1)'
        ELSE ''
    END + '; '
FROM @columns_to_add;

-- Execute scripts
EXEC sp_executesql @query_add_columns;

-- Create script to remove columns in the cloned table that are not in the original table

DECLARE @columns_to_remove TABLE (
    column_name NVARCHAR(MAX)
);

-- Get columns from the cloned table that are not in the original table
INSERT INTO @columns_to_remove
SELECT c.column_name
FROM information_schema.columns c
WHERE c.table_name = 'tb_copia_cliente'
AND c.table_schema = 'schema3'
AND NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'tb_cliente'
    AND table_schema = 'dbo'
    AND column_name = c.column_name
);

-- Generate script to remove columns
DECLARE @query_remove_columns NVARCHAR(MAX) = '';

SELECT @query_remove_columns += 'ALTER TABLE [schema3].[tb_copia_cliente] DROP COLUMN ' + QUOTENAME(column_name) + '; '
FROM @columns_to_remove;

-- Execute scripts
EXEC sp_executesql @query_remove_columns;
