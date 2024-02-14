## Documentação das Tabelas `tb_customer` e `tb_Client_Copy`

Este documento descreve as tabelas `tb_customer` e `tb_Client_Copy`, incluindo suas colunas, restrições e diferenças entre elas.

**Tabela `tb_customer`**

| Coluna | Tipo de Dado | Nulo | Valor Padrão | Descripción |
|---|---|---|---|---|
| id | INT | NO | - | Identificador único do cliente (chave primária). |
| name | VARCHAR(50) | NO | - | Nome do cliente. |
| weight | DECIMAL(5,2) | NO | 0.00 | Peso do cliente. |
| date_of_birth | DATE | SI | - | Data de nascimento do cliente. |
| registration_number | UNIQUEIDENTIFIER | NO | NEWID() | Número de registro único do cliente. |

**Restrições:**

* **PK_tb_customer:** Chave primária na coluna `id`.

**Tabela `tb_Client_Copy`**

| Coluna | Tipo de Dado | Nulo | Valor Padrão | Descripción |
|---|---|---|---|---|
| id | INT | NO | - | Identificador único do cliente. |
| name | VARCHAR(100) | NO | - | Nome do cliente (chave primária). |
| weight | DECIMAL(10,2) | NO | 0.00 | Peso do cliente. |
| date_of_birth | DATE | NO | - | Data de nascimento do cliente. |
| registration_number | UNIQUEIDENTIFIER | SI | NEWID() | Número de registro único do cliente. |
| height | INT | NO | - | Altura do cliente (único). |

**Restrições:**

* **PK_tb_Client_Copy:** Chave primária na coluna `name`.
* **UNIQUE_tall:** A coluna `tall` possui valores únicos.

**Diferenças entre as tabelas:**

* A tabela `tb_Client_Copy` possui uma coluna a mais: `height`.
* As colunas `name`, `weight` e `registration_number` possuem tamanhos de dados e valores padrões diferentes nas duas tabelas.
* A coluna `date_of_birth` é obrigatória na `tb_Client_Copy`, mas opcional na `tb_customer`.
* A coluna `registration_number` é opcional e possui valor padrão diferente na `tb_Client_Copy`.
* A chave primária é diferente em cada tabela: `id` na `tb_customer` e `name` na `tb_Client_Copy`.
* A tabela `tb_Client_Copy` possui uma restrição única adicional na coluna `height`.

**Observações:**

* É importante considerar o motivo das diferenças entre as tabelas para garantir a consistência dos dados.
* É recomendado revisar se o tamanho dos dados das colunas é adequado para as necessidades do sistema.
* A obrigatoriedade da data de nascimento na `tb_Client_Copy` pode impactar a lógica de negócio.
* Verifique se os valores padrão definidos são apropriados para cada coluna.
* A escolha da chave primária deve ser baseada na forma como os dados serão acessados e manipulados.

