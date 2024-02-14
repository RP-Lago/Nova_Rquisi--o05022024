-- Script ajustado para verificar e corrigir FKs entre tb_cliente e tb_copia_cliente

-- Primeiro, vamos identificar as FKs que diferem ou estão ausentes em tb_copia_cliente
DECLARE @ForeignKeyOperations NVARCHAR(MAX) = '';

SELECT @ForeignKeyOperations = @ForeignKeyOperations +
    'ALTER TABLE [dbo].[tb_copia_cliente] DROP CONSTRAINT ' + QUOTENAME(fk.NAME) + '; ' +
    'ALTER TABLE [dbo].[tb_copia_cliente] ADD CONSTRAINT ' + QUOTENAME(fk.NAME) +
    ' FOREIGN KEY (' + COLUMN_NAME + ') REFERENCES ' + REFERENCED_TABLE_NAME + '(' + REFERENCED_COLUMN_NAME + '); '
FROM 
    (SELECT 
        fk.NAME, 
        c.NAME AS COLUMN_NAME, 
        fk_tab.NAME AS REFERENCED_TABLE_NAME, 
        ref_c.NAME AS REFERENCED_COLUMN_NAME
     FROM 
        sys.foreign_keys AS fk
     INNER JOIN 
        sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
     INNER JOIN 
        sys.columns AS c ON fc.parent_object_id = c.object_id AND fc.parent_column_id = c.column_id
     INNER JOIN 
        sys.tables AS fk_tab ON fk.referenced_object_id = fk_tab.object_id
     INNER JOIN 
        sys.columns AS ref_c ON fc.referenced_object_id = ref_c.object_id AND fc.referenced_column_id = ref_c.column_id
     WHERE 
        fk.parent_object_id = OBJECT_ID('tb_cliente')) AS fk_info
WHERE 
    NOT EXISTS (
        SELECT 1 FROM 
            sys.foreign_keys AS fk_copia
        INNER JOIN 
            sys.tables AS t_copia ON fk_copia.parent_object_id = t_copia.object_id
        WHERE 
            t_copia.name = 'tb_copia_cliente' AND fk_copia.name = fk_info.NAME
    );

-- Executar as operações de FK acumuladas
EXEC sp_executesql @ForeignKeyOperations;
