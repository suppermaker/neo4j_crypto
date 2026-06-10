# Crypto Neo4j Agent Guide

本文档用于帮助编码智能体快速理解和修改本仓库。开始工作前先阅读本文件；涉及本体设计时，再按下方索引读取对应文档。

## 项目概览

本项目用于构建“密码应用安全性评估报告”知识图谱。目前仓库只包含：

- Neo4j 本体设计文档
- Neo4j 约束、索引与全局字典初始化脚本
- 本地 Neo4j Docker Compose 部署脚本

当前没有 FastAPI、Vue、数据抽取程序或自动化测试框架。不要假设这些模块已经存在。

## 快速定位

| 需要了解或修改的内容 | 首选文件 | 相关文件 |
|---|---|---|
| 项目用途、启动方式、常用命令 | `README.md` | `.env.example` |
| 本体整体结构与建模原则 | `ontology/README.md` | `ontology/constraints.md` |
| 节点标签、属性字段 | `ontology/entity_types.md` | `ontology/neo4j_schema.cypher` |
| 关系类型、方向、允许的起止节点 | `ontology/relation_types.md` | `ontology/constraints.md` |
| 枚举值、质量标记、字典建议 | `ontology/enums.md` | `ontology/seed_dictionary.cypher` |
| ID、唯一性、多标签、缺失值和关系去重规则 | `ontology/constraints.md` | `ontology/neo4j_schema.cypher` |
| Neo4j 唯一约束、普通索引、全文索引 | `ontology/neo4j_schema.cypher` | `ontology/entity_types.md` |
| 算法、用途、安全需求、威胁的初始数据 | `ontology/seed_dictionary.cypher` | `ontology/enums.md` |
| 根据明确 ID 引用创建实例关系 | `ontology/link_instances.cypher` | `ontology/relation_types.md` |
| Neo4j 镜像、端口、插件、数据卷、健康检查 | `docker-compose.neo4j.yml` | `.env.example` |
| Neo4j 启停、日志、Shell、清理操作 | `scripts/neo4j.sh` | `docker-compose.neo4j.yml` |

快速全文定位建议：

```bash
rg -n 'CryptoApplication|USES_ALGORITHM' ontology/
rg -n 'CREATE (CONSTRAINT|INDEX)|FULLTEXT INDEX' ontology/neo4j_schema.cypher
rg -n 'MERGE|UNWIND' ontology/seed_dictionary.cypher
```

## 核心模型不变量

修改本体或编写导入代码时必须保持以下规则：

1. 每份报告对应一个 `Report`，每个被测系统对应一个 `System`，两者通过 `EVALUATES` 关联。
2. 资产、人员、文档和密码应用等实例应归属于某个 `System` 或 `Report`。
3. 系统内实例节点使用全局唯一 `id`，推荐格式为 `{system_id}:{entity_type}:{normalized_name}`。
4. 系统内实例节点应带 `Entity` 标签，以便 `Entity.id` 唯一约束和通用索引生效。
5. `CryptoAlgorithm`、`CryptoUsage`、`SecurityRequirement`、`Threat`、`ProductType`、`DataCategory`、`EvaluationCriterion` 是跨报告复用的全局字典节点。
6. 全局字典唯一键分别为算法 `name`、用途 `name`、安全需求 `name`，以及威胁、产品类型、数据类别、测评指标的 `code`。
7. 同一实体具备多个身份时使用多标签，不重复创建节点。
8. 关系类型使用大写下划线命名，方向必须遵循 `ontology/relation_types.md`。
9. 节点和关系尽量保留 `source_section`、`source_text`、`confidence` 等溯源信息。
10. 不可信占位值应保留原文，同时添加 `quality_flags` 并降低 `confidence`。
11. 导入关系时按 `start_node_id + relationship_type + end_node_id` 去重。
12. `ReportSection`、`ReportField` 是可选溯源辅助节点，不是核心领域实体；核心业务关系不得依赖它们中转。
13. `AssetType`、`NetworkZoneType`、`ComplianceResult` 是简单属性枚举，不创建对应节点；`ProductType`、`DataCategory`、`EvaluationCriterion` 必须作为全局字典节点复用。

## 修改联动清单

不要只修改单个说明文件。按改动类型同步检查以下文件：

