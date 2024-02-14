-- Objetivo: Alterar as características nullable das colunas da tabela tb_copia_cliente para que sejam iguais às da tabela tb_cliente.

DECLARE @colunas_nullable TABLE (
    column_name NVARCHAR(MAX),
    data_type NVARCHAR(MAX),
    is_nullable_original BIT,
    is_nullable_novo BIT
);

-- Obter colunas com características nullable diferentes, incluindo data_type
INSERT INTO @colunas_nullable (column_name, data_type, is_nullable_original, is_nullable_novo)
SELECT 
    c.column_name, 
    c.DATA_TYPE, 
    CASE WHEN c.IS_NULLABLE = 'YES' THEN 1 ELSE 0 END, -- Convertendo para BIT aqui
    CASE WHEN cc.IS_NULLABLE = 'YES' THEN 1 ELSE 0 END -- Convertendo para BIT aqui
FROM information_schema.columns c
INNER JOIN information_schema.columns cc 
    ON c.column_name = cc.column_name AND cc.table_name = 'tb_copia_cliente'
WHERE c.table_name = 'tb_cliente'
AND c.column_name IN (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_name = 'tb_copia_cliente'
)
AND (CASE WHEN c.IS_NULLABLE = 'YES' THEN 1 ELSE 0 END) <> (CASE WHEN cc.IS_NULLABLE = 'YES' THEN 1 ELSE 0 END);

-- Gerar script para alterar características nullable
DECLARE @query_alterar_caracteristicas_nullable NVARCHAR(MAX);
SET @query_alterar_caracteristicas_nullable = '';

-- Seleção e concatenação dos comandos de alteração
SELECT @query_alterar_caracteristicas_nullable = @query_alterar_caracteristicas_nullable +
    'ALTER TABLE [schema3].[tb_copia_cliente] ALTER COLUMN ' + column_name + ' ' + data_type +
    CASE 
        WHEN is_nullable_novo = 1 THEN ' NULL; '
        ELSE ' NOT NULL; '
    END
FROM @colunas_nullable;

-- Executar os comandos SQL gerados
EXEC sp_executesql @query_alterar_caracteristicas_nullable;
