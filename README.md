# Crypto Neo4j

密码安全应用测评报告知识图谱项目。

## 本体模型

密评报告知识图谱的本体模型放在 `ontology/` 目录：

```text
ontology/README.md
ontology/entity_types.md
ontology/relation_types.md
ontology/enums.md
ontology/constraints.md
ontology/neo4j_schema.cypher
ontology/link_instances.cypher
```

本体设计采用“报告实例 + 被测系统实例 + 全局字典”的结构。不同报告中的资产、密码应用、人员、文档等实例挂到对应 `System` 节点下；密码算法、安全需求、密码用途、安全威胁、密码产品类型、数据类别和测评指标作为全局字典节点复用。

简单状态和分类提示使用属性枚举，例如 `AssetType`、`NetworkZoneType`、`ComplianceResult`；需要跨报告复用并与其他知识建立关系的概念使用字典节点，例如 `ProductType`、`DataCategory`、`EvaluationCriterion`。

`ReportSection` 和 `ReportField` 是可选的报告结构与溯源辅助节点，不属于图谱核心。核心业务实体直接建立关系；仅在需要完整报告结构或精确原文定位时创建章节、字段和 `EXTRACTED_FROM` 关系。

初始化 Neo4j schema 和字典节点：

```bash
source .env
docker exec -i crypto-neo4j cypher-shell -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" < ontology/neo4j_schema.cypher
docker exec -i crypto-neo4j cypher-shell -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" < ontology/seed_dictionary.cypher
docker exec -i crypto-neo4j cypher-shell -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" < ontology/link_instances.cypher
```

`link_instances.cypher` 只根据明确的 ID 引用创建关系，可重复执行。算法、威胁、保护对象等语义关系必须由报告内容或人工确认提供，脚本不会按标签猜测关联。

写入一套脱敏的实际业务形态测评数据：

```bash
scripts/load_sample_data.sh
```

该脚本依次应用 schema、全局字典、`ontology/sample_evaluation_data.cypher` 和实例自动关联脚本，可重复执行。样例包含一个政务服务平台，以及资产、密码产品、密码应用、重要数据、威胁、测评项、发现和证据。

## Neo4j 本地部署

本项目推荐使用 Docker Compose 部署 Neo4j，便于后续和 FastAPI、Vue 3 + TypeScript 一起组成完整开发环境。

### 启动

```bash
chmod +x scripts/neo4j.sh
scripts/neo4j.sh up
```

首次运行会自动从 `.env.example` 生成 `.env`。本地默认账号：

```text
username: neo4j
password: crypto_neo4j_password
```

### 访问

```text
Neo4j Browser: http://localhost:7474
Bolt URI:       bolt://localhost:7687
```

### 常用命令

```bash
scripts/neo4j.sh up       # 启动 Neo4j
scripts/neo4j.sh logs     # 查看日志
scripts/neo4j.sh shell    # 进入 cypher-shell
scripts/neo4j.sh status   # 查看状态
scripts/neo4j.sh down     # 停止服务
scripts/neo4j.sh clean    # 停止并删除数据卷
```

`clean` 会删除 Neo4j 数据卷，只建议在本地重置开发环境时使用。

### 环境变量

配置项在 `.env` 中维护，常用项：

```text
NEO4J_IMAGE=neo4j:5.26-community
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=crypto_neo4j_password
NEO4J_HTTP_PORT=7474
NEO4J_BOLT_PORT=7687
```

非本地环境请修改 `NEO4J_PASSWORD`。

## 图谱查询 API

本仓库提供一个轻量 FastAPI 服务，用于把 Neo4j 图谱内容以稳定 JSON 返回给后续 report 智能体。

### 安装依赖

```bash
uv sync --extra test
```

### 启动 API

先启动 Neo4j 并加载样例数据：

```bash
sudo scripts/neo4j.sh up
sudo scripts/load_sample_data.sh
```

再启动查询服务：

```bash
uv run uvicorn crypto_kg_api.main:app --host 0.0.0.0 --port 8000
```

默认读取以下环境变量，未设置时使用本地 Neo4j 默认值：

```text
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=crypto_neo4j_password
NEO4J_DATABASE=neo4j
```

### 常用接口

```bash
curl http://localhost:8000/api/v1/health
curl http://localhost:8000/api/v1/ready
curl http://localhost:8000/api/v1/systems/sys_gov_service/overview
curl http://localhost:8000/api/v1/systems/sys_gov_service/assets
curl http://localhost:8000/api/v1/reports/rpt_20260610_gov_service/generation-context
```

`generation-context` 是后续接入 report 智能体的主接口，只返回图中已有事实，不根据名称或文本猜测缺失关系。