| 改动类型 | 必须检查和同步的文件 |
|---|---|
| 新增或修改实体标签、属性 | `ontology/entity_types.md`、`ontology/README.md`、`ontology/neo4j_schema.cypher`、`ontology/constraints.md` |
| 新增或修改关系 | `ontology/relation_types.md`，必要时更新 `ontology/README.md` 和导入脚本 |
| 新增枚举或质量标记 | `ontology/enums.md`，必要时更新 `ontology/entity_types.md` |
| 新增或修改全局字典项 | `ontology/enums.md`、`ontology/seed_dictionary.cypher` |
| 修改唯一键、ID 或必填规则 | `ontology/constraints.md`、`ontology/neo4j_schema.cypher`、相关实体文档 |
| 修改 Neo4j 版本、端口、插件或资源配置 | `.env.example`、`docker-compose.neo4j.yml`、`README.md` |
| 修改运维命令 | `scripts/neo4j.sh`、`README.md` |

新增可查询属性时，判断是否需要同步新增普通索引或全文索引。新增字典数据时使用 `MERGE`，确保种子脚本可重复执行。

## 编码与文档约定

- Markdown 与领域内容以中文为主；标签、属性、关系和代码标识符使用英文。
- 节点标签使用 PascalCase，例如 `CryptoProduct`。
- 属性使用 snake_case，例如 `source_section`。
- 关系使用 UPPER_SNAKE_CASE，例如 `USES_ALGORITHM`。
- Cypher 脚本应可重复执行：schema 使用 `IF NOT EXISTS`，字典节点使用 `MERGE`。
- Shell 脚本保持 `set -euo pipefail`，变量使用双引号，路径从仓库根目录解析。
- 不要提交 `.env` 或真实密码；新增配置项时写入 `.env.example`。
- 保持改动聚焦。当前仓库没有应用代码，不要为小型本体改动引入新的框架或依赖。

## 常用命令

```bash
# 启动并等待 Neo4j 可连接
scripts/neo4j.sh up

# 查看状态、日志或进入 cypher-shell
scripts/neo4j.sh status
scripts/neo4j.sh logs
scripts/neo4j.sh shell

# 初始化或重复应用 schema 与字典
source .env
docker exec -i "$NEO4J_CONTAINER_NAME" cypher-shell \
  -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" \
  < ontology/neo4j_schema.cypher
docker exec -i "$NEO4J_CONTAINER_NAME" cypher-shell \
  -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" \
  < ontology/seed_dictionary.cypher
docker exec -i "$NEO4J_CONTAINER_NAME" cypher-shell \
  -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" \
  < ontology/link_instances.cypher

# 停止服务
scripts/neo4j.sh down
```

`scripts/neo4j.sh clean` 会停止服务并删除 Neo4j 数据卷，属于破坏性操作，除非用户明确要求重置数据，否则不要执行。

## 修改后的验证

本仓库当前没有自动化测试套件。根据改动范围执行以下验证：

```bash
# Shell 语法
bash -n scripts/neo4j.sh

# Compose 配置展开与校验
docker compose --env-file .env.example -f docker-compose.neo4j.yml config

# 查看项目文件和引用，检查文档是否同步
rg -n '<新增或修改的标签、属性、关系或字典值>' README.md ontology/
```

涉及 Cypher 行为时，应启动 Neo4j，依次执行 `neo4j_schema.cypher` 和 `seed_dictionary.cypher`，然后再次执行二者以确认幂等性。可使用以下查询做基本检查：

```cypher
SHOW CONSTRAINTS;
SHOW INDEXES;
MATCH (n:CryptoAlgorithm) RETURN count(n);
MATCH (n:CryptoUsage) RETURN count(n);
MATCH (n:SecurityRequirement) RETURN count(n);
MATCH (n:Threat) RETURN count(n);
```

预置字典当前应包含 6 个 `CryptoAlgorithm`、13 个 `CryptoUsage`、8 个 `SecurityRequirement`、24 个 `Threat`、8 个 `ProductType` 和 6 个 `DataCategory` 节点。`EvaluationCriterion` 从实际采用的标准导入，不预置通用值。

## 工作完成标准

- 相关设计文档与可执行 Cypher 保持一致。
- Cypher 初始化脚本可重复执行，不产生重复字典节点。
- 新增实例标签符合 `Entity`、唯一 ID、归属关系和溯源字段约定。
- 配置变更已同步到 `.env.example` 和 README。
- 已运行与改动范围相符的验证，并明确说明未能执行的验证。
