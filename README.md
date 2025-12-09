# Delta Sharing Spark Ingestion

Projeto para consumo de dados compartilhados via **Delta Sharing** utilizando **PySpark** e ingestão em **MongoDB**.

## 📋 Descrição

Este projeto demonstra como:
- Conectar-se a um servidor Delta Sharing
- Consumir dados compartilhados usando PySpark
- Processar e transformar dados com Spark SQL
- Ingerir dados processados em MongoDB
- Executar todo o ambiente em containers Docker

## 🕹️ Simulação
Este projeto utiliza **dados simulados da plataforma Blip**, obtidos através de um **bot de teste** criado especificamente para demonstração. Os dados não representam conversas reais e servem apenas para fins educacionais e de desenvolvimento.

## 🏗️ Arquitetura

```
┌─────────────────────┐
│  Delta Sharing      │
│  Server             │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐     ┌─────────────────────┐
│  PySpark/Jupyter    │────▶│     MongoDB         │
│  Container          │     │     Container       │
└─────────────────────┘     └─────────────────────┘
```

## 🚀 Tecnologias

- **PySpark 3.x**: Processamento distribuído de dados
- **Delta Sharing**: Protocolo de compartilhamento de dados
- **MongoDB**: Banco de dados NoSQL para armazenamento
- **Jupyter Notebook**: Interface interativa para desenvolvimento
- **Docker & Docker Compose**: Orquestração de containers

## 📚 Dependências JAR

Este projeto utiliza JARs externos para integração com Delta Sharing e MongoDB. Eles são carregados automaticamente durante a inicialização da SparkSession através da configuração `spark.jars.packages`.

### JARs Utilizados

#### 1. **MongoDB Spark Connector** (`org.mongodb.spark:mongo-spark-connector_2.12:3.0.1`)

- **Propósito**: Permite a leitura e escrita de dados entre Spark DataFrames e MongoDB
- **Funcionalidades**:
  - Escrita de dados processados no MongoDB com suporte a diferentes modos (append, overwrite)
  - Leitura de coleções MongoDB como DataFrames
  - Suporte a agregações e filtros do lado do MongoDB
  - Inferência automática de schema
