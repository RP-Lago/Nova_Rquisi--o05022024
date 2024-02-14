-- Etapa 5: Criar script para tratar valores default na tabela clonada caso esteja diferente

DECLARE @colunas_default TABLE (
    column_name NVARCHAR(MAX),
    column_default_original NVARCHAR(MAX),
    column_default_novo NVARCHAR(MAX)
);

-- Obter colunas com valores default diferentes
INSERT INTO @colunas_default
SELECT c.column_name, c.column_default, t.column_default
FROM information_schema.columns c
JOIN information_schema.columns t ON t.TABLE_NAME = 'tb_cliente' AND t.TABLE_SCHEMA = 'dbo' AND t.COLUMN_NAME = c.COLUMN_NAME
WHERE c.table_name = 'tb_copia_cliente'
AND c.table_schema = 'schema3'
AND c.column_default <> t.column_default;

-- Gerar script para alterar valores default
DECLARE @query_alterar_valores_default NVARCHAR(MAX) = N'';

SELECT @query_alterar_valores_default = @query_alterar_valores_default + 
    CASE 
        WHEN column_default_novo IS NOT NULL THEN 
            'ALTER TABLE [schema3].[tb_copia_cliente] DROP CONSTRAINT IF EXISTS DF_' + column_name + '; ' +
            'ALTER TABLE [schema3].[tb_copia_cliente] ADD CONSTRAINT DF_' + column_name + ' DEFAULT ' + column_default_novo + ' FOR ' + column_name + '; '
        ELSE 
            '' 
    END
FROM @colunas_default;

-- Executar script
EXEC sp_executesql @query_alterar_valores_default;
