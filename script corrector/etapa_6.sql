-- Etapa 6: Criar script para lidar com restrições unique na tabela clonada caso esteja diferente
--etapa-6.sql
DECLARE @restricoes_unique TABLE (
    constraint_name NVARCHAR(MAX),
    column_name NVARCHAR(MAX)
);

-- Obter restrições unique diferentes
INSERT INTO @restricoes_unique
SELECT tc.constraint_name, cc.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.constraint_column_usage cc ON cc.constraint_name = tc.constraint_name
WHERE tc.table_name = 'tb_cliente'
AND tc.table_schema = 'dbo'
AND tc.constraint_type = 'UNIQUE'
AND tc.constraint_name NOT IN (
    SELECT constraint_name
    FROM information_schema.table_constraints
    WHERE table_name = 'tb_copia_cliente'
    AND table_schema = 'schema3'
    AND constraint_type = 'UNIQUE'
);

-- Gerar script para adicionar restrições unique
DECLARE @query_adicionar_restricoes_unique NVARCHAR(MAX) = N'';

SELECT @query_adicionar_restricoes_unique = @query_adicionar_restricoes_unique + 
    'ALTER TABLE [schema3].[tb_copia_cliente] ADD CONSTRAINT ' + constraint_name + ' UNIQUE (' + QUOTENAME(column_name) + '); '
FROM @restricoes_unique;

-- Executar script
EXEC sp_executesql @query_adicionar_restricoes_unique;