- **Documentação**: [MongoDB Spark Connector](https://docs.mongodb.com/spark-connector/current/)

#### 2. **Delta Sharing Spark** (`io.delta:delta-sharing-spark_2.12:0.7.0`)

- **Propósito**: Implementa o protocolo Delta Sharing para consumo de dados compartilhados
- **Funcionalidades**:
  - Leitura de tabelas Delta compartilhadas via protocolo REST
  - Autenticação via Bearer Token
  - Suporte a versionamento e time travel de dados
  - Integração nativa com Spark DataFrames
- **Documentação**: [Delta Sharing Protocol](https://github.com/delta-io/delta-sharing)

### Configuração no Código

```python
spark = (
    SparkSession
    .builder.appName("DeltaSharingApp")
    .config("spark.jars.packages",
            "org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,"
            "io.delta:delta-sharing-spark_2.12:0.7.0")
    .getOrCreate()
)
```

### Observações
- **Download Automático**: Os JARs são baixados automaticamente do Maven Central na primeira execução
- **Cache Local**: Após o primeiro download, os JARs são armazenados em cache no container
- **Versões Alternativas**: Para usar versões diferentes, ajuste os números de versão na configuração `spark.jars.packages`

## 📦 Pré-requisitos

- Docker
- Acesso a um servidor Delta Sharing (token e endpoint)

## ⚙️ Configuração

### 1. Clone o repositório

```bash
git clone https://github.com/eduardoveloso/delta_sharing_spark_ingestion.git
cd delta_sharing_spark_ingestion
```

### 2. Configure o Delta Sharing

Crie o arquivo de configuração `src/config.share` baseado no exemplo:

```bash
cp src/config.share.example src/config.share
```

Edite `config.share` com suas credenciais:

```json
{
    "shareCredentialsVersion": 1,
    "bearerToken": "SEU_TOKEN_AQUI",
    "endpoint": "URL_SERVIDOR",
    "expirationTime": "2026-12-01T19:02:37.420Z"
}
```

### 3. Inicie os containers

```bash
docker-compose up -d
```

Isso irá iniciar:
- **PySpark/Jupyter** na porta `8888`
- **Spark UI** na porta `4040`
- **MongoDB** na porta `27017`

## 🔧 Uso

### Acessar o Jupyter Notebook

Abra seu navegador em: `http://localhost:8888`

O notebook `delta_sharing.ipynb` está disponível no diretório `work`.

### Estrutura do Notebook

1. **Configuração da Sessão Spark**
   - Inicializa SparkSession com Delta Sharing e MongoDB connectors

2. **Conexão com Delta Sharing**
   - Carrega credenciais do `config.share`
   - Lista tabelas disponíveis

3. **Leitura de Dados**
   - Consome dados da tabela Delta Sharing
   - Aplica transformações SQL

4. **Processamento**
   - Decodifica conteúdo em Base64
   - Filtra dados por tenant e data
   - Transforma campos

5. **Ingestão no MongoDB**
   - Escreve dados processados no MongoDB
   - Modo append para preservar dados existentes


## 🗂️ Estrutura do Projeto

```
.
├── docker-compose.yaml          # Orquestração dos containers
├── dockerfile                   # Imagem customizada do PySpark
├── README.md                    # Este arquivo
└── src/
    ├── config.share             # Credenciais Delta Sharing (não versionado)
    ├── config.share.example     # Exemplo de configuração
    └── delta_sharing.ipynb      # Notebook principal
```

## 🔍 Validação e Testes

### Testar Conexão Delta Sharing

```python
import delta_sharing

profile_file = "./config.share"
client = delta_sharing.SharingClient(profile_file)

# Listar todas as tabelas disponíveis
print(client.list_all_tables())
```

### Testar Conexão MongoDB

```bash
# Dentro do container ou via mongo client
mongo mongodb://admin:admin123@localhost:27017

use delta_sharing_teste
db.messages.count()
db.messages.findOne()
```

### Validar Processamento Spark

```python
# Verificar schema dos dados
df.printSchema()

# Contar registros
print(f"Total de registros: {df.count()}")

# Visualizar amostra
df.show(5, truncate=False)
```

## 🐛 Troubleshooting

### Erro de Autenticação Delta Sharing

- Verifique se o token no `config.share` está válido
- Confirme que a URL do endpoint está correta
- Verifique se o token não expirou

### Erro de Conexão MongoDB

- Confirme que o container MongoDB está rodando: `docker ps`
- Verifique as credenciais (admin:admin123)
- Certifique-se de que os containers estão na mesma rede

### Spark UI não acessível

- Aguarde alguns segundos após iniciar o container
- Verifique se a porta 4040 não está em uso
- Acesse: `http://localhost:4040`

## 📊 Monitoramento

- **Jupyter Notebook**: `http://localhost:8888`
- **Spark UI**: `http://localhost:4040`
- **MongoDB**: `mongodb://admin:admin123@localhost:27017`

## 🛑 Parar o Ambiente

```bash
# Parar containers
docker-compose down

# Parar e remover volumes
docker-compose down -v
```

## 📝 Notas

- Os dados no MongoDB são persistidos no volume `mongo_data`
- O diretório `src` é montado como volume no container
- Nunca, jamais, versione o arquivo `config.share` com credenciais reais
- Use `.gitignore` para proteger informações sensíveis

## 👤 Autor

**Eduardo Veloso**
- GitHub: [@eduardoveloso](https://github.com/eduardoveloso)

## 🔗 Links Úteis

- [Delta Sharing Protocol](https://github.com/delta-io/delta-sharing)
- [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)
- [MongoDB Spark Connector](https://docs.mongodb.com/spark-connector/current/)
- [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/)
