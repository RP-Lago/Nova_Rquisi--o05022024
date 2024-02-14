-- Etapa 7: Criar script para alterar colunas do tipo constraints (como default, unique, ou primary key), na tabela clonada caso este diferente

DECLARE @colunas_constraints TABLE (
    column_name NVARCHAR(MAX),
    constraint_type NVARCHAR(MAX),
    constraint_name NVARCHAR(MAX)
);

-- Obter colunas com constraints diferentes
INSERT INTO @colunas_constraints
SELECT column_name, constraint_type, constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'tb_cliente'
AND column_name IN (
    SELECT column_name
    FROM information_schema.table_constraints
    WHERE table_name = 'tb_copia_cliente'
)
AND (constraint_type = 'DEFAULT' OR constraint_type = 'UNIQUE' OR constraint_type = 'PRIMARY KEY')
AND constraint_name <> constraint_name;

-- Gerar script para alterar constraints
DECLARE @query_alterar_constraints NVARCHAR(MAX) = '';

SELECT @query_alterar_constraints 
     = @query_alterar_constraints + 'ALTER TABLE [dbo].[tb_copia_cliente] ALTER COLUMN ' + column_name + ' ' + data_type + 
                   CASE 
                        WHEN constraint_type = 'DEFAULT'     THEN ' DEFAULT ' + column_default_novo
                        WHEN constraint_type = 'UNIQUE'      THEN ' CONSTRAINT ' + constraint_name + ' UNIQUE'
                        WHEN constraint_type = 'PRIMARY KEY' THEN ' CONSTRAINT ' + constraint_name + ' PRIMARY KEY'
                   END + ';'
FROM @colunas_constraints;

-- Executar script
EXEC sp_executesql @query_alterar_constraints;
