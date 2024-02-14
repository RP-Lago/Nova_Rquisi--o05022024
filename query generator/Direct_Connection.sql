DECLARE @schemaName VARCHAR(50);

-- Loop para criar os schemas
SET @schemaName = 'dbo';
WHILE @schemaName IS NOT NULL
BEGIN
  IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = @schemaName)
  BEGIN
    EXEC sp_executesql N'CREATE SCHEMA [@schemaName]';
  END
  SET @schemaName = CASE WHEN @schemaName = 'dbo' THEN 'customer' ELSE NULL END;
END;

-- Criação da tb_customer no schema dbo
CREATE TABLE dbo.tb_customer0 (
  id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  weight DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  date_of_birth DATE NULL,
  registration_number UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  CONSTRAINT PK_tb_customer0 PRIMARY KEY (id)
);

-- Criação da tb_Client_Copy no schema customer
CREATE TABLE schema1.tb_Client_Copy0 (
  id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  weight DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  date_of_birth DATE NOT NULL,
  registration_number UNIQUEIDENTIFIER NULL DEFAULT NEWID(),
  height INT UNIQUE,
  CONSTRAINT PK_tb_Client_Copy0 PRIMARY KEY (name)
);
