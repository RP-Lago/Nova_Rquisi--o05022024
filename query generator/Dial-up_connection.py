import pyodbc
from config import username, password, server, database, DRIVER_ODBC, MAIN_SCHEMA, NEW_SCHEMA, table_name, table_name2

# Creation of table2 in the new schema
# String de conexão
connection = pyodbc.connect(f"DRIVER={DRIVER_ODBC};\
                            SERVER={server};\
                            DATABASE={database};\
                            UID={username};\
                            PWD={password}")
cursor = connection.cursor()

# Creation of the new schema
cursor.execute(f"CREATE SCHEMA {NEW_SCHEMA}")
connection.commit()

# Creation of table1 in the main schema
cursor.execute(f"""
CREATE TABLE {MAIN_SCHEMA}.{table_name} (
    id INT              NOT NULL,
    name VARCHAR(50)    NOT NULL,
    weight DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    date_of_birth       DATE NULL,
    registration_number UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_{table_name} PRIMARY KEY (id)
)
""")

cursor.execute(f"""
CREATE TABLE {NEW_SCHEMA}.{table_name2} (
    id INT              NOT NULL,
    name VARCHAR(100)   NOT NULL,                                   -- Difference in data size
    weight DECIMAL(10,2)NOT NULL DEFAULT 0.00,                      -- Difference in data size and default values
    date_of_birth DATE  NOT NULL,                                   -- Difference in nullable property
    registration_number UNIQUEIDENTIFIER NULL DEFAULT NEWID(),      -- Difference in nullable property and default values
    tall INT UNIQUE,                                                -- Difference in unique attribute
    CONSTRAINT PK_{table_name2} PRIMARY KEY (name)                  -- Difference in primary key
)
""")

connection.commit()
