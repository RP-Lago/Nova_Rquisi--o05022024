-- Script ajustado para identificar e corrigir FKs com base na comparação dinâmica entre tb_cliente e tb_copia_cliente

DECLARE @TabelaOrigem NVARCHAR(128) = 'tb_cliente',
        @TabelaCopia NVARCHAR(128) = 'tb_copia_cliente',
        @ComandoDrop NVARCHAR(MAX),
        @ComandoAdd NVARCHAR(MAX);

-- Criar tabela temporária para armazenar as diferenças de FK
IF OBJECT_ID('tempdb..#DiferencasFK') IS NOT NULL DROP TABLE #DiferencasFK;
CREATE TABLE #DiferencasFK (
    ConstraintName NVARCHAR(128),
    ComandoDrop NVARCHAR(MAX),
    ComandoAdd NVARCHAR(MAX)
);

-- Inserir na tabela temporária as diferenças de FK entre as tabelas origem e cópia
INSERT INTO #DiferencasFK (ConstraintName, ComandoDrop, ComandoAdd)
SELECT 
    rc.CONSTRAINT_NAME, 
    'ALTER TABLE ' + QUOTENAME(@TabelaCopia) + ' DROP CONSTRAINT ' + QUOTENAME(rc.CONSTRAINT_NAME),
    'ALTER TABLE ' + QUOTENAME(@TabelaCopia) + 
    ' ADD CONSTRAINT ' + QUOTENAME(rc.CONSTRAINT_NAME) + 
    ' FOREIGN KEY (' + ccu.COLUMN_NAME + ') REFERENCES ' + kcu.TABLE_NAME + '(' + kcu.COLUMN_NAME + ')'
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON rc.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON ccu.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON kcu.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
WHERE tc.TABLE_NAME = @TabelaOrigem
AND NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rcc
    JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tcc ON rcc.CONSTRAINT_NAME = tcc.CONSTRAINT_NAME
    WHERE tcc.TABLE_NAME = @TabelaCopia
    AND rcc.UNIQUE_CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
);

-- Iterar sobre as diferenças de FK e aplicar correções
DECLARE @ConstraintName NVARCHAR(128);

DECLARE fk_cursor CURSOR FOR
SELECT ConstraintName, ComandoDrop, ComandoAdd FROM #DiferencasFK;

OPEN fk_cursor;

FETCH NEXT FROM fk_cursor INTO @ConstraintName, @ComandoDrop, @ComandoAdd;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Remover a FK, se existir na tabela cópia
    EXEC sp_executesql @ComandoDrop;
    
    -- Recriar a FK na tabela cópia com base na definição da tabela original
    EXEC sp_executesql @ComandoAdd;

    FETCH NEXT FROM fk_cursor INTO @ConstraintName, @ComandoDrop, @ComandoAdd;
END;

CLOSE fk_cursor;
DEALLOCATE fk_cursor;

-- Limpeza
DROP TABLE #DiferencasFK;
