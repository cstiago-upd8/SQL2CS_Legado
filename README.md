# SQL2CS - Sistema de Gerenciamento de Chamados/OS

Sistema web para gerenciamento de Chamados e Ordens de Serviço desenvolvido em **ASP Clássico (VBScript)** com banco de dados **PostgreSQL** na AWS.

Identidade visual baseada no padrão **UPD8** ([www.upd8.com.br](http://www.upd8.com.br)).

---

## Funcionalidades

- Cadastro de chamados técnicos
- Edição de chamados existentes
- Exclusão de chamados (com confirmação)
- Listagem e pesquisa com filtros (por título, técnico e status)
- Histórico/auditoria de alterações (tabela `historicochamados`)
- Regra de negócio: não permite fechar/resolver chamado sem preencher a solução técnica
- Badges visuais para prioridade e status
- Layout responsivo

---

## Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| Frontend | HTML5, CSS3 (variáveis CSS, Grid, Flexbox), Google Fonts (Inter) |
| Backend | ASP Clássico (VBScript) rodando no IIS |
| Banco de Dados | PostgreSQL 14 (AWS EC2) |
| Conexão | ADO (ADODB.Connection) via driver ODBC PostgreSQL Unicode |
| Funções DB | PL/pgSQL (equivalente a Stored Procedures) |

---

## Estrutura do Projeto

```
SQL2CS/
├── chamados.asp                  # Formulário de cadastro/edição de chamados
├── pesquisa_chamados.asp         # Listagem e pesquisa de chamados
├── excluir_chamado.asp           # Exclusão de chamados via função PL/pgSQL
├── config.asp                    # Connection string (NÃO versionado - .gitignore)
├── config.exemplo.asp            # Template de configuração (exemplo)
├── database_chamados_postgres.sql # Script DDL para PostgreSQL (tabelas + funções)
├── database_chamados.sql         # Script DDL para SQL Server (referência/legado)
├── web.config                    # Configuração IIS
├── .gitignore                    # Ignora config.asp (credenciais)
└── README.md                     # Este arquivo
```

---

## Banco de Dados

### Tabelas

**chamados**
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| chamadoid | SERIAL (PK) | Identificador único |
| titulo | VARCHAR(200) | Título do chamado |
| descricao | VARCHAR(4000) | Descrição detalhada |
| prioridade | VARCHAR(50) | Baixa, Media, Alta, Critica |
| status | VARCHAR(50) | Aberto, Em Andamento, Aguardando, Resolvido, Fechado |
| tecnicoresp | VARCHAR(200) | Técnico responsável |
| solucaotecnica | VARCHAR(4000) | Solução aplicada |
| datacriacao | TIMESTAMP | Data de criação (automática) |
| dataatualizacao | TIMESTAMP | Data da última atualização |

**historicochamados**
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| historicoid | SERIAL (PK) | Identificador único |
| chamadoid | INT (FK) | Referência ao chamado |
| status | VARCHAR(50) | Status no momento do registro |
| tecnicoresp | VARCHAR(200) | Técnico no momento do registro |
| dataregistro | TIMESTAMP | Data do registro de auditoria |

### Funções PL/pgSQL

**sp_salvar_chamado** — Inserção e atualização de chamados
- Valida regra de negócio (solução obrigatória para Resolvido/Fechado)
- INSERT quando `p_chamadoid` é NULL, UPDATE caso contrário
- Registra histórico automaticamente na tabela `historicochamados`
- Retorna o ID do chamado

**sp_excluir_chamado** — Exclusão de chamados
- Valida existência do chamado
- Remove registros de histórico associados
- Remove o chamado

---

## Configuração do Ambiente

### Pré-requisitos

- Windows com **IIS** habilitado (com módulo ASP Clássico)
- **Driver ODBC PostgreSQL Unicode** (64-bit)
- Acesso de rede ao servidor PostgreSQL

### 1. Instalar IIS + ASP Clássico

PowerShell como Administrador:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-StaticContent, IIS-DefaultDocument, IIS-DirectoryBrowsing, IIS-HttpErrors, IIS-ASP, IIS-ISAPIExtensions, IIS-ISAPIFilter, IIS-ManagementConsole -All -NoRestart
```

### 2. Instalar Driver ODBC PostgreSQL

```powershell
winget install PostgreSQL.psqlODBC
```

### 3. Criar o Site no IIS

```powershell
Import-Module WebAdministration

New-WebAppPool -Name "PoolChamados"
Set-ItemProperty "IIS:\AppPools\PoolChamados" -Name "enable32BitAppOnWin64" -Value $false
Set-ItemProperty "IIS:\AppPools\PoolChamados" -Name "managedRuntimeVersion" -Value ""

New-Website -Name "Chamados" -Port 8080 -PhysicalPath "C:\Projetos\SQL2CS" -ApplicationPool "PoolChamados"

# Desbloquear seção ASP
Set-WebConfiguration -Filter "/system.webServer/asp" -PSPath "MACHINE/WEBROOT/APPHOST" -Metadata "overrideMode" -Value "Allow"
Set-WebConfigurationProperty -Filter "/system.webServer/asp" -PSPath "IIS:\Sites\Chamados" -Name "enableParentPaths" -Value $true
Set-WebConfigurationProperty -Filter "/system.webServer/asp" -PSPath "IIS:\Sites\Chamados" -Name "scriptErrorSentToBrowser" -Value $true

Start-Website -Name "Chamados"
```

### 4. Configurar Conexão com o Banco

Copie o arquivo de exemplo e preencha com suas credenciais:

```powershell
copy config.exemplo.asp config.asp
```

Edite `config.asp`:

```asp
<%
Dim DB_CONNECTION_STRING
DB_CONNECTION_STRING = "Driver={PostgreSQL Unicode};Server=SEU_HOST;Port=5432;Database=SEU_BANCO;Uid=SEU_USUARIO;Pwd=SUA_SENHA;"
%>
```

### 5. Criar Objetos no Banco

Execute o script `database_chamados_postgres.sql` no PostgreSQL usando psql, pgAdmin ou DBeaver.

---

## Uso

| Página | URL | Descrição |
|--------|-----|-----------|
| Pesquisa | http://localhost:8080/pesquisa_chamados.asp | Listagem e filtros |
| Novo Chamado | http://localhost:8080/chamados.asp | Formulário de cadastro |
| Editar Chamado | http://localhost:8080/chamados.asp?id=1 | Formulário de edição |

### Fluxo de Navegação

1. Acesse `pesquisa_chamados.asp` (tela principal)
2. Clique em **"+ Novo Chamado"** para cadastrar
3. Após salvar, é redirecionado automaticamente para a pesquisa
4. Na listagem, use **"Editar"** ou **"Excluir"** nas ações de cada registro
5. Filtros de busca por texto e status estão disponíveis no topo

---

## Identidade Visual

Padrão UPD8 com:

- **Paleta**: Azul primário (`#1a56db`), Azul marinho (`#0f2b5b`), Fundo cinza (`#f4f6f9`)
- **Tipografia**: Inter (Google Fonts)
- **Cards**: Fundo branco, `border-radius: 8px`, sombra suave
- **Botões**: Azul com hover e transição
- **Badges**: Cores por prioridade e status
- **Responsivo**: Grid adaptável para mobile

---

## Segurança

- Arquivo `config.asp` com credenciais **não é versionado** (protegido pelo `.gitignore`)
- Escape de aspas simples (`Replace(valor, "'", "''")`) nas queries
- `Server.HTMLEncode()` em todas as saídas para prevenir XSS
- Validação `IsNumeric` e `CLng` nos IDs recebidos via QueryString

---

## Repositório

- **GitHub**: [https://github.com/upd8-Inovacao/SQL2CS](https://github.com/upd8-Inovacao/SQL2CS)
- **Branch principal**: `main`

---

## Equipe

Desenvolvido pela equipe **UPD8 Inovação**.
