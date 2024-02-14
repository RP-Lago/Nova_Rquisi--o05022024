-- Etapa 2: Criar script para alterar os tipos de dados das colunas na tabela clonada

DECLARE @colunas_alterar TABLE (
    column_name NVARCHAR(MAX),
    data_type_original NVARCHAR(MAX),
    data_type_novo NVARCHAR(MAX)
);

DECLARE @colunas_tamanho TABLE (
    column_name NVARCHAR(MAX),
    character_maximum_length_original INT,
    character_maximum_length_novo INT
);

-- Obter colunas com tipos de dados diferentes
INSERT INTO @colunas_alterar
SELECT c1.column_name, c1.data_type, c2.data_type
FROM information_schema.columns c1
JOIN information_schema.columns c2 ON c1.column_name = c2.column_name AND c1.table_schema = c2.table_schema
WHERE c1.table_name = 'tb_cliente'
AND c2.table_name = 'tb_copia_cliente'
AND c1.data_type <> c2.data_type;

-- Obter colunas com tamanhos de dados diferentes
INSERT INTO @colunas_tamanho
SELECT c1.column_name, c1.character_maximum_length, c2.character_maximum_length
FROM information_schema.columns c1
JOIN information_schema.columns c2 ON c1.column_name = c2.column_name AND c1.table_schema = c2.table_schema
WHERE c1.table_name = 'tb_cliente'
AND c2.table_name = 'tb_copia_cliente'
AND c1.character_maximum_length <> c2.character_maximum_length;

-- Gerar script para alterar tipos de dados
DECLARE @query_alterar_tipos_dados NVARCHAR(MAX) = '';

SELECT @query_alterar_tipos_dados = @query_alterar_tipos_dados + 'ALTER TABLE [schema3].[tb_copia_cliente] ALTER COLUMN ' + column_name + ' ' + data_type_novo + ';'
FROM @colunas_alterar;

-- Gerar script para alterar tamanhos de dados
DECLARE @query_alterar_tamanhos_dados NVARCHAR(MAX) = '';

SELECT @query_alterar_tamanhos_dados = @query_alterar_tamanhos_dados + 'ALTER TABLE [schema3].[tb_copia_cliente] ALTER COLUMN ' + column_name + ' VARCHAR(' + CONVERT(NVARCHAR(MAX), character_maximum_length_novo) + ');'
FROM @colunas_tamanho;

-- Executar scripts
EXEC sp_executesql @query_alterar_tipos_dados;
EXEC sp_executesql @query_alterar_tamanhos_dados;
