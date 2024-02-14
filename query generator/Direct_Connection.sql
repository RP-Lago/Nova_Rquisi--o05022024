-- Criação da tb_customer
CREATE TABLE tb_customer (
    id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    weight DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    date_of_birth DATE NULL,
    registration_number UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_tb_customer PRIMARY KEY (id)
);

-- Criação da tb_Client_Copy
CREATE TABLE tb_Client_Copy (
    id INT NOT NULL,
    name VARCHAR(100) NOT NULL,                                -- Diferença no tamanho dos dados
    weight DECIMAL(10,2) NOT NULL DEFAULT 0.00,                -- Diferença no tamanho dos dados e valores default
    date_of_birth DATE NOT NULL,                               -- Diferença na propriedade nullable
    registration_number UNIQUEIDENTIFIER NULL DEFAULT NEWID(), -- Diferença na propriedade nullable e valores default
    height INT UNIQUE,                                         -- Diferença no atributo unique
    CONSTRAINT PK_tb_Client_Copy PRIMARY KEY (name)            -- Diferença na primary key
);
